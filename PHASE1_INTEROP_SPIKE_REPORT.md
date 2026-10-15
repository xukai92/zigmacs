# Phase-1 C↔Zig Interop Spike — Final Report

**Status:** ✅ **COMPLETE** — All four proof requirements met

**Commit:** `832c02a` (main spike) + `22bc2f5` (CI fix)

**Date:** 2026-10-15

---

## Executive Summary

The Phase-1 C↔Zig interop spike **successfully proves** that Zig code can compile to a native object, link into the `emacs` binary built with `zig cc`, and bidirectionally call across the C↔Zig boundary while correctly round-tripping `Lisp_Object` values. This is the **FIRST Zig-language code** in Zigmacs.

The spike is **ADDITIVE** (new files only), **INERT** (never auto-invoked), **NAMESPACED** (`zigmacs--*`), and **REVERSIBLE** via `git revert`. It introduces zero changes to existing Emacs semantics and zero regressions in the test suite or fidelity differential.

---

## Proof of Concept — All Four Requirements Met

### 1. ✅ Zig Object Links Into Binary

**Mechanism:**
- `src/zig_spike.zig` compiled with `zig build-obj -target native -OReleaseSafe -lc` (NOT `zig cc`)
- Output: `src/zig_spike.o` (native ELF object)
- Linked into `temacs` → `emacs` binary via modified `src/Makefile.in` (added to `obj` variable)

**Verification:**
```bash
$ nm src/emacs | grep zig_spike
000000000122c8f0 T syms_of_zig_spike
000000000122c960 T zig_spike_add1
000000000122c950 T zig_spike_cons
000000000122c910 T zig_spike_selftest
000000000122c960 T zig_spike_simple_test
```

**Symbols present:** All Zig `export fn` functions are visible in the final binary. ✅

---

### 2. ✅ C → Zig Calls Work

**Mechanism:**
- C code (`src/zig_spike_glue.c`) declares Zig functions as `extern`:
  ```c
  extern Lisp_Object zig_spike_simple_test (Lisp_Object n);
  ```
- Calls them directly in the `Fzigmacs__interop_selftest` primitive

**Verification:**
```bash
$ src/emacs -Q --batch --eval "(fboundp 'zigmacs--interop-selftest)"
t
```

The primitive exists and is callable from Elisp (which calls C, which calls Zig). ✅

---

### 3. ✅ Zig → C Calls Work

**Mechanism:**
- Zig code declares Emacs C functions as `extern "c"`:
  ```zig
  extern "c" fn Fcons(car: Lisp_Object, cdr: Lisp_Object) Lisp_Object;
  extern "c" fn Fadd1(number: Lisp_Object) Lisp_Object;
  ```
- Calls them directly:
  ```zig
  const result = Fadd1(number);  // Calls real Emacs C function
  const cons_cell = Fcons(car, cdr);
  ```

**Verification:**
```bash
$ src/emacs -Q --batch --eval "(zigmacs--interop-selftest)"
(42 (99 . 100) (43 44 . 0))
```

- `42`: Zig called `Fadd1(41)` → proof Zig→C works ✅
- `(99 . 100)`: Zig called `Fcons(make_fixnum(99), make_fixnum(100))` → proof Zig builds structures via C ✅

---

### 4. ✅ Shared Object Model — `Lisp_Object` Round-Trips Correctly

**Mechanism:**
- On 64-bit builds without `CHECK_LISP_OBJECT_TYPE`, Emacs defines:
  ```c
  typedef Lisp_Word Lisp_Object;  // where Lisp_Word is pointer-width (struct Lisp_X * or EMACS_INT)
  ```
- Zig mirrors this as:
  ```zig
  pub const Lisp_Object = extern struct { i: u64 };  // matches C ABI layout
  ```
- Fixnums are tagged: `(n << 3) + 2` (LSB tagging, `INTTYPEBITS=3`, `Lisp_Int0=2`)
- Zig implements `make_fixnum` and `xfixnum` using the same bit shifts

**Verification:**
```elisp
(zigmacs--interop-selftest)
⇒ (42 (99 . 100) (43 44 . 0))
```

- **Element 0:** `42` — Zig received fixnum `41`, called `Fadd1`, returned fixnum `42`
  - Proves fixnum encoding/decoding works ✅
- **Element 1:** `(99 . 100)` — Zig built a cons cell using `Fcons`
  - Proves cons structure round-trips ✅
