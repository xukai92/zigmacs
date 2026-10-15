# Zigmacs — Fidelity Harness Design

> Companion to `ARCH.md`. `ARCH.md` says *what* we build and in what order; this document
> defines the machinery that **proves** every ported function is bug-for-bug faithful to the
> GNU Emacs C it replaces — automatically, at every commit, operationally (not by inspection).
>
> If `ARCH.md` §2.2 ("Elisp semantics are sacred") is the law, this is the enforcement.

Status: **binding design**. Build is incremental (see §14). Decisions baked in:
dual differential channels (in-process A/B **and** cross-binary oracle); an **exact-match**
fidelity bar with an explicit, written **allowed-divergence registry**; byte-identical `.elc`
as the default byte-compile check.

---

## 1. Thesis

A port is "faithful" iff, for every input, its **observable behavior is identical** to the
vendored upstream Emacs — where "observable" is a *declared, enumerated* set of surfaces (§4)
and "identical" means byte-exact after a *registered, justified* normalization (§5–§6).

We prove this two independent ways (§7):

- **Channel A — in-process A/B:** keep the original C function compiled in alongside its Zig
  port and run both on the same live arguments, asserting equality. Pinpoints divergence to a
  function, works on random/fuzzed and real-workload inputs. *Uniquely enabled by the
  Zig-and-C-in-one-binary architecture (ARCH.md §3) — Remacs/emacs-ng never had this lever.*
- **Channel B — cross-binary oracle:** run the same program through a frozen pristine upstream
  binary and through `zigmacs`, and diff all surfaces. Catches *emergent* divergence (dispatch,
  dumping, GC, interaction) and validates the actual artifact a user runs.

Two channels with independent failure modes. A finding must be explainable by at least one; a
real regression usually trips both.

---

## 2. Principles (the harness contract)

1. **Exact observable equality is the default.** Every exception is an entry in the
   allowed-divergence registry (§6) with a rationale, a specific normalizer, and an owner.
2. **The oracle defines truth — including upstream bugs.** We reproduce Emacs's behavior, not
   our idea of correct behavior. "Bug-for-bug" is literal (ARCH.md §2.2).
3. **No function is "ported" without fidelity coverage.** Porting status in `PORTING.md` is
   gated on differential coverage (§10). Untested port = unported.
4. **Determinism is engineered, not hoped for** (§5). A wobbling oracle makes differential
   testing worthless.
5. **The harness never bends to make a port pass.** If a port diverges, the port is wrong —
   unless the divergence is a pre-registered, inherent nondeterminism. We do not add masks to
   silence real differences.
6. **Reuse upstream as test material.** Emacs's own ERT suite and its own `lisp/` tree are
   feeders (§8.3–§8.4). Deriving expectations from upstream avoids our own test bugs.
7. **Cheap tier blocks merge; heavy tier runs nightly** (§13). Fast feedback, deep coverage.

---

## 3. The oracle (ground truth)

- **Golden oracle = a stock-`gcc` build of the _exact vendored source_ at the pinned commit**,
  reproduced by `scripts/build-oracle.sh` (produced in Phase 0). *Not* the system/brew Emacs —
  the oracle's semantics must be, by construction, the precise base we claim to port.
- The oracle binary is **pinned and checksummed**; its hash is recorded and it is cached in CI.
  It is rebuilt only when we bump the vendored base, at which point golden files (§8.1) are
  regenerated under human review.
- The system/brew Emacs 30.1 is a **secondary sniff-test** only, never authoritative.
- The oracle and `zigmacs` must be built from the **same source revision** for any diff to be
  meaningful; CI enforces this (same vendored tree → both binaries).

### 3.1 The 3-binary triangulation

To prove any divergence is a **port bug** (wrong Zig translation) and not a **compiler artifact**
(`zig cc`-as-C-compiler changing semantics), we keep **three** binaries from the exact vendored
source at the pinned commit — differing only in `CC` and in whether Zig ports are present:

1. **`emacs-gcc`** — stock `gcc` build of the vendored C. *Role:* golden oracle (ground truth).
2. **`emacs-zigcc`** — `zig cc` build of the **same C, zero ports**. *Role:* compiler control.
3. **`zigmacs`** — `zig cc` build with Zig ports incrementally replacing C. *Role:* port under test.

**Standing invariant:** `emacs-zigcc ≡ emacs-gcc` across all surfaces (§4), modulo registered
inherent nondeterminism (§6). This is literally the Phase-0 gate; if it ever breaks, that is a
toolchain/build-config problem — **halt and fix the toolchain, never the port.**

**Attribution rule** when a test fails:

| Observation | Interpretation |
|---|---|
| `zigmacs ≠ emacs-gcc`, `zigmacs ≠ emacs-zigcc`, and `emacs-zigcc ≡ emacs-gcc` | **Port bug** — fix the port |
| `zigmacs ≠ emacs-gcc` **and** `emacs-zigcc ≠ emacs-gcc` | **Compiler artifact** — halt; fix toolchain/vendored-source compat |
| `zigmacs ≡ emacs-zigcc ≡ emacs-gcc` | **False positive** — harness bug (flaky test / bad normalizer); fix the test |

Note Channel A (§7.1) factors out the compiler on its own (original C and Zig port run in the
*same* `zig cc` binary), so triangulation is primarily what gives **Channel B** the same
blame-free attribution. All three are built by `scripts/build-oracle.sh`, SHA256-pinned and
CI-cached; rebuilt only on a vendored-base bump (golden files regenerated under review). Per-PR,
a `zigmacs` divergence is auto-compared against `emacs-zigcc` and tagged port-bug vs
compiler-artifact; nightly asserts `emacs-zigcc ≡ emacs-gcc` over the full corpus.

---

## 4. Observable surfaces (what "behavior" means)

We compare exactly these surfaces and no others. If behavior leaks outside them, that is a gap
to be closed by *adding a surface here*, deliberately — never by ignoring it.

- **(a) Return value** — via a canonical printer: `print-circle t`, `print-gensym t`,
  `print-length`/`print-level` nil, `print-quoted t`, float formatting pinned; `prin1-to-string`.
- **(b) Streams** — `standard-output` / `standard-error` captured verbatim.
- **(c) Nonlocal exits** — signaled errors captured as `(error-symbol . data)` and `throw`
  tags/values, via `condition-case`/`catch`, printed canonically. A port must signal the *same*
  condition with the *same* data, not merely "an error".
- **(d) Editing state** — a canonical buffer serialization: buffer text; **text properties**
  (full interval map); **markers** (position + insertion type); **overlays** (bounds + props);
  **narrowing** (`point-min`/`point-max`); point; mark; and a declared set of buffer-local vars.
  This surface is non-negotiable for the Phase-2 buffer/text engine (ARCH.md §5): a rope that
  changes any of these observably is a regression.
- **(e) Declared global side effects** — only where a primitive is *defined* to have them:
  `match-data`, obarray interning, `kill-ring`, and the specific global-var set the function
  touches. Enumerated per function in its test, not assumed globally.

Explicitly **out of scope as surfaces** (inherently nondeterministic; see §5): object
addresses, GC accounting (`garbage-collect` return, `memory-use-counts`), wall-clock time, PID.

---

## 5. Determinism control (the spine)

Differential testing is only as sound as the determinism of both sides. Both binaries run under
an identical **controlled batch preamble** and their outputs pass through an identical
**normalizer** before diff.

### 5.1 Nondeterminism sources and their handling

