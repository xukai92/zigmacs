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
| **Last updated** | 2026-10-16 — HEAD `9004569` |

## Progress by category

Surface ≈ **1,790 DEFUN primitives** total (~1,300 relevant to the nox build; ~400 are GUI backends, excluded). **DEFUN-count is a poor progress proxy** — most effort/risk is in a few huge subsystems (D–G), which are whole-engine rewrites, not per-function ports.

| Cat | What | Unit | Done / Total | Difficulty | Phase |
|---|---|---|---|---|---|
| **A** | Pure type predicates / `const` primitives | DEFUN | **10 / 25** | ★ trivial | 1 |
| **B** | Pure computational primitives (arith, list/seq/string builders) | DEFUN | 0 / ~230 *(est)* | ★★ easy-med | 1 |
| **C** | Stateful primitives (mutate buffer/point/match-data/globals) | DEFUN | 0 / ~260 *(est)* | ★★★ med | 1 |
| **D** | Interpreter & reader core (`eval`, `bytecode` VM, `lread`) | subsystem | 0 / ~75 DEFUN + 3 engines | ★★★★ hard | 1–2 |
| **E** | Buffer/text engine & search (`buffer`,`editfns`,`textprop`,`marker`,`insdel`,`search`,`regex`; ~21K LOC) | subsystem | 0 | ★★★★ hard | 2 |
| **F** | Garbage collector (`alloc.c`, 8.4K LOC) | subsystem | 0 | ★★★★★ very hard | 2 |
| **G** | Redisplay/terminal/windows (`xdisp` 38.6K, `dispnew`, `term`, `window`, `frame`; ~56K LOC) | subsystem | 0 | ★★★★★ hardest | 2+ |
| **H** | I/O · process · event-loop · coding · tree-sitter · module/native-comp compat | DEFUN+ | 0 / ~280 *(est)* | ★★★ med-hard | 1–3 |
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

### Cat B — Pure computational primitives — _how-to TBD (write after sampling)_
_Pure but real logic (loops, allocation). Channel A = value compare + property/fuzz over generated inputs. No state → no snapshot needed._

### Cat C — Stateful primitives — _how-to TBD (write after sampling)_
_Mutate buffers/globals/match-data. Channel A needs **snapshot→replay**: run `*_orig` and the Zig port on independent clones of the touched state, compare BOTH return values AND resulting state. This machinery is the key new infra before scaling C._

### Cat D–G — Interpreter / buffer engine / GC / redisplay — _strategy, not per-function recipe_
_These are whole-subsystem rewrites (Phase 2), NOT fan-out-able as independent small ports. How-to will be a design/sequencing doc per ARCH.md §5, §7._

### Cat H — I/O / process / compat — _how-to TBD (write after sampling)_

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

## Before parallel fan-out (prerequisites)
Parallel agents currently conflict on shared files (`data.c`, `Makefile.in`, `shim.c`, `lisp.h`, `PORTING.md`). Before fanning out:
- Make the Makefile obj-list **auto-glob** Zig ports (no shared line to edit per port).
- Make the shim **append-safe / modular** (per-category), pre-seed common accessors.
- Use **isolated git worktrees** per agent + a **serialized integration/merge** step (build + gate one at a time).
- Note: Cat D–G are subsystem rewrites — not part of the per-function fan-out.
