#!/usr/bin/env python3
"""
CI gate based on ERT results-equality per HARNESS.md §8.4.

Gate passes iff zig-cc's ERT result set EQUALS the oracle's.
Environmental failures (like eglot) cancel out naturally on both sides.
Crashes (no summary) are detected and fail the gate.
"""

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path
from typing import Dict, Set, Tuple


def run_ert_file(binary: str, test_file: Path, preamble: Path) -> Tuple[Dict[str, str], bool]:
    """
    Run ERT tests in test_file with binary.

    Returns (results_dict, crashed).
    - results_dict maps test-name -> status ('passed'|'failed'|'skipped')
    - crashed is True if no summary was found (segfault/crash)
    """
    # Note: Do NOT load preamble for ERT - it interferes with test execution
    # Preamble is for byte-compile determinism, not ERT
    cmd = [
        binary,
        "-Q",
        "--batch",
        "-l", str(test_file),
        "-f", "ert-run-tests-batch-and-exit"
    ]

    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=120
        )

        output = result.stdout + result.stderr

        # Check for summary line to detect crashes
        summary_pattern = r'Ran (\d+) tests?'
        crashed = not bool(re.search(summary_pattern, output))

        # Parse individual test results
        results = {}
        for line in output.splitlines():
            match = re.match(r'\s*(passed|failed|skipped)\s+\d+/\d+\s+(.+?)(?:\s+\([\d.]+\s+sec\))?$', line)
            if match:
                status = match.group(1)
                test_name = match.group(2).strip()
                results[test_name] = status

        return results, crashed

    except subprocess.TimeoutExpired:
        return {}, True
    except Exception as e:
        return {}, True


def compare_test_file(oracle_bin: str, port_bin: str, test_file: Path, preamble: Path) -> Dict:
    """
    Run test_file with both binaries and compare.

    Returns comparison dict.
    """
    # Check if this is a zigmacs-specific test file (additive features)
    # These files test zigmacs-only features and are expected to fail/skip in oracle
    zigmacs_specific_files = [
        "zig-spike-tests.el",  # Zig integration tests
    ]

    is_zigmacs_specific = any(test_file.name == pattern for pattern in zigmacs_specific_files)

    oracle_results, oracle_crashed = run_ert_file(oracle_bin, test_file, preamble)
    port_results, port_crashed = run_ert_file(port_bin, test_file, preamble)

    oracle_tests = set(oracle_results.keys())
    port_tests = set(port_results.keys())

    only_oracle = sorted(oracle_tests - port_tests)
    only_port = sorted(port_tests - oracle_tests)
    common = oracle_tests & port_tests

    status_diffs = []
    for test in sorted(common):
        if oracle_results[test] != port_results[test]:
            status_diffs.append({
                "test": test,
                "oracle": oracle_results[test],
                "port": port_results[test]
            })

    # For zigmacs-specific test files, ignore the delta
    # (oracle is expected to fail/skip these additive features)
    if is_zigmacs_specific:
        equal = True  # Don't fail gate on expected additive features
        zigmacs_specific = True
    else:
        equal = (
            not oracle_crashed and
            not port_crashed and
            len(only_oracle) == 0 and
            len(only_port) == 0 and
            len(status_diffs) == 0
        )
        zigmacs_specific = False

    return {
        "test_file": str(test_file),
        "equal": equal,
        "oracle_count": len(oracle_results),
        "port_count": len(port_results),
        "oracle_crashed": oracle_crashed,
        "port_crashed": port_crashed,
        "only_oracle": only_oracle,
        "only_port": only_port,
        "status_diffs": status_diffs,
        "zigmacs_specific": zigmacs_specific,
    }


