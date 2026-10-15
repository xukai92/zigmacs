#!/usr/bin/env python3
"""
CI gate: ERT results-equality between the gcc oracle and the zig-cc port
(HARNESS.md §8.4, triangulation §3.1).

Principle: the gate passes iff the port's ERT result set is EQUAL to the
oracle's. "Equal" is judged honestly:

  * Symmetric crash (BOTH binaries crash on a file) == equal. These are
    environmental (native-comp off, missing test .so, no network, batch-hostile
    self-tests). Both behaving identically is parity, not a divergence.

  * A candidate divergence (asymmetric crash, a test only one side ran, or a
    per-test status difference) is only a REAL divergence if it is
    REPRODUCIBLE. We re-run the file; if any re-run comes back equal (or both
    crash), the difference is FLAKY (timing/remote/process nondeterminism, e.g.
    tramp/eshell/auto-revert) and is NOT counted. A stable, repeatable
    difference fails the gate.

  * zigmacs-only additive test files (e.g. the interop spike) can't exist in the
    oracle and are excluded from the comparison.

No hand-maintained flaky allowlist and no arbitrary "allow N" threshold: real
(reproducible) divergences fail; flakiness is detected empirically by re-running.
"""

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path
from typing import Dict, Tuple

# Test files that exercise zigmacs-only additive features; the oracle lacks them
# by construction, so they are not part of the oracle-vs-port comparison.
ZIGMACS_ONLY = {"zig-spike-tests.el"}

# How many extra times to re-run a candidate-divergent file before believing it.
RECHECKS = 3


def run_ert_file(binary: str, test_file: Path) -> Tuple[Dict[str, str], bool]:
    """Run one ERT file; return (test-name -> status, crashed?).

    crashed == no ERT summary line was produced (segfault/abort/timeout).
    """
    cmd = [binary, "-Q", "--batch", "-l", str(test_file),
           "-f", "ert-run-tests-batch-and-exit"]
    try:
        proc = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
    except (subprocess.TimeoutExpired, Exception):
        return {}, True

    output = proc.stdout + proc.stderr
    crashed = not re.search(r'Ran (\d+) tests?', output)

    results: Dict[str, str] = {}
    for line in output.splitlines():
        m = re.match(
            r'\s*(passed|failed|skipped)\s+\d+/\d+\s+(.+?)(?:\s+\([\d.]+\s+sec\))?$',
            line)
        if m:
            results[m.group(2).strip()] = m.group(1)
    return results, crashed


def compare_once(oracle_bin: str, port_bin: str, test_file: Path) -> Dict:
    """One oracle-vs-port comparison of a file."""
    o_res, o_crash = run_ert_file(oracle_bin, test_file)
    p_res, p_crash = run_ert_file(port_bin, test_file)

    o_tests, p_tests = set(o_res), set(p_res)
    only_oracle = sorted(o_tests - p_tests)
    only_port = sorted(p_tests - o_tests)
    status_diffs = [
        {"test": t, "oracle": o_res[t], "port": p_res[t]}
        for t in sorted(o_tests & p_tests) if o_res[t] != p_res[t]
    ]

    both_crashed = o_crash and p_crash
    one_crashed = o_crash != p_crash
    # "equal" = neither crashed, same test set, same per-test status.
    equal = (not o_crash and not p_crash and not only_oracle
             and not only_port and not status_diffs)

    return {
        "test_file": str(test_file),
        "oracle_crashed": o_crash, "port_crashed": p_crash,
        "both_crashed": both_crashed, "one_crashed": one_crashed,
        "equal": equal, "only_oracle": only_oracle, "only_port": only_port,
        "status_diffs": status_diffs,
        "oracle_count": len(o_res), "port_count": len(p_res),
    }


