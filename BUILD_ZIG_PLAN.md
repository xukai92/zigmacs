# Build.zig Takeover Plan

**Goal:** Replace Emacs's autotools-based build system with `build.zig`, incrementally, while preserving the "always-working editor" rule.

---

## Why Replace Autotools?

1. **Consistency:** Single toolchain (`zig build`) for compiling both C (via `zig cc`) and future Zig modules
2. **Cross-compilation:** Zig's native cross-compilation eliminates complex configure logic
3. **Speed:** Parallel builds without `make`'s serialization bottlenecks; incremental recompilation via caching
4. **Simplicity:** Replace 274KB `configure.ac` + 1.5MB generated `configure` with declarative Zig build script
5. **Fidelity:** Explicit dependency tracking (no hidden autoconf magic)

---

## Constraints

1. **Always-working editor:** Every commit must produce a runnable `emacs` binary
2. **Behavioral parity:** Output binary must be byte-for-byte equivalent to autotools build (initially)
3. **Incremental:** Coexist with autotools during transition (allow parallel builds)
4. **Ground-truth oracle:** Maintain `scripts/build-oracle.sh` (gcc+autotools) for fidelity testing

---

## Phases

### Phase 0: Scaffolding (Current State)

**Status:** ✅ DONE  
- Autotools build works with `zig cc`
- No `build.zig` yet

### Phase 1: Minimal `build.zig` (Proof of Concept)

**Goal:** Compile+link `src/emacs` using `zig build`, delegating to `zig cc` for C sources.

**Tasks:**

1. **Create `build.zig`** at repo root:
   ```zig
   const std = @import("std");

   pub fn build(b: *std.Build) void {
       const target = b.standardTargetOptions(.{});
       const optimize = b.standardOptimizeOption(.{});

       const emacs = b.addExecutable(.{
           .name = "emacs",
           .target = target,
           .optimize = optimize,
       });

       // Add all C sources from src/
       emacs.addCSourceFiles(&.{
           "src/dispnew.c",
           "src/frame.c",
           // ... (all 80+ C files)
       }, &.{
           "-DHAVE_CONFIG_H",
           "-I.", "-I./src", "-I./lib",
           // ... (cflags from Makefile)
       });

       // Link libraries
       emacs.linkSystemLibrary("ncursesw");
       emacs.linkSystemLibrary("gnutls");
       emacs.linkSystemLibrary("xml2");
       emacs.linkSystemLibrary("tree-sitter");
       emacs.linkSystemLibrary("lcms2");
       emacs.linkSystemLibrary("z");

       // Link gnulib
       emacs.addObjectFile(.{ .path = "lib/libgnu.a" });

       b.installArtifact(emacs);
   }
   ```

2. **Generate `src/config.h`** in `build.zig`:
   - Run minimal feature detection (replace autoconf probes with `std.zig.system` queries)
   - Or: parse existing `config.h` from autotools build and hardcode values as comptime known
   - **Temporary:** Symlink to autotools-generated `config.h` (transitional hack)

3. **Build lib/libgnu.a separately:**
   - `zig build-lib` for gnulib sources, or
   - Let `build.zig` compile them directly (preferred)

4. **Test:**
   ```bash
   zig build
   ./zig-out/bin/emacs --version
   ```

**Deliverable:** `zig build` produces a working `emacs` binary.

**Caveats:**
- Does NOT handle pdumper yet (uses stock `loadup.el` without dumping)
- Config.h still autotools-generated
- Coexists with `make` (two build systems in parallel)

---

### Phase 2: PDumper Integration

**Goal:** Generate `emacs.pdmp` (portable dump file) as part of `zig build`.

**Challenges:**
1. PDumper requires running `emacs --batch -l loadup.el` to serialize preloaded elisp
2. Circular dependency: need `emacs` binary to generate `.pdmp`, which `emacs` loads at startup

**Solution:**
1. **Bootstrap binary:** `zig build` creates `zig-out/bin/temacs` (emacs without pdump support)
2. **Run pdumper:** Execute `temacs --batch -l loadup.el --temacs=pbootstrap` to generate `emacs.pdmp`
3. **Final binary:** Link `emacs` with hardcoded path to `emacs.pdmp`