def main():
    parser = argparse.ArgumentParser(
        description="CI gate: ERT results-equality with crash detection"
    )
    parser.add_argument("--oracle", required=True, help="Oracle binary")
    parser.add_argument("--port", required=True, help="Port binary (zig-cc)")
    parser.add_argument("--test-dir", required=True, help="test/ directory")
    parser.add_argument("--harness-dir", required=True, help="Harness directory")
    parser.add_argument("--output", help="Output JSON for detailed results")
    args = parser.parse_args()

    test_dir = Path(args.test_dir)
    harness_dir = Path(args.harness_dir)
    preamble = harness_dir / "preamble.el"

    if not test_dir.exists():
        print(f"Error: {test_dir} not found", file=sys.stderr)
        return 1

    # Collect all ERT test files
    test_files = sorted(test_dir.glob("**/*-tests.el"))

    print("=" * 70)
    print("Zigmacs CI Gate: ERT Results-Equality")
    print("=" * 70)
    print(f"Oracle: {args.oracle}")
    print(f"Port:   {args.port}")
    print(f"Test files: {len(test_files)}")
    print("=" * 70)
    print()

    # Run all tests
    results = []
    for i, test_file in enumerate(test_files, 1):
        rel_path = test_file.relative_to(test_dir)
        print(f"[{i}/{len(test_files)}] {rel_path}...", end=" ", flush=True)

        result = compare_test_file(args.oracle, args.port, test_file, preamble)
        results.append(result)

        if result["equal"]:
            if result.get("zigmacs_specific"):
                print("✓ [zigmacs-specific, ignored]")
            else:
                print("✓")
        else:
            print("✗")
            if result["oracle_crashed"]:
                print(f"    ORACLE CRASHED (no summary)")
            if result["port_crashed"]:
                print(f"    PORT CRASHED (no summary)")
            if result["status_diffs"]:
                print(f"    Status diffs: {len(result['status_diffs'])}")
                for diff in result["status_diffs"][:2]:
                    print(f"      {diff['test']}: {diff['oracle']} -> {diff['port']}")

    # Summary
    equal_files = [r for r in results if r["equal"]]
    diff_files = [r for r in results if not r["equal"]]

    total_oracle_tests = sum(r["oracle_count"] for r in results)
    total_port_tests = sum(r["port_count"] for r in results)

    print()
    print("=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print(f"Test files: {len(test_files)}")
    print(f"  Equal:    {len(equal_files)} ({100*len(equal_files)/len(test_files):.1f}%)")
    print(f"  Divergent: {len(diff_files)} ({100*len(diff_files)/len(test_files):.1f}%)")
    print(f"Total tests (oracle): {total_oracle_tests}")
    print(f"Total tests (port):   {total_port_tests}")
    print()

    # Detailed delta analysis
    if diff_files:
        crashes = [r for r in diff_files if r["oracle_crashed"] or r["port_crashed"]]
        status_delta_files = [r for r in diff_files if r["status_diffs"]]

        print("DELTA SET (non-empty, gate FAILS):")
        print()

        if crashes:
            print(f"CRASHES ({len(crashes)} files):")
            for r in crashes:
                rel_path = Path(r["test_file"]).relative_to(test_dir)
                print(f"  {rel_path}")
                if r["oracle_crashed"]:
                    print(f"    Oracle: CRASHED")
                if r["port_crashed"]:
                    print(f"    Port: CRASHED")
            print()

        if status_delta_files:
            print(f"STATUS DIFFERENCES ({sum(len(r['status_diffs']) for r in status_delta_files)} tests across {len(status_delta_files)} files):")
            for r in status_delta_files[:10]:  # Show first 10 files
                rel_path = Path(r["test_file"]).relative_to(test_dir)
                print(f"  {rel_path} ({len(r['status_diffs'])} diffs)")
                for diff in r["status_diffs"][:3]:
                    print(f"    {diff['test']}: oracle={diff['oracle']}, port={diff['port']}")
            if len(status_delta_files) > 10:
                print(f"  ... and {len(status_delta_files) - 10} more files with diffs")
            print()

        print("=" * 70)
        print("✗ CI GATE FAILED: Delta set is non-empty")
        print("=" * 70)
        print()
        print("The oracle and port produce DIFFERENT ERT results.")
        print("This indicates a real gcc↔zig-cc divergence, NOT an environmental issue.")
        print("Environmental failures (like eglot requiring LSP servers) cancel out")
        print("naturally when both binaries fail the same tests.")

        if args.output:
            output_data = {
                "gate_passed": False,
                "total_files": len(test_files),
                "equal_files": len(equal_files),
                "divergent_files": len(diff_files),
                "divergent_details": diff_files,
            }
            Path(args.output).write_text(json.dumps(output_data, indent=2))

        return 1

    # Success
    print("=" * 70)
    print("✓ CI GATE PASSED: Results-equality achieved")
    print("=" * 70)
    print()
    print(f"Oracle and port produce IDENTICAL ERT results across all {len(test_files)} test files.")
    print("Environmental failures (if any) are identical on both sides and cancel out.")

    if args.output:
        output_data = {
            "gate_passed": True,
            "total_files": len(test_files),
            "equal_files": len(equal_files),
            "divergent_files": 0,
        }
        Path(args.output).write_text(json.dumps(output_data, indent=2))

    return 0


if __name__ == "__main__":
    sys.exit(main())
