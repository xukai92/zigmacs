# Proposed Addition to HARNESS.md §3: 3-Binary Triangulation

**Context**: This section would be inserted into HARNESS.md §3 ("The oracle") to
formalize the 3-binary strategy that isolates port bugs from compiler artifacts.

---

## Proposed §3.1: The 3-Binary Triangulation

To prove that any observed divergence is a **port bug** (incorrect Zig translation)
and not a **compiler artifact** (Zig-as-C-compiler changing semantics), we maintain
**three binaries** built from the exact vendored source at the pinned commit:

1. **`emacs-gcc`** — stock `gcc` build of the vendored C source  
   **Role**: Golden oracle. This is "ground truth" — the precise semantics we claim to port.

2. **`emacs-zigcc`** — `zig cc` build of the **same vendored C source** (zero ports)  
   **Role**: Compiler validation. Proves Zig-as-C-compiler is semantically faithful to gcc.

3. **`zigmacs`** — `zig cc` build with **Zig ports** incrementally replacing C functions  
   **Role**: The actual port under test.

### The Standing Invariant

At all times, the following must hold:

```
emacs-zigcc ≡ emacs-gcc
```

**Meaning**: A `zig cc` build of unmodified upstream C must be behaviorally identical to
the `gcc` build across all observable surfaces (§4), modulo registered inherent
nondeterminism (§6). Any divergence here is a **Zig toolchain bug** (or a build-config
issue), not a port problem — we halt and fix the toolchain/config, not the port.

### The Divergence Attribution Rule

When a test fails (Channel A or B), we compare **all three**:

| Comparison | Result | Interpretation |
|------------|--------|----------------|
| `zigmacs ≠ emacs-gcc` AND `zigmacs ≠ emacs-zigcc` AND `emacs-zigcc ≡ emacs-gcc` | **Port bug** | The Zig port diverged. Fix the port. |
| `zigmacs ≠ emacs-gcc` AND `emacs-zigcc ≠ emacs-gcc` | **Compiler artifact** | `zig cc` itself changed semantics. Halt; fix toolchain or vendored source compatibility. |
| `zigmacs ≡ emacs-zigcc ≡ emacs-gcc` | **False positive** | Harness bug (flaky test, bad normalizer, etc.). Fix the test. |

This triangulation is **cheap** (three binaries, once per Emacs version bump) and
eliminates the confound: we can confidently say "this is a port bug" vs "this is a
compiler quirk."

### Build and Checksumming

All three binaries are built by `scripts/build-oracle.sh` (Phase 0):
- Same source tree, same configure flags, only `CC` differs (gcc vs `zig cc`)
- Each binary's SHA256 is recorded and cached in CI
- Rebuilt only on vendored Emacs version bumps; golden files regenerated under review

### Why This Matters

Without `emacs-zigcc`, a divergence in `zigmacs` could be:
1. A port bug (we translated wrong), OR
2. A Zig-as-C-compiler semantic difference (undefined behavior, ABI mismatch, etc.)

We cannot tell which without the control. With `emacs-zigcc`, **any `zigmacs` divergence
from `emacs-gcc` that does NOT also appear in `emacs-zigcc` is provably a port bug**,
because we've factored out the compiler variable.

This is critical for trust: we can definitively say "Zig ports are faithful" without
the nagging doubt of "…or is it just `zig cc` being weird?"

---

**Usage in CI**:
- Nightly: run full corpus against all three, assert `emacs-zigcc ≡ emacs-gcc`
- Per-PR: if `zigmacs` diverges, auto-compare to `emacs-zigcc` and tag the issue as
  "port-bug" vs "compiler-artifact" in the failure report

**Merge into HARNESS.md §3** after "The oracle binary is pinned and checksummed" paragraph.
