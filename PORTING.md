# Zigmacs Porting Log

This document tracks all patches, workarounds, and findings from porting GNU Emacs 30.1 to build with `zig cc`.

## Phase 0: Establish `zig cc` Build

**Goal:** Make GNU Emacs 30.1 build cleanly with `zig cc 0.17.0`, pass tests, and run in CI.

### Build Environment

- **Base:** GNU Emacs 30.1 (official tarball, commit `8ac894e`)
- **Toolchain:** Zig 0.17.0 (public release, pinned in CI)
- **Compiler:** `CC="zig cc"`
- **Platform:** CentOS Stream 9 (GLIBC 2.34), x86_64 Linux (local); ubuntu-latest (CI)
- **Dependencies:** Via linuxbrew (gnutls 3.8.12, libxml2 2.13.8, tree-sitter 0.25.6, ncurses 6.6) on local; via apt on CI

### Configure Flags (Ground-Truth Match)

```bash
./configure \
  --without-x \
  --with-gnutls \
  --with-xml2 \
  --with-modules \
  --without-ns \
  --without-imagemagick \
  --without-dbus \
  --without-selinux \
  --with-tree-sitter \
  --with-native-compilation=no
```

### Required Environment Variables

```bash
# PKG_CONFIG_PATH - to find linuxbrew dependencies
export PKG_CONFIG_PATH="/home/linuxbrew/.linuxbrew/lib/pkgconfig"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/home/linuxbrew/.linuxbrew/opt/gnutls/lib/pkgconfig"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/home/linuxbrew/.linuxbrew/opt/libxml2/lib/pkgconfig"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/home/linuxbrew/.linuxbrew/opt/tree-sitter/lib/pkgconfig"

# LDFLAGS/CPPFLAGS - for ncurses
export LDFLAGS="-L/home/linuxbrew/.linuxbrew/opt/ncurses/lib"
export CPPFLAGS="-I/home/linuxbrew/.linuxbrew/opt/ncurses/include"

# LD_LIBRARY_PATH - CRITICAL: system /usr/lib64 must come BEFORE brew paths
# This ensures the system libstdc++ (compatible with GLIBC 2.34) is used instead
# of brew's libstdc++ (which requires GLIBC 2.36+). Tree-sitter links against
# libstdc++, creating a transitive dependency.
export LD_LIBRARY_PATH="/usr/lib64:/home/linuxbrew/.linuxbrew/lib:$LD_LIBRARY_PATH"
```

### Source Code Patches

**NONE REQUIRED.** Emacs 30.1 builds with `zig cc 0.17.0` with zero source modifications.

### Build Warnings (Non-Fatal)

The following warnings are emitted by `zig cc` but do not prevent a successful build:

1. **`dispnew.c:3685:12`**: `variable 'changed_p' set but not used`
   - GCC doesn't warn on this; `zig cc` is stricter
   - No semantic impact; variable written but never read
   
2. **`json.c:326` and `fns.c:6084`**: `initializer-string for character array is too long`
   - Hex digit arrays declared as `char[16]` initialized with 17-char string literal (includes NUL)
   - `zig cc` suggests `nonstring` attribute
   - No runtime impact (NUL terminator is truncated)

3. **`keyboard.c:5418:19`**: `no previous extern declaration for non-static variable 'lispy_function_keys'`
   - `zig cc` prefers explicit `extern` or `static` for file-scope variables
   - GCC accepts implicit extern
   - No linkage issue

These warnings reflect `zig cc`'s stricter diagnostics compared to GCC. They are **tracked but not fixed** in Phase 0, as the goal is a byte-compatible build. If any become errors in future Zig versions, they will be addressed minimally.

### Runtime Environment Fix (RESOLVED - Defect 3)

**Issue:** The linked `emacs` binary transitively depends on `libstdc++.so.6` (via `libtree-sitter.so`). Linuxbrew's `libstdc++` (from gcc 14.2.0) requires GLIBC 2.36+, but CentOS Stream 9 ships GLIBC 2.34. Previous workaround used `LD_LIBRARY_PATH=/usr/lib64:...` which:
- Polluted shell environment
- Broke child processes (gh, unzip, bwrap in tests)
- Propagated to all subprocesses

**Solution (IMPLEMENTED):** Use **rpath** in LDFLAGS at configure time:

```bash
export LDFLAGS="-L/home/linuxbrew/.linuxbrew/opt/ncurses/lib"
export LDFLAGS="$LDFLAGS -Wl,-rpath,/usr/lib64"
export LDFLAGS="$LDFLAGS -Wl,-rpath,/home/linuxbrew/.linuxbrew/lib"
```

Rpath embeds library search paths in the binary and does NOT propagate to child processes.

**Verification:**
```bash
# Check rpath
readelf -d src/emacs | grep RUNPATH

# Run without any env pollution
unset LD_LIBRARY_PATH
src/emacs --version  # works!
```

**Launcher:** `scripts/zigmacs` provides clean invocation
**Build script:** `scripts/build-with-rpath.sh` documents the process