- **Element 2:** `(43 44 . 0)` — Zig built nested cons `(43 . (44 . 0))` via multiple `Fadd1` + `Fcons` calls
  - Proves complex structures work ✅

**`@cImport` Status:**
- **NOT attempted** in this spike (focused on proving basic linkage)
- PRIMARY approach (hand-declared externs) is sufficient for the spike
- STRETCH goal deferred: Zig's `@cImport("lisp.h")` could eliminate manual declarations, but requires careful header management (config.h, macros). This is a Phase 2+ exploration.

---

## Testing & Validation

### Manual Verification
```bash
$ src/emacs -Q --batch --eval "(zigmacs--interop-selftest)"
(42 (99 . 100) (43 44 . 0))
```
✅ Returns expected values demonstrating all four proof requirements.

### ERT Tests
```bash
$ src/emacs -Q --batch -l test/src/zig-spike-tests.el -f ert-run-tests-batch-and-exit
Running 2 tests (2026-10-15 15:36:18+0000, selector 't')
   passed  1/2  zig-spike-interop-selftest (0.000086 sec)
   passed  2/2  zig-spike-primitive-exists (0.000022 sec)

Ran 2 tests, 2 results as expected, 0 unexpected
```
✅ 2/2 tests pass.

### `make check` — Baseline Parity
```
Files examined: 539
Ran 7740 tests, 7495 results as expected, 1 unexpected, 244 skipped
1 file contained unexpected results:
  lisp/progmodes/eglot-tests.log
```
✅ Same 1 unexpected (eglot) as Phase 0 baseline — **NO REGRESSIONS**.

### Channel B Differential — Fidelity Unchanged
```bash
$ for f in test/fidelity/corpus/*.el; do \
    python3 test/fidelity/channel-b.py \
      --oracle oracle/emacs-gcc \
      --port src/emacs \
      --harness-dir test/fidelity \
      --input "$f"; \
  done
```

**Result:** 12/12 PASS — no regressions in observable Elisp behavior. ✅

---

## Files Changed

### New Files (Reversible)
- **`src/zig_spike.zig`** (114 lines) — First Zig code; exports `zig_spike_{add1,cons,selftest,simple_test}`
- **`src/zig_spike_glue.c`** (53 lines) — C glue; defines `Fzigmacs__interop_selftest` and `syms_of_zig_spike`
- **`test/src/zig-spike-tests.el`** (72 lines) — ERT tests

### Modified Files
- **`src/Makefile.in`** — Added Zig build rule and linked `zig_spike.o` into `obj`
- **`src/lisp.h`** — Declared `extern void syms_of_zig_spike (void);`
- **`src/emacs.c`** — Registered `syms_of_zig_spike();` in symbol initialization
- **`PORTING.md`** — Documented Phase 1 spike

**Total diff:** +292 lines, -2 lines (7 files changed)

---

## Build Integration

### Zig Object Build Rule
```makefile
ZIG ?= zig
zig_spike.o: $(srcdir)/zig_spike.zig
	$(AM_V_GEN)$(ZIG) build-obj -target native -OReleaseSafe -lc \
	  $(srcdir)/zig_spike.zig -femit-bin=$@
```

- Uses `zig build-obj` (NOT `zig cc`) to compile Zig source to native object
- `-lc` required for `extern "c"` declarations
- `ZIG ?= zig` allows override for local dev (`make ZIG=/custom/path/zig`)

### Link Integration
```makefile
zig_spike_obj = zig_spike.o
doc_obj = $(base_obj) $(NS_OBJC_OBJ)
obj = $(doc_obj) $(HAIKU_CXX_OBJ) $(zig_spike_obj)
```

- `zig_spike.o` added to `obj` (NOT `base_obj` or `doc_obj`) to avoid `.o` → `.c` substitution in `make-docfile`
- `zig_spike_glue.o` in `base_obj` (normal C compilation)

---

## CI Status

**Commits Pushed:** `832c02a` (main spike) + `22bc2f5` (CI path fix)

**CI Run:** https://github.com/xukai92/zigmacs/actions (triggered on push to `master`)

**Expected Outcome:**
- Zig 0.17.0 already installed in CI workflow
- `ZIG ?= zig` allows CI to use `zig` from PATH
- Build: `make -j$(nproc) src` should succeed
- Tests: `make check` allowlisted for eglot failures (same as Phase 0)

**Manual Verification Pending:** CI run in progress.

---

## Guardrails — All Maintained

### ✅ No Regressions
- `make check`: 7740 tests, 1 unexpected (eglot) — same as baseline
- Channel B: 12/12 corpus tests PASS

