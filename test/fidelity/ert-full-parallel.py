#!/usr/bin/env python3
"""
Full ERT suite results-equality checker per HARNESS.md §8.4.

Runs the COMPLETE ERT suite under both oracle and port binaries,
compares the result SET (pass/fail/skip per test), not just green status.
"""

import argparse
import json
import multiprocessing as mp
import os
import re
import subprocess
import sys
import time
from pathlib import Path
from typing import Dict, List, Set, Tuple


class ERTRunner:
    """Parallel ERT test runner."""

    def __init__(self, oracle_bin: str, port_bin: str, harness_dir: Path):
        self.oracle_bin = oracle_bin
        self.port_bin = port_bin
        self.harness_dir = harness_dir
        self.preamble = harness_dir / "preamble.el"

    def run_ert_file(self, binary: str, test_file: Path) -> Tuple[Dict[str, str], str, bool]:
        """
        Run ERT tests in test_file with binary.

        Returns (results_dict, full_output, crashed).
        - results_dict maps test-name -> status ('passed'|'failed'|'skipped')
        - full_output is the complete stdout+stderr
        - crashed is True if no summary was found (segfault/crash)
        """
        # Note: Do NOT load preamble for ERT - it interferes with test execution
        # For results-equality, we compare both binaries in the same natural environment
        cmd = [
            binary,
            "-Q",
            "--batch",
            "-l", str(test_file),
            "-f", "ert-run-tests-batch-and-exit"
        ]

        env = os.environ.copy()
        env["LC_ALL"] = "C.UTF-8"

        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                env=env,
                timeout=120
            )

            output = result.stdout + result.stderr

            # Parse ERT output
            results = {}
            crashed = True  # Assume crashed until we find summary

            # Look for summary line:
            # "Ran 123 tests, 120 results as expected, 3 unexpected (timestamp, duration)"
            summary_pattern = r'Ran (\d+) tests?'
            if re.search(summary_pattern, output):
                crashed = False  # Found summary, didn't crash

            # Parse individual test results
            # ERT batch format: "   passed  1/10  test-name (0.001 sec)"
            for line in output.splitlines():
                match = re.match(r'\s*(passed|failed|skipped)\s+\d+/\d+\s+(.+?)(?:\s+\([\d.]+\s+sec\))?$', line)
                if match:
                    status = match.group(1)
                    test_name = match.group(2).strip()
                    results[test_name] = status

                # Also catch "Test test-name backtrace:" for failures
                elif "backtrace:" in line.lower():
                    match = re.match(r'Test\s+(\S+)\s+backtrace:', line)
                    if match:
                        test_name = match.group(1)
                        if test_name not in results:
                            results[test_name] = 'failed'

            return results, output, crashed

        except subprocess.TimeoutExpired:
            return {}, "TIMEOUT", True
        except Exception as e:
            return {}, str(e), True


def worker_run_test_file(args_tuple):
    """Worker function for parallel ERT execution."""
    oracle_bin, port_bin, harness_dir, test_file = args_tuple
    runner = ERTRunner(oracle_bin, port_bin, harness_dir)

    # Check if this is a zigmacs-specific test file (additive features)
    zigmacs_specific_files = [
        "zig-spike-tests.el",  # Zig integration tests
    ]
    is_zigmacs_specific = any(test_file.name == pattern for pattern in zigmacs_specific_files)

    # Run with oracle
    oracle_results, oracle_output, oracle_crashed = runner.run_ert_file(
        oracle_bin, test_file
    )

    # Run with port
    port_results, port_output, port_crashed = runner.run_ert_file(
        port_bin, test_file
    )

    # Compare results
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
    if is_zigmacs_specific:
        equal = True  # Don't count as divergence
        zigmacs_specific = True
    else:
        equal = (len(only_oracle) == 0 and len(only_port) == 0 and
                len(status_diffs) == 0 and not oracle_crashed and not port_crashed)
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
        "oracle_results": oracle_results,
        "port_results": port_results,
        "zigmacs_specific": zigmacs_specific,
    }