| Source | Handling |
|---|---|
| `random` | fixed seed in preamble: `(random "zigmacs-fixed-seed")` |
| `current-time`, `float-time`, `current-time-string`, "now" in `encode-time` | frozen via override in preamble; residual masked by normalizer |
| `gensym-counter`, uninterned print `#:gN` | counter reset per case; normalizer collapses `#:g[0-9]+` → `#:gN` |
| `#<…>` object-identity reps (windows, frames, some live objects) | normalizer masks numeric ids |
| hash-table / obarray / `mapatoms` iteration order | Emacs iterates insertion/bucket order *deterministically*; asserted equal between sides. A port that changes obarray/hash layout must preserve order or register a divergence |
| `emacs-pid`, `system-name`, `user-login-name`, `emacs-build-time`, `invocation-name`/`-directory`, `temporary-file-directory`, `process-environment` | pinned via preamble env + normalizers |
| filesystem paths / cwd | each case runs in a fresh sandboxed temp `HOME`/cwd; absolute paths normalized |
| GC-dependent output + timing | `gc-cons-threshold` raised during a case to avoid incidental GC; GC accounting excluded from surfaces (§4) |
| float formatting | same code path on both; pinned (`float-output-format`) anyway |
| locale / coding systems | `LC_ALL=C.UTF-8`; default coding systems pinned in preamble |

### 5.2 The preamble
A single `harness/preamble.el` loaded via `emacs -Q --batch -l harness/preamble.el`, pinning
everything in §5.1 so both binaries execute under byte-identical conditions.

### 5.3 The normalizer
An ordered list of `(regexp . replacement)` filters, **each tied to a registry entry (§6)**,
applied identically to both outputs. Normalization is symmetric by construction: the same filter
hits oracle and port, so it can hide a genuine difference only if it is written wrongly — which
§6 hygiene checks guard against.

---

## 6. The allowed-divergence registry

A machine-checkable file (`harness/divergences.toml`) enumerating every permitted deviation:

```
[[divergence]]
id          = "addr-window-id"
surface     = "a|b|c|d|e"
pattern     = "#<window [0-9]+"      # the normalizer this entry authorizes
category    = "inherent"             # inherent | scaffolding | (bug-for-bug is NOT a divergence)
rationale   = "window object ids are address-derived and non-semantic"
owner       = "…"
review_by   = ""                      # required for category=scaffolding
```

Rules enforced in CI:
- **Any un-normalized divergence not covered by a registry entry fails the build.** No silent masks.
- **Dead-mask hygiene:** a registry entry/normalizer that never fires over the full corpus is
  flagged (it may be hiding nothing — or hiding the wrong thing).
- **Categories:**
  - `inherent` — addresses, time, PID: permanent.
  - `scaffolding` — a temporary divergence from an in-progress port; **must** carry a tracking
    issue and a `review_by`. These are debt, counted and surfaced, never allowed to accumulate
    silently.
  - *bug-for-bug reproductions are **not** divergences* — we match upstream, including its bugs;
    noted in the test for clarity, not registered as a deviation.

---

## 7. The two differential channels

### 7.1 Channel A — in-process A/B (shadow execution)
- **Mechanism:** when C `Ffoo` is ported to Zig, the original C is retained compiled-in as
  `Ffoo__orig` (build-time rename/alias). Under `ZIGMACS_AB=1` (and a Lisp-visible flag), a
  dispatcher runs **both** on the same arguments and asserts equality over the declared surfaces
  (§4) *and* identical nonlocal-exit behavior (§4c). Mismatch → minimal repro logged + abort.
- **Stateful functions need snapshot–replay**, not naive double-call: snapshot the touched state
  (args + affected buffers/globals), run `Ffoo__orig` against clone‑1 and the Zig port against
  clone‑2, then compare *both the return values and the two resulting states*. The per-function
  test declares which state it touches (ties to §4e).
- **Modes:** (1) targeted unit tests; (2) property/fuzz (§8.2) with shrinking; (3) nightly
  *whole-workload shadow* — A/B every ported call made during a real session/corpus run
  (expensive, highest realism).
- **Retirement:** `__orig` retention is temporary. Once a function is fully trusted and the
  upstream C is removed, its A/B retires; recorded in `PORTING.md` (§10).