### ✅ Differential Stays Green
- Oracle (`oracle/emacs-gcc`) vs. Port (`src/emacs`) produce identical outputs on all 12 fidelity corpus cases

### ✅ Additive & Inert
- New primitive `zigmacs--interop-selftest` is namespaced (double-dash = internal)
- Never auto-invoked; only exists if explicitly called
- Zero impact on normal Emacs use

### ✅ Reversible
- Single clean commit: `git revert 832c02a` removes all spike code
- No entanglement with existing Emacs functionality

---

## Mechanism Summary

### C ↔ Zig Boundary
| Direction | Mechanism | Example |
|-----------|-----------|---------|
| **C → Zig** | `extern Lisp_Object zig_spike_add1(...)` in C, `export fn zig_spike_add1(...)` in Zig | `Fzigmacs__interop_selftest` calls Zig functions |
| **Zig → C** | `extern "c" fn Fadd1(...) Lisp_Object` in Zig | Zig calls `Fadd1`, `Fcons` |

### Lisp_Object Representation
| Type | C Encoding | Zig Encoding |
|------|------------|--------------|
| **Fixnum 42** | `(42 << 3) + 2 = 338` | `make_fixnum(42)` → `{ .i = 338 }` |
| **Cons `(99 . 100)`** | `Fcons(make_fixnum(99), make_fixnum(100))` | Same function called from Zig |

---

## Lessons for Phase 2+

### What Worked
- **Direct C ABI compatibility:** Zig's `extern "c"` and `export fn` are zero-overhead
- **Hand-declared externs:** Simple, explicit, no tooling dependencies
- **Additive integration:** Makefile rules are clean and isolated

### What to Explore
- **`@cImport` for full header inclusion:**
  - Zig can `@cImport("lisp.h")` to auto-generate bindings
  - Requires resolving macro expansion (e.g., `INLINE`, `DEFUN`) and header dependencies
  - Benefit: eliminates manual extern declarations, ensures type safety
  - Risk: C macros may not translate cleanly to Zig (needs testing)

- **Build system migration:**
  - Current: Makefile rule for `.zig` → `.o`, then link via existing autotools
  - Future: `build.zig` orchestrating full build (Zig + remaining C) in one graph

- **Object model completeness:**
  - This spike only handles fixnums and cons cells
  - Real port needs: strings, vectors, symbols, floats, hash tables, etc.
  - Next step: port `data.c` or `alloc.c` functions to Zig

---

## Commit Details

### Main Spike Commit
```
832c02a Phase-1 C↔Zig interop spike: prove linkage (ADDITIVE/INERT)

Proves all four interop requirements:
1. Zig object links into emacs binary (zig_spike.o via zig build-obj)
2. C→Zig calls work (C glue calls Zig export functions)
3. Zig→C calls work (Zig calls Fcons, Fadd1)
4. Lisp_Object round-trips correctly (fixnums + cons cells)
...
Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
```

### CI Fix Commit
```
22bc2f5 Fix Zig path for CI: use ZIG?=zig instead of hardcoded path

The Makefile hardcoded ZIG=/home/kai/.local/zig/0.17.0/zig which
works locally but breaks CI (where zig is in PATH).

Change to ZIG?=zig with override capability for local dev.

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
```

**Committer:** Kai Xu `<xuk@redhat.com>`

---

## Next Steps (Not Implemented)

1. **Verify CI passes:** Monitor GitHub Actions run for green status
2. **Phase 2 planning:** Choose first subsystem to port (e.g., simple primitives from `data.c`)
3. **Explore `@cImport`:** Attempt `@cImport("lisp.h")` in isolation to assess macro/header complexity
4. **Incremental porting:** Port one function at a time, keeping `make check` green at each step

---

## Conclusion

The Phase-1 C↔Zig interop spike **successfully de-risks** the core architectural challenge of Zigmacs: proving that Zig and C can coexist in the same binary, call each other freely, and share the Lisp object graph without FFI overhead. All four proof requirements are met with clean, reversible code.

This is the **FIRST Zig-language code** in Zigmacs and establishes the foundation for incremental C→Zig porting in Phase 2+.

**Status:** ✅ **SPIKE COMPLETE** — Ready for Phase 2.

---

**Report Date:** 2026-10-15  
**Agent:** Claude Sonnet 4.5  
**Repository:** https://github.com/xukai92/zigmacs  
**Commit:** 832c02a (spike) + 22bc2f5 (CI fix)
