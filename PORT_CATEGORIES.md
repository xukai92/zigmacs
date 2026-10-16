# Zigmacs — Port Categories & Progress Tracker

> Living tracker for the C→Zig port surface: categories by difficulty, progress,
> and the per-category "how-to". Companion to `ARCH.md` (strategy), `HARNESS.md`
> (fidelity), and `PORTING.md` (per-function log). **Keep this updated as ports land.**

## Metadata (what we are porting / with)

| | |
|---|---|
| **Base** | GNU Emacs **30.1** |
| **Upstream pin** | git tag `emacs-30.1`, commit `8ac894e2246f25d2a2a97d866b10e6e0b0fede5a` (mirror `github.com/emacs-mirror/emacs`) |
| **Toolchain** | Zig **0.17.0** (`zig cc` for C; `zig build-obj` for Zig). `@cImport` removed in 0.17 → binding = `extern` + thin C shim (see `ARCH.md` §3) |
| **Build config** | `--without-x --with-gnutls --with-xml2 --with-modules --with-tree-sitter --with-native-compilation=no` (matches ground-truth; nox) |
| **Golden oracle** | `oracle/emacs-gcc` — gcc build of the exact vendored source (`scripts/build-oracle.sh`) |
| **Repo** | `github.com/xukai92/zigmacs` |
| **Fidelity gates** | per-PR: build + `make check` (allowlist gate, 25-min timeout); nightly: full byte-identical + ERT results-equality vs oracle |
| **Last updated** | 2026-10-16 — 20 ports landed (Cat A 13, B 3, C 1, H₁ 3); first stateful (Cat-C) port done |

## Progress by category

Surface ≈ **1,790 DEFUN primitives** total (~1,300 relevant to the nox build; ~400 are GUI backends, excluded). **DEFUN-count is a poor progress proxy** — most effort/risk is in a few huge subsystems (D–G), which are whole-engine rewrites, not per-function ports.

| Cat | What | Unit | Done / Total | Difficulty | Phase |
|---|---|---|---|---|---|
| **A** | Pure type predicates / `const` primitives | DEFUN | **13 / 25** | ★ trivial | 1 |
| **B** | Pure computational primitives (arith, list/seq/string builders) | DEFUN | **3 / ~230** *(est)* | ★★ easy-med | 1 |
| **C** | Stateful primitives (mutate buffer/point/match-data/globals) | DEFUN | **1 / ~260** *(est)* | ★★★ med | 1 |
| **D** | Interpreter & reader core (`eval`, `bytecode` VM, `lread`) | subsystem | 0 / ~75 DEFUN + 3 engines | ★★★★ hard | 1–2 |
| **E** | Buffer/text engine & search (`buffer`,`editfns`,`textprop`,`marker`,`insdel`,`search`,`regex`; ~21K LOC) | subsystem | 0 | ★★★★ hard | 2 |
| **F** | Garbage collector (`alloc.c`, 8.4K LOC) | subsystem | 0 | ★★★★★ very hard | 2 |
| **G** | Redisplay/terminal/windows (`xdisp` 38.6K, `dispnew`, `term`, `window`, `frame`; ~56K LOC) | subsystem | 0 | ★★★★★ hardest | 2+ |
| **H** | I/O · process · event-loop · coding · tree-sitter · module/native-comp compat | DEFUN+ | **3 / ~280** *(est; H₁ slice)* | ★★★ med-hard | 1–3 |
| **X** | GUI window-system backends (`xfns`/`pgtk`/`w32`/`ns`/`android`/`haiku`) | — | out of scope (nox) | — | — |

*`~` = estimate from per-file DEFUN counts; replace with exact classification when done.*

## How-to per category

### Cat A — Pure type predicates ✅ recipe proven (10 landed)
1. `src/zig/<name>.zig`: `export fn zig_<name>(object) Lisp_Object` using shim wrappers.
2. Add any missing shim wrapper to `src/zig/shim.{c,h}` (`zig_<MACRO>` = one-line `return <MACRO>(x);`).
3. `src/data.c`: retain original as `<name>_orig`; make the `DEFUN` a **Channel A dispatcher** (call `zig_<name>` live; under `ZIGMACS_AB=1` run both + assert `EQ` + abort on mismatch).
4. `src/Makefile.in`: add `zig/<name>.o` build rule (`zig build-obj`) + to `zig_port_obj`; declare prototype in `lisp.h`.
5. Tests: `test/src/<name>-channel-a-tests.el` + `test/fidelity/corpus/NN-<name>.el`.
6. **Clean-build check** (`make -C src clean && make`) BEFORE push; then CI green (gate `Real failures: 0`).