**build.zig changes:**
```zig
const temacs = b.addExecutable(.{
    .name = "temacs",
    .target = target,
    .optimize = optimize,
});
// ... (same as Phase 1 emacs)

const pdump_step = b.addSystemCommand(&.{
    "./zig-out/bin/temacs", "--batch", "-l", "loadup.el",
    "--temacs=pbootstrap",
    "--bin-dest", "./zig-out/bin/",
    "--eln-dest", "./zig-out/lib/emacs/30.1/",
});
pdump_step.step.dependOn(&temacs.step);

const emacs = b.addExecutable(.{
    .name = "emacs",
    // ... same as temacs, but links against generated .pdmp
});
emacs.step.dependOn(&pdump_step.step);
```

**Test:**
```bash
zig build
./zig-out/bin/emacs --eval '(message "Pdumper works: %s" (featurep 'pdumper))'
```

**Deliverable:** `zig build` produces `emacs` + `emacs.pdmp`, fully functional.

---

### Phase 3: Feature Detection (Replace Autoconf)

**Goal:** Eliminate dependency on autotools-generated `config.h`.

**Approach:**

1. **Port autoconf probes to Zig comptime:**
   ```zig
   fn detectFeatures(b: *std.Build) Features {
       var features: Features = .{};

       // Example: check for gettimeofday
       const has_gettimeofday = b.runCCompile(&.{
           "int main() { struct timeval t; gettimeofday(&t, 0); return 0; }"
       }) == 0;

       features.HAVE_GETTIMEOFDAY = has_gettimeofday;
       // ... (repeat for 200+ probes)

       return features;
   }
   ```

2. **Generate config.h dynamically:**
   ```zig
   pub fn build(b: *std.Build) void {
       const features = detectFeatures(b);
       const config_h = b.addWriteFile("src/config.h", features.toConfigH());
       emacs.step.dependOn(&config_h.step);
       // ...
   }
   ```

3. **Hardcode stable features:**
   - Most `HAVE_*` macros are platform-stable (e.g., `HAVE_UNISTD_H` always true on Linux)
   - Only detect dynamic features (library versions, optional headers)

**Deliverable:** `zig build` no longer requires running `./configure`.

---

### Phase 4: Incremental C→Zig Module Porting

**Goal:** Replace individual `.c` files with `.zig` equivalents, compiled together.

**Example: Port `src/itree.c` to `src/itree.zig`:**

1. **Create `src/itree.zig`:**
   ```zig
   const std = @import("std");
   const c = @cImport({
       @cInclude("lisp.h");  // Import Emacs C headers
   });

   export fn itree_insert(tree: *c.itree, node: *c.itree_node) void {
       // Zig implementation
   }
   // ... (port all functions)
   ```

2. **Update `build.zig`:**
   ```zig
   emacs.addCSourceFiles(&.{
       "src/dispnew.c",
       "src/frame.c",
       // "src/itree.c",  // REMOVED
       // ... other .c files
   }, &.{ /* cflags */ });

   emacs.root_module.addCSourceFile(.{
       .file = .{ .path = "src/itree.zig" },
       .flags = &.{"-DHAVE_CONFIG_H"},
   });
   ```

3. **Fidelity test:**
   ```bash
   zig build
   ./zig-out/bin/emacs --eval '(progn (itree-insert ...) (message "Zig itree works"))'
   diff <(./oracle/emacs-gcc --batch --eval '(...)') \
        <(./zig-out/bin/emacs --batch --eval '(...)')
   ```

**Deliverable:** Emacs with 1 Zig module, N-1 C modules, behavior-identical to pure-C build.

**Iteration:** Repeat for each module, prioritizing:
- Leaf modules (no dependents, e.g., `itree.c`, `sort.c`)
- High-complexity modules benefiting from Zig safety (e.g., `alloc.c`)
- Avoid core modules like `eval.c` until late phases

---

### Phase 5: Full Zig Build

**Goal:** All `.c` files ported to `.zig`; autotools fully removed.

**Cleanup:**
- Delete `configure.ac`, `Makefile.in`, `aclocal.m4`, etc.
- Remove `scripts/build-oracle.sh` (oracle is final autotools build artifact, frozen)
- Archive `PORTING.md` as historical record

**Deliverable:** `zig build` is the ONLY build system.

---

## Incremental Validation Strategy

At each phase boundary, run **fidelity tests** comparing new build to oracle:

1. **Binary size:** `ls -l zig-out/bin/emacs oracle/emacs-gcc` (should be within 1%)
2. **Symbol table:** `nm -D` (exported symbols should match)
3. **Runtime behavior:** Automated test suite (`make check` → `zig build test`)
4. **Manual smoke tests:**
   ```bash
   ./zig-out/bin/emacs --batch --eval '(message "Test: %s" (+ 1 2))'
   ```

If fidelity diverges:
1. **Bisect:** Rollback to last known-good commit
2. **Isolate:** Compare `zig cc` vs. `gcc` output for specific `.c` file
3. **Fix:** Adjust `build.zig` cflags or investigate Zig compiler bug

---

## Coexistence Plan (Phase 1–4)

While both autotools and `build.zig` exist:

1. **Separate output dirs:**
   - Autotools: `src/emacs`, `src/emacs.pdmp`
   - Zig: `zig-out/bin/emacs`, `zig-out/bin/emacs.pdmp`

2. **Makefile targets:**
   ```makefile
   # Add to Makefile
   .PHONY: zig-build
   zig-build:
       zig build

   .PHONY: zig-test
   zig-test:
       zig build test
   ```

3. **CI runs both:**
   ```yaml
   # .github/workflows/ci.yml
   - name: Build with autotools
     run: make -j$(nproc) src

   - name: Build with zig build
     run: zig build

   - name: Test both binaries
     run: |
       ./src/emacs --version
       ./zig-out/bin/emacs --version
   ```

4. **Document parity:** Each commit message notes "autotools/zig both pass tests"

---

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|-----------|
| Config.h probes incorrect | Broken build on exotic platforms | Start with hardcoded Linux values; test macOS/FreeBSD separately |
| PDumper doesn't run | No preloaded elisp | Keep `temacs` fallback; debug step-by-step |
| Zig `.o` files incompatible with gcc `.o` | Link failures | Use `zig cc` for ALL C sources (no mixing) |
| Build time regression | Slower than `make -j` | Profile `zig build`; parallelize artifact steps |
| Community resistance | Users prefer autotools | Maintain autotools in parallel through Phase 4; only remove after 6mo of `build.zig` stability |

---

## Timeline Estimate (Single Developer)

- **Phase 1 (Scaffold):** 1 week (500 LOC `build.zig`)
- **Phase 2 (PDumper):** 1 week (debugging bootstrap)
- **Phase 3 (Feature detect):** 2 weeks (port 200+ probes)
- **Phase 4 (C→Zig porting):** 6–12 months (80+ files, incremental)
- **Phase 5 (Cleanup):** 1 week (delete old build system)

**Total:** ~7–13 months for full migration.

---

## Alternative: Hybrid Approach (Long-Term Coexistence)

If full porting proves impractical:

1. **Use `build.zig` for orchestration ONLY:**
   - Shell out to `./configure` and `make` for C compilation
   - `zig build` wraps autotools, adding Zig module compilation

2. **Zig modules compile separately:**
   - `build.zig` compiles `src/*.zig` → `zig-out/lib/zigmacs.a`
   - Autotools `Makefile` links `zigmacs.a` into final `emacs` binary

3. **Incremental wins:**
   - Benefit from Zig safety in new modules
   - Avoid risky autoconf replacement
   - Lower maintenance burden

**Trade-off:** Lose cross-compilation, retain configure complexity.

---

## Next Immediate Step

Create minimal `build.zig` (Phase 1 scaffold) in a **new branch**:

```bash
git checkout -b phase1-build-zig
# Create build.zig (per Phase 1 spec above)
zig build
# Test, compare to autotools binary
git add build.zig
git commit -m "Phase 1: Minimal build.zig scaffold

Compiles src/emacs using zig build, delegating to zig cc for C sources.
Coexists with autotools (outputs to zig-out/ vs. src/).

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

**Do NOT merge to `master`** until fidelity tests pass and CI validates both builds.

---

## References

- [Zig Build System Documentation](https://ziglang.org/documentation/master/#Build-System)
- GNU Emacs `INSTALL.REPO` (autotools workflow)
- `src/Makefile.in` (comprehensive cflags/ldflags reference)
- [Porting Emacs to Haiku](https://github.com/emacs-mirror/emacs/blob/master/etc/PROBLEMS) (similar build system replacement)

---

**Status:** Plan complete, awaiting Phase 1 implementation approval.