### 7.2 Channel B — cross-binary oracle diff
- Run an identical input program under the oracle (§3) and under `zigmacs`, both with the
  preamble (§5.2), normalize (§5.3), and diff every surface (§4).
- Shares input feeders (§8) with Channel A wherever possible.

### 7.3 Why both
Channel A pinpoints *which function* diverged, on live and random data, before a bug can hide in
aggregate. Channel B validates the *real shipped binary* and catches emergent/whole-system
divergence (dispatch, pdumper, GC interaction) that per-call A/B cannot see. Independent failure
modes; a real regression usually trips both.

---

## 8. Test feeders (the inputs)

### 8.1 Curated corpus
Hand-picked `.el` programs targeting semantics known to be subtle: `nil`/`()` duality, dotted
pairs & improper lists, bignum/fixnum overflow boundaries, float edge cases (NaN, ±inf, −0.0,
printing), text properties, markers with both insertion types, `narrow-to-region` +
`save-restriction`, dynamic vs lexical binding, `cl-lib`, `pcase`, regex corner cases,
unicode/coding-system round-trips, hash-tables, char-tables, `format`/`prin1` edge cases.
**Expected output is defined by the oracle**, captured as checked-in golden files; regeneration
is gated on human review (§3).

### 8.2 Property / fuzz per primitive
For each ported function, a typed argument generator (QuickCheck-style) over its domain,
including boundary values, compared via Channel A (and B where cheap). Generators are **keyed to
the function in `PORTING.md`**. Failures **shrink** to a minimal reproducer.

### 8.3 Real-code replay
Read + macroexpand + **byte-compile** over large real corpora — Emacs's own `lisp/` tree
(thousands of files), ERT's own sources, and later Doom's pinned packages — asserting
**byte-identical `.elc`** (§9) and no reader/macroexpand divergence. This is the cheapest
high-coverage signal and the closest proxy to the Doom gate (ARCH.md §6).

### 8.4 Reused upstream ERT (results-equality, not just green)
Run the full ERT suite under **both** oracle and `zigmacs` and compare the *result set*
(pass/fail/skip per test), not merely "is it green". A test the oracle skips but the port passes
(or vice versa) is flagged — the bar is "same results as upstream", a strictly stronger
condition than ARCH.md §2.3's "preserve green status".

---

## 9. Byte-compile fidelity (detail)

- **Default assertion: byte-identical `.elc`**, oracle vs port, across the §8.3 corpus. `.elc`
  is deterministic given (source, version), so this single check exercises the reader,
  macroexpander, `cconv`, `byte-opt`, and `byte-comp` together — and is essentially what Doom
  does to every package.
- **Floor:** behavior-identical. If a *legitimate* compiler-internal divergence is introduced
  (a non-observable change), register it (§6) and fall back to running the compiled code through
  the surfaces (§4) for that case. Byte-identical is the ceiling we hold by default; behavior-
  identical is the minimum we never drop below.
- **Self-stability:** compiling the same source twice must be bit-stable on both binaries.

---

## 10. Coverage & bookkeeping (couples to `PORTING.md`)

`PORTING.md` carries one row per function: `upstream C fn → Zig fn → status → fidelity coverage
(channels/feeders) → A/B retired?`. Enforced gates:

- A function may not be marked **ported** without (a) a Channel A property/A-B test **and**
  (b) membership in the passing corpus / real-code replay.
- CI emits a **coverage report**: for each coverage type, the % of ported functions covered, and
  an explicit list of any ported-but-uncovered functions (must be empty).
- Open `scaffolding` divergences (§6) are listed with their `review_by` so debt stays visible.

---

## 11. The Doom gates (Layer 4 — operational, from `ARCH.md` §6)

- **Phase-1 smoke gate:** a fixed set of real `.el` files read/macroexpanded/eval'd/byte-compiled,
  diffed vs oracle (a slice of §8.1/§8.3).