def main():
    parser = argparse.ArgumentParser(
        description="Full ERT suite results-equality comparison"
    )
    parser.add_argument("--oracle", required=True, help="Oracle Emacs binary")
    parser.add_argument("--port", required=True, help="Port Emacs binary")
    parser.add_argument("--harness-dir", required=True, help="Harness directory")
    parser.add_argument("--test-dir", required=True, help="test/ directory")
    parser.add_argument("--jobs", type=int, default=None,
                       help="Parallel jobs (default: CPU count / 4)")
    parser.add_argument("--output", help="Output JSON file for results")
    args = parser.parse_args()

    harness_dir = Path(args.harness_dir)
    test_dir = Path(args.test_dir)

    if not test_dir.exists():
        print(f"Error: {test_dir} not found")
        return 1

    # Collect all ERT test files
    test_files = sorted(test_dir.glob("**/*-tests.el"))

    total = len(test_files)
    print(f"Full ERT suite results-equality comparison")
    print(f"Oracle: {args.oracle}")
    print(f"Port: {args.port}")
    print(f"Test files: {total}")

    # Use fewer jobs for ERT (each test runs multiple tests, more memory-intensive)
    jobs = args.jobs or max(1, mp.cpu_count() // 4)
    print(f"Parallel jobs: {jobs}")
    print("=" * 70)

    # Prepare worker arguments
    worker_args = [
        (args.oracle, args.port, harness_dir, test_file)
        for test_file in test_files
    ]

    # Run in parallel
    start_time = time.time()

    with mp.Pool(processes=jobs) as pool:
        results = []
        for i, result in enumerate(pool.imap_unordered(worker_run_test_file, worker_args), 1):
            results.append(result)
            rel_path = Path(result["test_file"]).relative_to(test_dir)
            status = "✓" if result["equal"] else "✗"
            oracle_info = f"{result['oracle_count']} tests"
            if result["oracle_crashed"]:
                oracle_info += " [CRASHED]"
            port_info = f"{result['port_count']} tests"
            if result["port_crashed"]:
                port_info += " [CRASHED]"

            zigmacs_note = " [zigmacs-specific, ignored]" if result.get("zigmacs_specific") else ""
            print(f"{status} [{i}/{total}] {rel_path}: oracle={oracle_info}, port={port_info}{zigmacs_note}")

            if not result["equal"]:
                if result["oracle_crashed"] or result["port_crashed"]:
                    print(f"    CRASH DETECTED")
                if result["status_diffs"]:
                    print(f"    Status diffs: {len(result['status_diffs'])}")
                    for diff in result["status_diffs"][:3]:
                        print(f"      {diff['test']}: {diff['oracle']} -> {diff['port']}")
                if result["only_oracle"]:
                    print(f"    Only oracle: {len(result['only_oracle'])} tests")
                if result["only_port"]:
                    print(f"    Only port: {len(result['only_port'])} tests")

    elapsed = time.time() - start_time

    print("=" * 70)
    print(f"Completed in {elapsed:.1f}s")
    print()

    # Analyze results
    equal_files = [r for r in results if r["equal"]]
    diff_files = [r for r in results if not r["equal"]]

    total_oracle_tests = sum(r["oracle_count"] for r in results)
    total_port_tests = sum(r["port_count"] for r in results)

    print(f"SUMMARY:")
    print(f"  Test files: {total}")
    print(f"  Equal results: {len(equal_files)} ({100*len(equal_files)/total:.1f}%)")
    print(f"  Divergent: {len(diff_files)} ({100*len(diff_files)/total:.1f}%)")
    print(f"  Total tests (oracle): {total_oracle_tests}")
    print(f"  Total tests (port): {total_port_tests}")
    print()

    if diff_files:
        print(f"DELTA SET (tests with different results):")
        print()

        # Collect all test-level deltas
        all_status_diffs = []
        crashes = []

        for file_result in diff_files:
            rel_path = Path(file_result["test_file"]).relative_to(test_dir)

            # Check for crashes
            if file_result["oracle_crashed"] or file_result["port_crashed"]:
                crashes.append({
                    "file": str(rel_path),
                    "oracle_crashed": file_result["oracle_crashed"],
                    "port_crashed": file_result["port_crashed"],
                })

            # Collect status diffs
            for diff in file_result["status_diffs"]:
                all_status_diffs.append({
                    "file": str(rel_path),
                    "test": diff["test"],
                    "oracle": diff["oracle"],
                    "port": diff["port"],
                })

        if crashes:
            print(f"CRASHES ({len(crashes)}):")
            for crash in crashes:
                print(f"  {crash['file']}")
                if crash["oracle_crashed"]:
                    print(f"    Oracle: CRASHED (no summary)")
                if crash["port_crashed"]:
                    print(f"    Port: CRASHED (no summary)")
            print()

        if all_status_diffs:
            print(f"STATUS DIFFERENCES ({len(all_status_diffs)} tests):")
            for diff in all_status_diffs[:20]:  # Show first 20
                print(f"  {diff['file']}::{diff['test']}")
                print(f"    Oracle: {diff['oracle']}, Port: {diff['port']}")
            if len(all_status_diffs) > 20:
                print(f"  ... and {len(all_status_diffs) - 20} more")
            print()

    # Save detailed results
    if args.output:
        output_path = Path(args.output)
        output_data = {
            "summary": {
                "total_files": total,
                "equal_files": len(equal_files),
                "divergent_files": len(diff_files),
                "total_oracle_tests": total_oracle_tests,
                "total_port_tests": total_port_tests,
                "elapsed_sec": elapsed,
            },
            "divergent_files": diff_files,
        }
        output_path.write_text(json.dumps(output_data, indent=2))
        print(f"Detailed results saved to: {output_path}")

    # Exit code
    if diff_files:
        print(f"\n⚠ DELTA SET IS NON-EMPTY: {len(diff_files)} test files have different results")
        return 1
    else:
        print(f"\n✓ ERT RESULTS-EQUALITY ACHIEVED: all {total} test files identical")
        return 0


if __name__ == "__main__":
    sys.exit(main())
