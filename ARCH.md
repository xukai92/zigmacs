# Zigmacs — Architecture & Porting Guide

> A performant **Zig rewrite of GNU Emacs** that is a **functional superset** of Emacs,
> with **Doom Emacs** (`doomemacs/core` first) as the first-class compatibility citizen.

This document is the contract for how Zigmacs is built. Read it fully before writing code.
The strategy is deliberate and non-obvious; deviating from it is how every prior attempt
(Remacs, emacs-ng) stalled.

---

## 1. The one-paragraph thesis

Zigmacs is **not a reimplementation of Emacs**. It is GNU Emacs with its C core ported to
Zig **incrementally, function by function**, keeping a fully working, bug-for-bug-compatible
editor at *every single commit*. Emacs's real Elisp interpreter is ported into the Zig core —
never rewritten from scratch. "Superset" means: everything Emacs does, identically, **plus**
new additive capabilities (a Wasm extension host, a first-class Clojure runtime, a modern
renderer) layered on top of a preserved, stable Elisp API. Performance comes from replacing
**subsystems** (buffer representation, GC, redisplay, native primitives, async I/O), never
from altering Elisp's observable semantics.

---

## 2. Non-negotiable principles

1. **Working editor at every commit.** Never a multi-week "it doesn't build/run" window.
   Unported C stays in the build via Zig's C interop and remains callable. If a change can't
   preserve a working editor, it must be split until it can.
2. **Elisp semantics are sacred.** The observable behavior of the Elisp API (functions,
   variables, hooks, advice, text properties, markers, buffer-local vars, dynamic binding,
   narrowing, `save-excursion`, etc.) must not change. Internals may change freely; the
   surface may not.
3. **Incremental port, not clean-room.** Port existing Emacs C to Zig. Do not reinvent the
   interpreter, reader, or object model. Preserve the existing test suite's green status.
4. **Doom is the compatibility oracle.** A change that breaks the current Doom compatibility
   gate is not done, regardless of how clean it looks.
5. **Superset features are additive and isolated.** Anything new (Clojure, Wasm, GPU) lives
   above the compatibility surface and must have **zero** effect on Elisp semantics or on a
   user who never opts in.
6. **Measure performance claims.** Every "faster" must come with a reproducible benchmark and
   a before/after number. No vibes.

---

## 3. Why Zig (and specifically not Rust)

The core difficulty of this port is the **half-migrated object graph**: during the port, the
Lisp heap is simultaneously touched by unported C (raw tagged pointers) and ported Zig. That
intermediate state must be expressible and sound.

- **Rust's borrow checker rejects exactly this intermediate state.** Self-referential,
  mutable, cyclic, GC-managed graphs shared across a C/Rust boundary are precisely what Rust
  makes hard. This is the wall Remacs (C→Rust) hit at the GC and `xdisp`.
- **Zig has no ownership model to fight** and `@cImport`s Emacs's existing C headers into the
  *same* build with no FFI/bindgen tax. A half-ported graph is "just pointers," exactly as it
  already is in C — so the port can proceed one function at a time.
- Zig also gives precise control over data layout and allocators (useful for a custom GC) and
  `zig cc` can act as a drop-in C compiler for the parts not yet ported.

The accepted trade-off: Zig does **not** give Rust's memory-safety guarantees. We accept this
because the alternative (Rust) makes the incremental superset strategy itself infeasible.

---

## 4. Layered architecture

Bottom to top. (An interactive version of this diagram exists; this is the authoritative text.)

### 4.0 Platform & build (Phase 0)
- **Zig build** — `zig cc` as the C compiler, then `zig build` orchestrating a single build
  graph over Zig + remaining C.
- **OS I/O · subprocess · filesystem** — async I/O, process management (git, ripgrep, etc.).
- **Terminal & GUI backends** — termcap terminal; GUI (pgtk/Wayland) later.

### 4.1 Core runtime — Zig ⟷ C, ported incrementally (Phases 1–2)
This is where Emacs's real Elisp lives.
- **Elisp interpreter + bytecode VM** (P1) — the actual Emacs interpreter, ported C→Zig.
- **Object model & Lisp types** (P1) — the canonical tagged-value representation.
- **Byte-compiler** (P1) — must compile real third-party package source (Doom builds packages).
- **Native primitives** (P1) — regex, JSON, arithmetic; early, measurable perf wins.
- **Event loop & command dispatch** (P1).
- **Buffer & text engine** (P2, hard) — introduce a rope while preserving text props/markers.
- **Garbage collector** (P2, hard) — reduce pause times; see §7 for the staged approach.
- **Redisplay engine** (P2, hard) — the `xdisp` replacement; minimal for v0, full parity later.
- **Remaining C (`@cImport`)** — shrinking set of unported subsystems, always callable.

