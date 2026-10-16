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

## Phase N: Real C→Zig Ports (Incremental)

**Status:** 🟢 In Progress (35 functions ported)

### Port Map

| Function | Source | Zig Target | Status | Channel A | Channel B | Notes |
|----------|--------|-----------|--------|-----------|-----------|-------|
| `natnump` | `data.c:585` (Fnatnump) | `src/zig/natnump.zig` | ✅ PORTED | Property test + A/B mode | Corpus 13-natnump.el | First leaf port; establishes Channel A pattern |
| `nlistp` | `data.c:346` (Fnlistp) | `src/zig/nlistp.zig` | ✅ PORTED | Property test + A/B mode | Corpus 14-nlistp.el | Second leaf port; tests list predicates |
| `numberp` | `data.c:687` (Fnumberp) | `src/zig/numberp.zig` | ✅ PORTED | Property test + A/B mode | Corpus 15-numberp.el | Third leaf port; tests number predicates (fixnum/bignum/float) |
| `integerp` | `data.c:620` (Fintegerp) | `src/zig/integerp.zig` | ✅ PORTED | Property test + A/B mode | Corpus 16-integerp.el | Fourth leaf port; integer predicate (fixnum/bignum, NOT float) |
| `floatp` | `data.c:796` (Ffloatp) | `src/zig/floatp.zig` | ✅ PORTED | Property test + A/B mode | Corpus 17-floatp.el | Fifth leaf port; float predicate (float only, NOT integer) |
| `symbolp` | `data.c:430` (Fsymbolp) | `src/zig/symbolp.zig` | ✅ PORTED | Property test + A/B mode | Corpus 18-symbolp.el | Sixth leaf port; symbol predicate (nil and t ARE symbols) |
| `stringp` | `data.c:515` (Fstringp) | `src/zig/stringp.zig` | ✅ PORTED | Property test + A/B mode | Corpus 19-stringp.el | Seventh leaf port; string predicate (multibyte/unibyte) |
| `consp` | `data.c:333` (Fconsp) | `src/zig/consp.zig` | ✅ PORTED | Property test + A/B mode | Corpus 20-consp.el | Eighth leaf port; cons predicate (nil is NOT a cons) |
| `vectorp` | `data.c:544` (Fvectorp) | `src/zig/vectorp.zig` | ✅ PORTED | Property test + A/B mode | Corpus 21-vectorp.el | Ninth leaf port; vector predicate (strings/bool-vectors/char-tables are NOT vectors) |
| `listp` | `data.c:400` (Flistp) | `src/zig/listp.zig` | ✅ PORTED | Property test + A/B mode | Corpus 22-listp.el | Tenth leaf port; list predicate (nil IS a list, inverse of nlistp) |
| `goto-char` | `editfns.c:205` (Fgoto_char) | `src/zig/goto-char.zig` | ✅ PORTED | Snapshot→replay A/B mode | Corpus 23-goto-char.el | **FIRST Cat-C (stateful) port**; establishes snapshot→replay Channel A for mutations |
| `bare-symbol-p` | `data.c:587` (Fbare_symbol_p) | `src/zig/bare-symbol-p.zig` | ✅ PORTED | Property test + A/B mode | — (no corpus) | Cat A; earlier batch (table reconciled 2026-10-16) |
| `char-or-string-p` | `data.c:1122` (Fchar_or_string_p) | `src/zig/char-or-string-p.zig` | ✅ PORTED | Property test + A/B mode | — (no corpus) | Cat A; earlier batch |
| `atom` | `data.c:433` (Fatom) | `src/zig/atom.zig` | ✅ PORTED | Property test + A/B mode | — (no corpus) | Cat A; earlier batch |
| `length` | `fns.c:175` (Flength) | `src/zig/length.zig` | ✅ PORTED | Property test + A/B mode | — (no corpus) | Cat B; earlier batch |
| `memq` | `fns.c:2072` (Fmemq) | `src/zig/memq.zig` | ✅ PORTED | Property test + A/B mode | — (no corpus) | Cat B; earlier batch; uses `zig_memq_helper` for FOR_EACH_TAIL |
| `assq` | `fns.c:2161` (Fassq) | `src/zig/assq.zig` | ✅ PORTED | Property test + A/B mode | — (no corpus) | Cat B; earlier batch; uses `zig_assq_helper` |
| `processp` | `process.c:1016` (Fprocessp) | `src/zig/processp.zig` | ✅ PORTED | Property test + A/B mode | — (no corpus) | Cat H₁; earlier batch |
| `file-name-absolute-p` | `fileio.c:2982` (Ffile_name_absolute_p) | `src/zig/file-name-absolute-p.zig` | ✅ PORTED | Property test + A/B mode | — (no corpus) | Cat H₁; earlier batch |
| `coding-system-p` | `coding.c:8630` (Fcoding_system_p) | `src/zig/coding-system-p.zig` | ✅ PORTED | Property test + A/B mode | — (no corpus) | Cat H₁; earlier batch |
| `arrayp` | `data.c:944` (Farrayp) | `src/zig/arrayp.zig` | ✅ PORTED | Property test + A/B mode | Corpus 24-arrayp.el | **Round #2** (fan-out); Cat A |
| `recordp` | `data.c:763` (Frecordp) | `src/zig/recordp.zig` | ✅ PORTED | Property test + A/B mode | Corpus 25-recordp.el | Round #2; Cat A |
| `bool-vector-p` | `data.c:894` (Fbool_vector_p) | `src/zig/bool_vector_p.zig` | ✅ PORTED | Property test + A/B mode | Corpus 26-bool-vector-p.el | Round #2; Cat A |
| `sequencep` | `data.c:994` (Fsequencep) | `src/zig/sequencep.zig` | ✅ PORTED | Property test + A/B mode | Corpus 27-sequencep.el | Round #2; Cat A (CONSP‖NILP‖ARRAYP) |
| `car-safe` | `data.c:1436` (Fcar_safe) | `src/zig/car_safe.zig` | ✅ PORTED | Property test + A/B mode | Corpus 28-car-safe.el | Round #2; Cat B (`zig_CAR_SAFE`) |
| `cdr-safe` | `data.c:1495` (Fcdr_safe) | `src/zig/cdr_safe.zig` | ✅ PORTED | Property test + A/B mode | Corpus 29-cdr-safe.el | Round #2; Cat B (`zig_CDR_SAFE`) |
| `nth` | `fns.c:1958` (Fnth) | `src/zig/nth.zig` | ✅ PORTED | Property test + A/B mode | Corpus 30-nth.el | Round #2; Cat B (`Fcar (Fnthcdr …)`) |
| `safe-length` | `fns.c:235` (Fsafe_length) | `src/zig/safe_length.zig` | ✅ PORTED | Property test + A/B mode | Corpus 31-safe-length.el | Round #2; Cat B (`zig_safe_length_count` helper) |
| `bobp` | `editfns.c:1101` (Fbobp) | `src/zig/bobp.zig` | ✅ PORTED | Property test + A/B mode | Corpus 32-bobp.el | Round #2; Cat C read-only point pred (simple dispatcher) |
| `eobp` | `editfns.c:1154` (Feobp) | `src/zig/eobp.zig` | ✅ PORTED | Property test + A/B mode | Corpus 33-eobp.el | Round #2; Cat C read-only point pred |
| `bolp` | `editfns.c:1207` (Fbolp) | `src/zig/bolp.zig` | ✅ PORTED | Property test + A/B mode | Corpus 34-bolp.el | Round #2; Cat C (`zig_FETCH_BYTE`) |
| `eolp` | `editfns.c:1262` (Feolp) | `src/zig/eolp.zig` | ✅ PORTED | Property test + A/B mode | Corpus 35-eolp.el | Round #2; Cat C (`zig_FETCH_BYTE`) |
| `buffer-live-p` | `buffer.c:427` (Fbuffer_live_p) | `src/zig/buffer_live_p.zig` | ✅ PORTED | Property test + A/B mode | Corpus 36-buffer-live-p.el | Round #2; Cat H₁ (`zig_XBUFFER`/`zig_BUFFER_LIVE_P`) |
| `keymapp` | `keymap.c:152` (Fkeymapp) | `src/zig/keymapp.zig` | ✅ PORTED | Property test + A/B mode | Corpus 37-keymapp.el | Round #2; Cat H₁ (`zig_KEYMAPP`) |
| `window-live-p` | `window.c:343` (Fwindow_live_p) | `src/zig/window_live_p.zig` | ✅ PORTED | Property test + A/B mode | Corpus 38-window-live-p.el | Round #2; Cat H₁ (`zig_WINDOW_LIVE_P`) |