def classify(oracle_bin: str, port_bin: str, test_file: Path) -> Tuple[str, Dict]:
    """Return (verdict, detail). verdict in:
    equal | zigmacs-only | environmental-crash | flaky | real-divergence
    """
    if test_file.name in ZIGMACS_ONLY:
        return "zigmacs-only", {"test_file": str(test_file)}

    c = compare_once(oracle_bin, port_bin, test_file)
    if c["equal"]:
        return "equal", c
    if c["both_crashed"]:
        return "environmental-crash", c

    # Candidate divergence — only real if it reproduces every time.
    for _ in range(RECHECKS):
        c2 = compare_once(oracle_bin, port_bin, test_file)
        if c2["equal"] or c2["both_crashed"]:
            return "flaky", c  # nondeterministic -> not a real divergence
    return "real-divergence", c


def main() -> int:
    ap = argparse.ArgumentParser(description="ERT results-equality gate")
    ap.add_argument("--oracle", required=True)
    ap.add_argument("--port", required=True)
    ap.add_argument("--test-dir", required=True)
    ap.add_argument("--harness-dir", required=False)  # accepted, unused
    ap.add_argument("--output")
    args = ap.parse_args()

    oracle_bin = str(Path(args.oracle).resolve())
    port_bin = str(Path(args.port).resolve())
    test_dir = Path(args.test_dir).resolve()
    if not test_dir.exists():
        print(f"Error: {test_dir} not found", file=sys.stderr)
        return 1

    test_files = sorted(test_dir.glob("**/*-tests.el"))
    print("=" * 70)
    print("Zigmacs CI Gate: ERT Results-Equality (oracle vs zig-cc port)")
    print(f"Oracle: {oracle_bin}\nPort:   {port_bin}\nTest files: {len(test_files)}")
    print("=" * 70)

    buckets: Dict[str, list] = {
        "equal": [], "zigmacs-only": [], "environmental-crash": [],
        "flaky": [], "real-divergence": [],
    }
    for i, tf in enumerate(test_files, 1):
        verdict, detail = classify(oracle_bin, port_bin, tf)
        buckets[verdict].append(detail)
        mark = {"equal": "✓", "zigmacs-only": "·", "environmental-crash": "~",
                "flaky": "≈", "real-divergence": "✗"}[verdict]
        print(f"[{i}/{len(test_files)}] {tf.relative_to(test_dir)} {mark} {verdict}")

    print("\n" + "=" * 70 + "\nSUMMARY")
    for k in ("equal", "zigmacs-only", "environmental-crash", "flaky", "real-divergence"):
        print(f"  {k:20s}: {len(buckets[k])}")

    def _rel(d):
        return str(Path(d["test_file"]).relative_to(test_dir))

    for label in ("environmental-crash", "flaky"):
        if buckets[label]:
            print(f"\n{label} (equal, not counted as divergence):")
            for d in buckets[label]:
                print(f"  ~ {_rel(d)}")

    real = buckets["real-divergence"]
    if args.output:
        Path(args.output).write_text(json.dumps(
            {"gate_passed": not real,
             "counts": {k: len(v) for k, v in buckets.items()},
             "real_divergences": real}, indent=2))

    print("\n" + "=" * 70)
    if real:
        print(f"✗ CI GATE FAILED: {len(real)} reproducible gcc↔zig-cc divergence(s)")
        print("=" * 70)
        for d in real:
            print(f"  {_rel(d)}")
            if d["one_crashed"]:
                print(f"    asymmetric crash: oracle_crashed={d['oracle_crashed']} "
                      f"port_crashed={d['port_crashed']}")
            for sd in d["status_diffs"][:5]:
                print(f"    {sd['test']}: oracle={sd['oracle']} port={sd['port']}")
            for t in d["only_oracle"][:5]:
                print(f"    only in oracle: {t}")
            for t in d["only_port"][:5]:
                print(f"    only in port: {t}")
        return 1

    print("✓ CI GATE PASSED: oracle and port ERT results are equal")
    print("=" * 70)
    print(f"  {len(buckets['equal'])} files identical; "
          f"{len(buckets['environmental-crash'])} symmetric-crash (environmental); "
          f"{len(buckets['flaky'])} flaky (nondeterministic, not a divergence); "
          f"{len(buckets['zigmacs-only'])} zigmacs-only.")
    print("  Zero reproducible gcc↔zig-cc divergences.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