### 4.2 Emacs compatibility surface (the superset contract)
- **Elisp API (stable surface)** — the contract packages depend on. Preserve exactly.
- **Dynamic module ABI (`emacs-module.h`)** — needed once `doomemacs/modules` arrives (later).
- **native-comp compatibility** — you need not implement gccemacs, but `(featurep
  'native-compile)`, `.eln` handling, and related code paths must report coherent state.

### 4.3 Doom Emacs — first compatibility citizen (the gate)
- **`doomemacs/core`** — early-init bootstrapper, `doom-lib`, module system, `bin/doom` CLI,
  `straight.el` package management. **This is the v0 target.**
- **`straight.el` package build** — clones + byte-compiles pinned packages.
- **User config (`$DOOMDIR`)** — kept empty (zero modules) for v0.
- **`doomemacs/modules`** — evil, vterm, tree-sitter, posframe, pdf-tools. **Later phase**;
  these force the display engine and the dynamic-module ABI to full parity.

### 4.4 Superset extension layer (Phase 3, additive — strictly post-v0)
- **Wasm host (WasmGC + component model)** — embedded engine exposing the core heap to guests.
- **Clojure / CLJS runtime** — ClojureScript-model (persistent data structures implemented
  over the core object model + GC, self-hosted, no JVM); first-class via the shared heap.
- **Sandboxed / untrusted modules** — isolated linear memory, capability-limited, marshalled.
- **GPU renderer · richer async** — optional performance/UX ceiling.

---

## 5. Build phases & definition of done

Each phase is gated. Do not advance until the gate passes.

### Phase 0 — Build under Zig
- **Do:** build **unmodified** GNU Emacs with `CC="zig cc"`; then introduce a `build.zig` that
  compiles the C sources and links the Emacs binary.
- **Gate:** resulting binary is behavior-identical to upstream; `make check` (ERT suite) fully
  green; starts interactively.
- **Why first:** establishes the always-working spine before anything is ported.

### Phase 1 — Leaf ports
- **Do:** port self-contained, hot, well-tested subsystems C→Zig one function at a time:
  start with primitives in e.g. `fns.c`, string/`json.c`, `regex-emacs.c`, selected `data.c`
  predicates. Keep C and Zig interoperating via `@cImport`.
- **Gate (every PR):** ERT suite green **and** the Phase-1 Doom smoke gate (see §6) still
  passes. Each perf-motivated port ships a benchmark delta.

### Phase 2 — Hard cores (in this order)
1. **Buffer & text engine** — gap buffer → rope, preserving `editfns.c`/`buffer.c` semantics,
   text properties (`textprop.c`), markers (`marker.c`), overlays, narrowing.
2. **Garbage collector** (`alloc.c`) — see §7.
3. **Redisplay** (`xdisp.c`) — minimal interactive parity for v0; full parity tracks modules.
- **Gate:** ERT green; full v0 Doom gate (§6) passes; documented benchmark wins; no semantic
  regressions in text-property / marker / narrowing tests.

### Phase 3 — Additive superset (post-v0 only)
- Wasm host, Clojure runtime, GPU renderer, deeper async. Must not alter Elisp semantics and
  must be inert for users who don't opt in.

---

## 6. Compatibility gates (Doom)

Compatibility is defined operationally, by running Doom — not by inspection.

- **Phase-1 smoke gate:** `emacs --batch` can read, macroexpand, eval, and byte-compile a
  small fixed set of real `.el` files without divergence from upstream Emacs output.
- **v0 gate (the headline milestone):**
  `bin/doom install && bin/doom sync && bin/doom doctor` all succeed, **and** Zigmacs boots an
  interactive session with a **zero-module** `$DOOMDIR`.
  - This is mostly display-free (batch), which is why `doomemacs/core` is the tractable first
    target. It still exercises: reader, macroexpansion, eval, byte-compilation of real
    packages, autoload generation, subprocess (git), and filesystem I/O.