### Cat B — Pure computational primitives ✅ recipe proven (`length`, `memq`, `assq`)
Same Channel A dispatcher as A (dispatchers live in the fn's file, e.g. `fns.c`), but:
1. **Error-signal fidelity is the crux.** Reproduce the EXACT signal bug-for-bug (`length`/`memq`/`assq` signal `wrong-type-argument`/`circular-list` on improper/circular input). Don't just match the happy path.
2. **Delegate hairy C to a shim helper, don't reimplement in Zig.** For `FOR_EACH_TAIL` + `CHECK_LIST_END` (tortoise/hare cycle detection), write a small C helper (`zig_memq_helper`, `zig_assq_helper`) and call it from Zig — keeps the port exact and simple. Allocation (`Fcons`) is a plain extern call.
3. **More accessors** than A: `XCAR`/`XCDR`/`CONSP`/`ASIZE`/`SCHARS`/`PVSIZE`/`EQ`/`BASE_EQ` shims.
4. **Tests are property/fuzz batteries** (~10–20 edge cases): empty, single, long, dotted, **circular**, strings (ASCII+multibyte), vectors, bool-vectors, char-tables, wrong types, `eq`-vs-`equal` semantics.

### Cat C — Stateful primitives ✅ recipe proven (`goto-char`)
Ports that mutate observable state (buffer point, mark, narrowing, text, match-data, globals). The Channel A dispatcher uses **snapshot→replay** to verify that Zig and C produce identical (return + post-state) on identical pre-state:

1. **Identify the touched state** for the primitive (e.g., `goto-char` touches **point** only; future ports may touch mark, narrowing, text, markers, match-data, or globals).
2. `src/zig/<name>.zig`: implement the Zig port using shim wrappers for state accessors/mutators (e.g., `zig_PT`, `zig_SET_PT`, `zig_BEGV`, `zig_ZV` for point; add wrappers to shim as needed).
3. `src/<file>.c`: retain original as `<name>_orig`; make the `DEFUN` a **snapshot→replay Channel A dispatcher**:
   - Under `ZIGMACS_AB=1`:
     - **SNAPSHOT** the touched state (e.g., `ptrdiff_t snapshot_pt = PT;` for point)
     - Run `<name>_orig(args)` (original C) → capture return + post-state
     - **RESTORE** state to snapshot (e.g., `SET_PT(snapshot_pt);`)
     - Run `zig_<name>(args)` (Zig port) → capture return + post-state
     - **Assert** `EQ(zig_result, c_result) && zig_post_state == c_post_state`
     - Abort with minimal repro on mismatch (include snapshot context + input args)
   - Normal mode: just run `zig_<name>(args)` live (no snapshot overhead)
4. **Tests**: ERT battery (`test/src/<name>-channel-a-tests.el`) + Channel B corpus (`test/fidelity/corpus/NN-<name>.el`). ERT tests **MUST run under `ZIGMACS_AB=1`** to exercise snapshot→replay verification. Use `with-temp-buffer` to isolate state (each test starts fresh).
5. **Extending the snapshot**: for primitives that touch **multiple** pieces of state (e.g., a fn that moves point AND sets mark), expand the snapshot struct:
   ```c
   struct state_snapshot { ptrdiff_t pt; ptrdiff_t mark; ptrdiff_t begv; ptrdiff_t zv; };
   struct state_snapshot snapshot = { PT, PT_MARK(current_buffer), BEGV, ZV };
   // ... run_orig, capture, restore (SET_PT, SET_PT_MARK, ...), run_zig, compare
   ```
   For **text mutations** (insert/delete), snapshot = buffer contents (e.g., `buffer_text_copy = buffer_string()`); restore = replace full buffer. For **match-data**, snapshot via `Fmatch_data(Qnil, Qnil)`, restore via `Fset_match_data(...)`. See `goto-char` (point-only) as the simplest template.
6. **Channel B corpus**: since stateful fns mutate, each test case **must reset state** (use `with-temp-buffer` or explicit cleanup). The corpus script runs under the SAME oracle/port binary, so differential = (final state after same input sequence), NOT independent re-runs.
7. **Clean-build check** BEFORE push (stateful ports = new header dependencies).

### Cat D–G — Interpreter / buffer engine / GC / redisplay — _strategy, not per-function recipe_
_These are whole-subsystem rewrites (Phase 2), NOT fan-out-able as independent small ports. How-to will be a design/sequencing doc per ARCH.md §5, §7._

### Cat H — I/O · process · coding · compat ✅ H₁ recipe proven (`processp`, `file-name-absolute-p`, `coding-system-p`)
Spans many files (`process.c`/`fileio.c`/`coding.c`/…); splits into two sub-tiers:
- **H₁ (pure / low-OS)** — predicates (`processp`) port like Cat A; string/path logic (`file-name-absolute-p`) and multi-condition predicates (`coding-system-p`, which even calls Lisp `Fget` via a shim) port like Cat B. Shim per subsystem (`PROCESSP`, `SSDATA`, `CHECK_STRING`, `CODING_SYSTEM_ID`…) + subsystem headers. **Fan-out-able.**
- **H₂ (effectful)** — real file I/O, process spawn, network, global-state mutation. Test: *"touches the OS or mutates state beyond allocation?"* → H₂. Needs **Cat-C-style effect verification** (snapshot / subprocess A/B with output capture), not in-process assertion. NOT in the current fan-out.

## Dependency graph & port ordering

**Key enabler:** unported C stays callable (C-interop), so **runtime call-dependencies do NOT gate port order** — a ported Zig fn calls unported C and vice-versa. The graph is therefore sparse: mostly *tooling gates* + the Phase-2 subsystem sequence. Great for parallelism.

- **Substrate** (stays C, always callable): object model (tags / `Lisp_Object`), OS.
- **Foundation** (DONE): binding (extern + shim), Channel A dispatcher, fidelity harness + oracle, CI gates.

Port-order DAG (`→` = "depends on / port after"):

```
Foundation (done)
  ├─ A  pure predicates        → (nothing else)          ⟹ parallel NOW
  ├─ B  pure computational     → C allocator (C, ok)     ⟹ parallel NOW
  ├─ H₁ process/fileio/coding  → OS (C, ok)              ⟹ parallel NOW (independent)
  ├─ C  stateful primitives    → [snapshot→replay tool]  ⟹ parallel AFTER that tool
  ├─ D  interpreter/reader/VM  → object model + GC (C, ok); HIGH blast radius; VM monolithic
  └─ H₂ event loop (keyboard)  → D (command dispatch/eval)

Phase-2 monoliths (SEQUENCED, not fan-out):
   E buffer/text rope → [buffer-state fidelity surface ✓]; runs on the C GC
        → F GC (alloc.c)  [non-moving; ARCH §7; ordered after E]
             → G redisplay (xdisp) → E + window/frame + faces + H₂   (LAST)

Orthogonal gate: parallel fan-out → [build de-conflict: auto-glob Makefile, modular shim, worktrees + serialized merge]
Post-v0 gate:    doomemacs/modules → emacs-module ABI (H) + display parity (G)
```

**Reading it:**
- **No edges among A, B, H₁** → fully independent → the fan-out pool.
- **C** waits only on the one-time snapshot→replay tool.
- **D** (interpreter) and **F** (GC) are the high-blast-radius spines — port carefully / semi-sequentially, *not* fanned out.
- **E → F → G** is a hard sequence (ARCH §5): rope, then GC, then redisplay — Phase-2 monoliths, one focused effort each.
- **The v0 Doom-core gate is display-free** → it rides on the interpreter (D) + I/O (H) + primitives, **not** E/F/G. So the *hardest* categories are **post-v0** (interactive/module parity), not on the v0 critical path.

**Practical order:** (1) now, parallel after de-conflict: **A, B, H₁** (hundreds of independent leaf ports); (2) build **snapshot→replay** → unlock **C** (parallel); (3) **D** reader→eval→VM as a careful mostly-sequential track; (4) Phase-2 **E → F → G** as single gated efforts.

## Ported log
See `PORTING.md` for the per-function table. Cat A done: `natnump`, `nlistp`, `numberp`, `integerp`, `floatp`, `symbolp`, `stringp`, `consp`, `vectorp`, `listp`.

## Parallel fan-out — trial results (2026-10-16) & procedure
A 3-agent parallel trial (A/B/H₁, 3 ports each = 9) ran successfully. **What worked:**
- Native worktree-isolation isn't available here → use **manual `git worktree add`** (one branch per agent).
- **Auto-glob Makefile** (ports = `src/zig/*.zig`) → zero shared-Makefile edits → zero conflicts. ✓
- **Agents don't touch trackers** (orchestrator updates them at integration) → zero tracker conflicts. ✓
- Ports live in distinct files (A→`data.c`, B→`fns.c`, H→`process/fileio/coding.c`) + new `.zig`/test files → no cross-category conflict. ✓
- **The ONLY merge seam is the shared `src/zig/shim.{c,h}`.**

**What bit us:** a `merge=union` driver on `shim.c` is line-based, not syntax-aware — it dropped closing braces and nested the defs (build failed; fixed by hand). **Never union-merge C.** Fix: (a) manual union at integration, or better (b) **split the shim per category** (`shim-A.c`, …) or one-wrapper-per-port file so there's no shared shim to merge.

**Procedure (serialized integration):** manual worktrees → agents port + Channel-A-verify in-worktree (oracle isn't present there) → orchestrator: merge branches → rebuild/union the shim → clean build → **Channel B differential + `make check` gate** → update trackers → push → CI.

**Scope:** fan-out is for A / B / C / H₁ (per-function). D–G are monolithic subsystem rewrites — single sequenced efforts, not fan-out.