- **v0 gate (headline):** `bin/doom install && bin/doom sync && bin/doom doctor` all succeed, and
  `zigmacs` boots an interactive session with a **zero-module** `$DOOMDIR`.
- Harness provides: a **hermetic** Doom checkout pinned to a commit; a sandboxed `$HOME`/`$DOOMDIR`;
  `straight.el` package repos **pinned to commits and mirrored** for reproducibility (no live
  network in CI); and a headless interactive **boot-smoke** (pty/expect) asserting an error-free
  session.
- **Post-v0:** each enabled `doomemacs/modules` entry becomes a new gate — this is what forces
  redisplay parity and the `emacs-module.h` ABI (ARCH.md §4.3).

---

## 12. Performance harness (Layer 5 — from `ARCH.md` §8)

- Benchmarks: startup time; `doom sync` wallclock; redisplay on long lines; **GC pause
  distribution** (histogram, not mean); large-file open; JSON parse throughput; regex throughput.
- Every perf-claiming PR ships a **before/after** number, same machine, N reps, median + spread,
  **with the full fidelity suite green in the same PR** (no "faster but different").
- Perf is informational on PRs (noisy); **gated nightly** on a fixed runner; regressions beyond a
  threshold are flagged.

---

## 13. CI topology

- **Per-PR, blocking (fast tier):** `zig cc` build; ERT results-equality vs oracle (§8.4); curated
  corpus diff (§8.1); byte-identical over a fast `lisp/` slice (§9); Channel A unit/property tests
  for touched functions (§8.2); the active Doom gate (Phase-1 smoke now → v0 later) (§11);
  registry conformance (§6).
- **Nightly, heavy tier:** full `lisp/` real-code replay + byte-id (§8.3); extended fuzz with
  shrinking (§8.2); whole-workload shadow A/B (§7.1); perf benchmarks + delta tracking (§12);
  registry dead-mask hygiene (§6).
- Oracle binary and Zig toolchain are **pinned + checksummed + cached**. Doom and `straight`
  packages pinned to commits and mirrored (§11). On any failure, the **minimal repro** (input +
  both raw outputs + normalized diff) is uploaded as an artifact.

---

## 14. Implementation order (incremental)

**Now (while Phase 0 lands) — needs only two Emacs binaries, zero porting, so it can be
validated immediately against oracle-vs-brew:**
1. This document (committed).
2. `harness/preamble.el` (§5.2) + normalizer (§5.3) + `harness/divergences.toml` skeleton (§6).
3. The **surface serializer** in Elisp (§4) — works today on any Emacs.
4. **Channel B** diff runner (§7.2) + a seed curated corpus (§8.1) with golden capture.
5. Byte-identical replay (§9) over a `lisp/` slice.
6. ERT results-equality check (§8.4).

**Phase 1 start (first real ports):**
7. **Channel A** scaffolding: `__orig` retention, dispatcher, `ZIGMACS_AB` flag, snapshot–replay
   protocol (§7.1).
8. Per-function property generators (§8.2) as each function is ported.
9. `PORTING.md` coverage gate (§10); wire the fast tier into CI (§13).

**Phase 2+:**
10. Scale real-code replay to Doom packages; stand up the perf harness (§12); whole-workload
    shadow A/B.

---

## 15. Non-goals & cautions

- **Don't test our expectations instead of the oracle's behavior.** The oracle is truth,
  upstream bugs included.
- **Don't mask divergences silently.** Registry or fail (§6).
- **Don't gate PRs on noisy perf** (§12).
- **`--batch` does not certify display.** Batch differential explicitly does *not* validate
  `xdisp`; redisplay parity is covered by the boot-smoke and later module gates (§11).
- **We test observable behavior, not internal structure.** A port may use a rope where the oracle
  uses a gap buffer; equal observable surfaces (§4) is the entire bar (ARCH.md §8). Internal
  divergence is not just allowed — it is the whole point.
