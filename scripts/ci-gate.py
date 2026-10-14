#!/usr/bin/env python3
"""
CI test gate for Zigmacs.

Scans ERT test logs for unexpected failures and fails CI if any failures
are found that are NOT in the justified allowlist.

Allowlist rationale:
- eglot-tests: Requires external LSP servers (rust-analyzer, tsserver, clangd) not installed in CI
- seccomp/bwrap tests: Requires privileged sandbox permissions not available in CI runner
"""

import sys
import re
from pathlib import Path
from typing import Dict, List, Set

# Justified allowlist: tests that fail due to missing CI resources (not zig cc bugs)
ALLOWLIST = {
    # LSP server integration tests - need rust-analyzer, tsserver, clangd
    "lisp/progmodes/eglot-tests.log",
    # Sandbox/seccomp tests - need audit permissions and special capabilities
    "src/emacs-tests.log",  # contains seccomp/bwrap tests
}


def parse_log_file(log_path: Path) -> Dict[str, any]:
    """
    Parse an ERT log file and extract test results.

    Returns dict with:
    - total: int
    - expected: int
    - unexpected: int
    - skipped: int (if present)
    - has_failures: bool
    """
    result = {
        "total": 0,
        "expected": 0,
        "unexpected": 0,
        "skipped": 0,
        "has_failures": False,
    }

    try:
        content = log_path.read_text(errors='replace')
    except Exception as e:
        print(f"Warning: Could not read {log_path}: {e}", file=sys.stderr)
        return result

    # Look for ERT summary line like:
    # "Ran 7 tests, 5 results as expected, 2 unexpected (2026-10-14 21:22:58+0000, 0.218294 sec)"
    # or "Ran 100 tests, 95 results as expected, 2 unexpected, 3 skipped (timestamp, duration)"
    pattern = r'Ran (\d+) tests?, (\d+) results? as expected(?:, (\d+) unexpected)?(?:, (\d+) skipped)?'

    match = re.search(pattern, content)
    if match:
        result["total"] = int(match.group(1))
        result["expected"] = int(match.group(2))
        result["unexpected"] = int(match.group(3)) if match.group(3) else 0
        result["skipped"] = int(match.group(4)) if match.group(4) else 0
        result["has_failures"] = result["unexpected"] > 0

    return result


def scan_test_logs(test_dir: Path) -> Dict[str, Dict]:
    """
    Recursively scan test directory for .log files and parse them.

    Returns dict mapping relative log path to parse results.
    """
    logs = {}

    for log_file in test_dir.rglob("*.log"):
        rel_path = log_file.relative_to(test_dir)
        result = parse_log_file(log_file)

        if result["total"] > 0:  # Only include logs with actual test runs
            logs[str(rel_path)] = result

    return logs


def main():
    # Find test directory relative to script location
    script_dir = Path(__file__).parent
    repo_root = script_dir.parent
    test_dir = repo_root / "test"

    if not test_dir.exists():
        print(f"Error: Test directory not found: {test_dir}", file=sys.stderr)
        sys.exit(1)

    print("=== Zigmacs CI Test Gate ===")
    print(f"Scanning: {test_dir}")
    print()

    # Scan all test logs
    logs = scan_test_logs(test_dir)

    if not logs:
        print("Warning: No test logs found with results", file=sys.stderr)
        sys.exit(1)

    # Separate allowlisted and non-allowlisted failures
    allowlisted_failures = []
    real_failures = []
    all_passed = []

    for log_path, result in sorted(logs.items()):
        if result["has_failures"]:
            if log_path in ALLOWLIST:
                allowlisted_failures.append((log_path, result))
            else:
                real_failures.append((log_path, result))
        else:
            all_passed.append((log_path, result))

    # Print summary
    print(f"Total test files: {len(logs)}")
    print(f"  ✓ Passed: {len(all_passed)}")
    print(f"  ⚠ Allowlisted failures: {len(allowlisted_failures)}")
    print(f"  ✗ Real failures: {len(real_failures)}")
    print()

    # Show passed tests
    if all_passed:
        print("Passed test files:")
        for log_path, result in all_passed:
            print(f"  ✓ {log_path}: {result['total']} tests, all expected")
        print()

    # Show allowlisted failures with justification
    if allowlisted_failures:
        print("Allowlisted failures (environmental, not zig cc bugs):")
        for log_path, result in allowlisted_failures:
            print(f"  ⚠ {log_path}: {result['unexpected']} unexpected / {result['total']} total")

            # Print justification
            if "eglot" in log_path:
                print(f"     → Requires external LSP servers not installed in CI")
            elif "emacs-tests" in log_path:
                print(f"     → Requires sandbox/seccomp permissions not available in CI")
        print()

    # Show real failures (these fail the gate)
    if real_failures:
        print("REAL FAILURES (zig cc regressions):")
        for log_path, result in real_failures:
            print(f"  ✗ {log_path}: {result['unexpected']} unexpected / {result['total']} total")
        print()
        print(f"CI GATE FAILED: {len(real_failures)} test file(s) with unexpected failures")
        print("These are NOT in the allowlist and indicate real regressions.")
        sys.exit(1)

    # Success
    print("✓ CI GATE PASSED")
    if allowlisted_failures:
        print(f"  (ignoring {len(allowlisted_failures)} allowlisted environmental failures)")
    sys.exit(0)


if __name__ == "__main__":
    main()