### Architecture: Channel A In-Process A/B Verification

Each ported function follows this pattern:
1. **Original C preserved** as `*_orig` (e.g., `natnump_orig` in data.c) — exact upstream, statically linked
2. **DEFUN becomes dispatcher**:
   - Normal mode: returns Zig result (`zig_natnump(object)`) — Zig is the live implementation
   - A/B mode (`ZIGMACS_AB=1`): computes BOTH, asserts `EQ`, aborts on mismatch with repro
3. **Shim layer**: `src/zig/shim.c` + `src/zig/shim.h` expose macro/inline/GMP API as linkable symbols
4. **Zig implementation**: self-contained (Zig 0.17.0 has limited module support), uses shim via `extern "c"`

### Verification Coverage (natnump)

- **Channel A Property Test**: `test/src/natnump-channel-a-tests.el` (5 ERT tests, comprehensive input battery)
  - Fixnum boundaries: 0, 1, -1, most-positive/negative-fixnum
  - Bignums: positive/negative, including large values (2^100, -2^100)
  - Non-integers: nil, t, symbols, strings, floats, cons, vectors
  - Runs with `ZIGMACS_AB=1` to enable in-process verification
- **Channel B Differential**: `test/fidelity/corpus/13-natnump.el` (oracle vs port, exact output match)
- **Existing ERT**: `test/src/data-tests.el` (57 tests, includes natnump coverage)