**Status:** `RESOLVED`. No environment variables needed, child processes run cleanly.

### Build Artifacts

- **Binary:** `src/emacs` (dynamically linked)
- **PDump:** `src/emacs.pdmp` (portable dumper format, Emacs 27+ default)
- **Warnings:** 4 diagnostics (see above), all non-fatal

### Test Results

_(To be filled after `make check`)_

### Files Modified

**NONE.** All changes are environment/build-system level.

### Commit History

1. `279988e` - Add oracle build script for fidelity testing
2. `59b7979` - Add .gitignore for build artifacts
3. `b6d2fc3` - Vendor pristine GNU Emacs 30.1
4. `323d710` - Add initial architecture documentation

---

## Phase N Roadmap (Not Implemented)

Future phases will:
- Port individual C modules to Zig
- Replace autotools with `build.zig`
- Establish fidelity harness comparing zig-emacs to gcc-oracle

See `ARCH.md` for the full incremental porting strategy.

---

## Phase 1: C↔Zig Interop Spike

**Status:** ✅ Complete (2026-10-15)

**Purpose:** Architecture de-risking spike to prove C↔Zig linkage — NOT a port. All changes are ADDITIVE, INERT, and reversible via `git revert`.

### Files Added (New, Reversible)
- **`src/zig_spike.zig`** — First Zig-language code in Zigmacs; exports functions callable from C
- **`src/zig_spike_glue.c`** — C glue exposing `zigmacs--interop-selftest` primitive to Elisp
- **`test/src/zig-spike-tests.el`** — ERT tests verifying C↔Zig interop

### Files Modified
- **`src/Makefile.in`** — Added Zig object build rule (`zig build-obj`) and linked `zig_spike.o` into `emacs`
- **`src/lisp.h`** — Declared `syms_of_zig_spike()`
- **`src/emacs.c`** — Registered `syms_of_zig_spike()` in symbol initialization

### Proof Requirements (All Met)
1. ✅ **Zig object links into binary:** `zig_spike.o` compiled via `zig build-obj -lc` and linked into `emacs`
   - Verification: `nm src/emacs | grep zig_spike` shows `zig_spike_selftest`, `zig_spike_cons`, `zig_spike_add1`
2. ✅ **C→Zig works:** C code (`zig_spike_glue.c`) calls Zig `export fn` functions
3. ✅ **Zig→C works:** Zig code calls real Emacs C functions (`Fcons`, `Fadd1`) via `extern "c"`
4. ✅ **Shared object model:** `Lisp_Object` round-trips correctly through Zig
   - Tested: fixnums (42), cons cells `(99 . 100)`, nested structures `(43 44 . 0)`

### Interop Mechanism
- **Approach:** Hand-declared `Lisp_Object` as `extern struct { i: u64 }` (matching C typedef on 64-bit builds)
- **C function calls:** Zig declares Emacs functions as `extern "c" fn Fcons(...) Lisp_Object`
- **No FFI/bindgen:** Direct C ABI compatibility via Zig's native C interop
- **`@cImport` status:** NOT attempted in this spike (focused on proving basic linkage; deferred to Phase 2+)

### Test Results
- **Manual verification:**
  ```elisp
  (zigmacs--interop-selftest) ⇒ (42 (99 . 100) (43 44 . 0))
  ```
  - Element 0: `42` — Zig called `Fadd1(41)`
  - Element 1: `(99 . 100)` — Zig built cons via `Fcons(99, 100)`
  - Element 2: `(43 44 . 0)` — Zig built nested cons via multiple `Fadd1` + `Fcons` calls

- **ERT tests:** `test/src/zig-spike-tests.el` passes (2/2 tests)
- **`make check` status:** Baseline parity (7740 tests, 1 unexpected in eglot-tests.log — same as Phase 0)
- **Channel B differential:** 12/12 corpus tests PASS (no regressions)

### What Changed
- New namespaced primitive `zigmacs--interop-selftest` (double-dash = internal/experimental)
- Zig build toolchain integrated into `src/Makefile` (uses `/home/kai/.local/zig/0.17.0/zig`)

### What Did NOT Change
- Zero changes to existing Emacs C functions or Elisp semantics
- Zero impact on normal Emacs use (primitive only exists, never auto-invoked)
- Spike is INERT — nothing changes unless user explicitly calls `(zigmacs--interop-selftest)`
- Fully reversible via `git revert` (one clean commit)

### Notes for Future Phases
- **`@cImport` exploration:** Zig 0.17.0 can `@cImport("lisp.h")` in theory, but requires careful header dependency management (config.h, macros). This spike proves the manual-extern fallback works; `@cImport` remains a stretch goal for real porting work.
- **Build system:** Current integration uses Makefile rules; Phase 2+ may move to `build.zig` for the full project.
- **Object model:** This spike uses simple fixnum/cons round-tripping. Real port will need full Lisp type system (strings, vectors, floats, symbols, etc.).

---
