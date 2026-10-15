#!/usr/bin/env python3
"""
ERT results-equality checker per HARNESS.md §8.4.

Run ERT suite under both oracle and port, compare result SET
(pass/fail/skip per test), not just overall green/red.
"""

import argparse
import json
import os
import re
import subprocess
import sys
from pathlib import Path
from typing import Dict, Set, Tuple


class ERTCompare:
    """ERT results comparison."""

    def __init__(self, oracle_bin: str, port_bin: str, harness_dir: Path):
        self.oracle_bin = oracle_bin
        self.port_bin = port_bin
        self.harness_dir = harness_dir
        self.preamble = harness_dir / "preamble.el"

    def run_ert(self, binary: str, test_file: Path) -> Tuple[Dict[str, str], str]:
        """
        Run ERT tests in test_file with binary.

        Returns (results_dict, stderr) where results_dict maps test-name -> status.
        Status is one of: 'passed', 'failed', 'skipped', 'error'.
        """
        # Create ERT runner script
        runner_script = f"""
(load "{self.preamble}")
(load "{test_file}")

;; Run all tests and collect results
(let ((results '()))
  (ert-run-tests-batch-and-exit
   (lambda ()
     ;; Custom reporter that captures results
     (dolist (test (ert-select-tests t t))
       (let* ((test-name (ert-test-name test))
              (result (ert-run-test test)))
         (push (cons test-name
                     (cond
                      ((ert-test-passed-p result) 'passed)
                      ((ert-test-failed-p result) 'failed)
                      ((ert-test-skipped-p result) 'skipped)
                      (t 'error)))
               results)))
     results)))
"""

        # Actually, ERT batch mode is complex. Let's use a simpler approach:
        # Run ERT and parse the output

        cmd = [
            binary,
            "-Q",
            "--batch",
            "-l", str(self.preamble),
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
                timeout=60
            )

            # Parse ERT output
            # ERT batch output format:
            # Running N tests...
            # Test test-name passed
            # Test test-name failed
            # etc.

            results = {}
            output = result.stdout + result.stderr

            # Parse test results
            for line in output.splitlines():
                # Match lines like: "   passed  1/10  test-name"
                match = re.match(r'\s*(passed|failed|skipped)\s+\d+/\d+\s+(.+)', line)
                if match:
                    status = match.group(1)
                    test_name = match.group(2).strip()
                    results[test_name] = status
                # Also match: "Test test-name backtrace:" (failed)
                elif "backtrace:" in line.lower():
                    match = re.match(r'Test\s+(\S+)\s+backtrace:', line)
                    if match:
                        test_name = match.group(1)
                        if test_name not in results:
                            results[test_name] = 'failed'

            return results, output

        except subprocess.TimeoutExpired:
            return {}, "TIMEOUT"
        except Exception as e:
            return {}, str(e)

    def compare_results(self, oracle_results: Dict[str, str],
                       port_results: Dict[str, str]) -> Tuple[bool, Dict]:
        """
        Compare ERT result sets.

        Returns (equal, diff_dict).
        """
        oracle_tests = set(oracle_results.keys())
        port_tests = set(port_results.keys())

        only_oracle = oracle_tests - port_tests
        only_port = port_tests - oracle_tests
        common = oracle_tests & port_tests

        status_diffs = []
        for test in sorted(common):
            if oracle_results[test] != port_results[test]:
                status_diffs.append({
                    "test": test,
                    "oracle": oracle_results[test],
                    "port": port_results[test]
                })

        diff = {
            "only_oracle": sorted(only_oracle),
            "only_port": sorted(only_port),
            "status_diffs": status_diffs
        }

        equal = (len(only_oracle) == 0 and len(only_port) == 0 and
                len(status_diffs) == 0)

        return equal, diff

    def run_test_file(self, test_file: Path) -> Dict:
        """Run ERT comparison on test file."""
        print(f"Running ERT comparison: {test_file.name}")

        oracle_results, oracle_output = self.run_ert(self.oracle_bin, test_file)
        port_results, port_output = self.run_ert(self.port_bin, test_file)

        print(f"  Oracle: {len(oracle_results)} tests")
        print(f"  Port: {len(port_results)} tests")

        equal, diff = self.compare_results(oracle_results, port_results)

        result = {
            "test_file": str(test_file),
            "equal": equal,
            "oracle_count": len(oracle_results),
            "port_count": len(port_results),
            "diff": diff,
            "oracle_results": oracle_results,
            "port_results": port_results
        }

        if equal:
            print(f"  PASS: identical results")
        else:
            print(f"  FAIL: results differ")
            if diff["only_oracle"]:
                print(f"    Only in oracle: {diff['only_oracle'][:3]}")
            if diff["only_port"]:
                print(f"    Only in port: {diff['only_port'][:3]}")
            if diff["status_diffs"]:
                print(f"    Status diffs: {len(diff['status_diffs'])}")
                for d in diff["status_diffs"][:3]:
                    print(f"      {d['test']}: {d['oracle']} -> {d['port']}")

        return result


def main():
    parser = argparse.ArgumentParser(description="ERT results-equality comparison")
    parser.add_argument("--oracle", required=True, help="Oracle Emacs binary")
    parser.add_argument("--port", required=True, help="Port Emacs binary")
    parser.add_argument("--harness-dir", required=True, help="Harness directory")
    parser.add_argument("--test-file", required=True, help="ERT test file")
    args = parser.parse_args()

    harness_dir = Path(args.harness_dir)
    test_file = Path(args.test_file)

    if not test_file.exists():
        print(f"Error: {test_file} not found")
        return 1

    print(f"ERT results-equality comparison")
    print(f"Oracle: {args.oracle}")
    print(f"Port: {args.port}")
    print(f"Test: {test_file}")
    print("=" * 60)

    checker = ERTCompare(args.oracle, args.port, harness_dir)
    result = checker.run_test_file(test_file)

    print("=" * 60)
    if result["equal"]:
        print("PASS: ERT results are identical")
        return 0
    else:
        print("FAIL: ERT results differ")
        return 1


if __name__ == "__main__":
    sys.exit(main())