### Build Integration

- **Makefile rules** (`src/Makefile.in`):
  - `zig/shim.o`: Compile C shim with standard CC
  - `zig/natnump.o`: Compile Zig via `zig build-obj -target native -OReleaseSafe -lc`
  - Linked into `base_obj` (shim) and `zig_port_obj` (natnump)
- **Dependencies**: `src/zig/shim.{c,h}` must be compiled before any Zig port
- **ZIG variable**: Must be set to Zig binary path (e.g., `ZIG=/home/kai/.local/zig/0.17.0/zig make`)

### Bug-for-Bug Fidelity

natnump port matches upstream EXACTLY:
- ✅ Returns `t` for 0 (not an error)
- ✅ Returns `nil` for non-integers (floats, symbols, strings, etc.) — no type error
- ✅ Correct bignum sign handling via `mpz_sgn` shim
- ✅ Pure function (no side effects, matches `attributes: const`)

### Test Results

```
Channel A: 5/5 ERT tests PASS (with ZIGMACS_AB=1 verification)
Channel B: 13/13 corpus PASS (was 12/12; added 13-natnump.el)
data-tests: 57/57 PASS (existing test suite, no regressions)
```

### Files Added/Modified

**New files:**
- `src/zig/emacs.zig` — Shared type definitions (Lisp_Object), currently unused (Zig 0.17.0 module limits)
- `src/zig/shim.c` + `src/zig/shim.h` — Shared C shim (macro/inline/GMP wrappers)
- `src/zig/natnump.zig` — First real port (self-contained, inline bindings)
- `test/src/natnump-channel-a-tests.el` — Channel A property tests
- `test/fidelity/corpus/13-natnump.el` — Channel B differential input

**Modified files:**
- `src/data.c` — Added Channel A dispatcher for natnump, preserved original as `natnump_orig`
- `src/Makefile.in` — Build rules for zig/shim.o and zig/natnump.o

---