- **Post-v0 gates:** progressively enable `doomemacs/modules` (start with `evil`, then a
  curated set), each addition becoming a new gate. This is what drives redisplay parity and
  the `emacs-module.h` ABI.

**The `doom sync` critical path** (what v0 must survive):
`bin/doom` (batch) → reader/eval of early-init + `doom-lib` + `packages.el` → `straight.el`
clones pinned repos → git subprocess + fs writes → byte-compile each package → package code
resolves against the stable Elisp API → **v0 gate**.

---

## 7. The garbage collector (read before touching `alloc.c`)

Emacs today uses a **non-moving, precise, mark-and-sweep** collector with tagged `Lisp_Object`
pointers (`USE_LSB_TAG`). Enormous amounts of C code — and every dynamic module — assume
**objects never move**.

Guidance:
- **Do not start with a moving/compacting collector.** A moving GC breaks the pointer-stability
  assumption that unported C and modules rely on, and would violate "working editor at every
  commit."
- **Stage it:** (1) port the existing mark-sweep to Zig faithfully; (2) reduce pause time with
  **incremental/generational marking that preserves pointer stability** (no movement); (3)
  only consider a moving young generation much later, behind a stable rooting abstraction, and
  only if benchmarks justify the risk.
- Preserve the `gc-cons-threshold` / `gc-cons-percentage` knobs' observable behavior — Doom's
  startup tuning depends on them (even if they become partly advisory).

---

## 8. Performance philosophy

- Wins come from **better data structures and subsystems**, not from changing how Elisp
  executes. The high-value targets: rope buffers (long lines, huge files), lower GC pause
  times, a modern redisplay path, native `regex`/`json` (LSP-heavy workloads), async I/O.
- **Do not try to beat interpreter speed by changing evaluation semantics.** Upstream
  native-compilation already captured most interpreter-speed gains, and chasing it risks
  compatibility for little return.
- Maintain a benchmark suite from Phase 1: startup time, `doom sync` time, redisplay on long
  lines, GC pause distribution, large-file open, JSON parse throughput. Track deltas per PR.

---

## 9. Non-goals / explicit "do nots"

- **Do not** reimplement Elisp, the reader, or the object model from scratch.
- **Do not** change observable Elisp semantics for performance or elegance.
- **Do not** introduce the Wasm/Clojure layer before the v0 Doom gate passes.
- **Do not** pursue a moving GC early (see §7).
- **Do not** drop platforms/features in a way that breaks Doom (this is a superset, not a
  minimalist fork like `rune`).
- **Do not** let the tree sit in a non-building or test-failing state between commits.

---

## 10. Repository & workflow conventions

- Vendor upstream GNU Emacs as the base (pin an exact version/commit; record it). Port in
  place so diffs against upstream stay legible.
- Prefer many small PRs, each: (a) keeps `make check` green, (b) keeps the current Doom gate
  green, (c) includes a benchmark number if it claims performance.
- Every ported function should have a short note mapping it to the upstream C function it
  replaces, so reviewers can check semantic equivalence.
- Keep a `PORTING.md` log of which C files/functions are ported vs. remaining `@cImport`.
- CI must run: build, full ERT suite, and the active Doom gate.

---

## 11. Key upstream source files (port targets, roughly by phase)

- **P1:** `fns.c`, `data.c`, `json.c`, `regex-emacs.c`, `lread.c` (reader), `eval.c`
  (evaluator), `bytecode.c` (VM), `editfns.c` (point/region primitives).
- **P2:** `buffer.c` + `textprop.c` + `marker.c` (buffer/text engine → rope),
  `alloc.c` (GC), `xdisp.c` + `dispnew.c` (redisplay).
- **Compatibility surface:** `emacs-module.c`/`emacs-module.h` (module ABI, later),
  `comp.c` (native-comp interop/shims).
- **Boot:** `emacs.c`, `startup.el`, `early-init` handling.

---

## 12. First concrete task (hand to the agent)

Execute **Phase 0** only. Do not port anything yet.
1. Vendor a specific GNU Emacs release; record the exact version/commit.
2. Get it to configure and build with `CC="zig cc"` (document every patch needed).
3. Run the full ERT suite (`make check`); get it green. Record any skips with justification.
4. Stand up CI that builds with `zig cc` and runs `make check`.
5. Produce a short report: what built cleanly, what needed patching, test status, and the
   proposed `build.zig` plan for replacing the autotools link step next.
Stop at the Phase 0 gate and report before proceeding.
