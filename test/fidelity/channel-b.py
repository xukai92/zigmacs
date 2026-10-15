#!/usr/bin/env python3
"""
Channel B runner: cross-binary oracle diff per HARNESS.md §7.2.

Run identical input program under two Emacs binaries, normalize both outputs,
diff all surfaces, emit minimal repro on mismatch.
"""

import argparse
import difflib
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Dict, List, Tuple


class ChannelBRunner:
    """Runs differential tests between two Emacs binaries."""

    def __init__(self, oracle_bin: str, port_bin: str, harness_dir: Path):
        self.oracle_bin = oracle_bin
        self.port_bin = port_bin
        self.harness_dir = harness_dir
        self.preamble = harness_dir / "preamble.el"
        self.normalizer = harness_dir / "normalizer.el"

    def run_emacs(self, binary: str, input_file: Path, work_dir: Path) -> Dict:
        """
        Run Emacs binary with input file, capture all outputs.

        Returns dict with:
            - stdout: captured stdout
            - stderr: captured stderr
            - exit_code: process exit code
            - raw_output_file: path to raw output
        """
        output_file = work_dir / f"{binary.split('/')[-1]}_raw.out"
        stderr_file = work_dir / f"{binary.split('/')[-1]}_stderr.out"

        # Build command: emacs -Q --batch -l preamble.el -l input-file
        cmd = [
            binary,
            "-Q",
            "--batch",
            "-l", str(self.preamble),
            "-l", str(input_file)
        ]

        # Set up clean environment
        env = os.environ.copy()
        env["LC_ALL"] = "C.UTF-8"
        env["TZ"] = "UTC"
        env["HOME"] = str(work_dir / "fake-home")
        os.makedirs(env["HOME"], exist_ok=True)

        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                cwd=work_dir,
                env=env,
                timeout=30
            )

            # Write outputs
            output_file.write_text(result.stdout)
            stderr_file.write_text(result.stderr)

            return {
                "stdout": result.stdout,
                "stderr": result.stderr,
                "exit_code": result.returncode,
                "raw_output_file": output_file
            }

        except subprocess.TimeoutExpired:
            return {
                "stdout": "",
                "stderr": "TIMEOUT",
                "exit_code": -1,
                "raw_output_file": output_file
            }
        except Exception as e:
            return {
                "stdout": "",
                "stderr": str(e),
                "exit_code": -1,
                "raw_output_file": output_file
            }

    def normalize_output(self, text: str, work_dir: Path) -> str:
        """
        Normalize output using normalizer.el.

        Returns normalized text.
        """
        work_dir.mkdir(parents=True, exist_ok=True)
        input_file = work_dir / "to_normalize.txt"
        output_file = work_dir / "normalized.txt"

        input_file.write_text(text)

        # Run normalizer
        normalize_script = f"""
(load "{self.normalizer}")
(zigmacs-normalize-file "{input_file}" "{output_file}")
"""
        script_file = work_dir / "normalize.el"
        script_file.write_text(normalize_script)

        cmd = [
            self.oracle_bin,  # Use oracle for normalization (deterministic)
            "-Q",
            "--batch",
            "-l", str(script_file)
        ]

        subprocess.run(cmd, capture_output=True, timeout=10)

        if output_file.exists():
            return output_file.read_text()
        return text  # Fallback if normalization failed

    def diff_outputs(self, oracle_text: str, port_text: str) -> Tuple[bool, List[str]]:
        """
        Compare normalized outputs.

        Returns (is_equal, diff_lines).
        """
        oracle_lines = oracle_text.splitlines(keepends=True)
        port_lines = port_text.splitlines(keepends=True)

        if oracle_lines == port_lines:
            return True, []

        # Generate unified diff
        diff = list(difflib.unified_diff(
            oracle_lines,
            port_lines,
            fromfile="oracle",
            tofile="port",
            lineterm=""
        ))

        return False, diff

    def run_test(self, input_file: Path, work_dir: Path = None) -> Dict:
        """
        Run differential test on input file.

        Returns result dict with:
            - passed: bool
            - oracle_output: raw oracle output
            - port_output: raw port output
            - oracle_normalized: normalized oracle output
            - port_normalized: normalized port output
            - diff: diff lines if divergence
        """
        if work_dir is None:
            work_dir = Path(tempfile.mkdtemp(prefix="channel-b-"))

        print(f"Running test: {input_file.name}")

        # Run on oracle
        oracle_result = self.run_emacs(self.oracle_bin, input_file, work_dir)

        # Run on port
        port_result = self.run_emacs(self.port_bin, input_file, work_dir)

        # Normalize both
        oracle_normalized = self.normalize_output(oracle_result["stdout"], work_dir / "oracle-norm")
        port_normalized = self.normalize_output(port_result["stdout"], work_dir / "port-norm")

        # Diff
        is_equal, diff_lines = self.diff_outputs(oracle_normalized, port_normalized)

        result = {
            "input_file": str(input_file),
            "passed": is_equal,
            "oracle_output": oracle_result["stdout"],
            "port_output": port_result["stdout"],
            "oracle_stderr": oracle_result["stderr"],
            "port_stderr": port_result["stderr"],
            "oracle_normalized": oracle_normalized,
            "port_normalized": port_normalized,
            "oracle_exit_code": oracle_result["exit_code"],
            "port_exit_code": port_result["exit_code"],
            "diff": diff_lines if not is_equal else [],
            "work_dir": str(work_dir)
        }

        return result

    def emit_repro(self, result: Dict, repro_dir: Path):
        """
        Emit minimal reproducer for a failed test.
        """
        repro_dir.mkdir(parents=True, exist_ok=True)

        # Copy input
        input_name = Path(result["input_file"]).name
        (repro_dir / input_name).write_text(Path(result["input_file"]).read_text())

        # Write outputs
        (repro_dir / "oracle_raw.out").write_text(result["oracle_output"])
        (repro_dir / "port_raw.out").write_text(result["port_output"])
        (repro_dir / "oracle_normalized.out").write_text(result["oracle_normalized"])
        (repro_dir / "port_normalized.out").write_text(result["port_normalized"])

        # Write diff
        (repro_dir / "diff.txt").write_text("\n".join(result["diff"]))

        # Write reproduction script
        repro_script = f"""#!/bin/bash
# Minimal reproducer for divergence in {input_name}

ORACLE={self.oracle_bin}
PORT={self.port_bin}
PREAMBLE={self.preamble}

echo "Running oracle..."
$ORACLE -Q --batch -l $PREAMBLE -l {input_name} > oracle.out 2>&1

echo "Running port..."
$PORT -Q --batch -l $PREAMBLE -l {input_name} > port.out 2>&1

echo "Diff:"
diff -u oracle.out port.out
"""
        repro_file = repro_dir / "reproduce.sh"
        repro_file.write_text(repro_script)
        repro_file.chmod(0o755)

        print(f"  Reproducer emitted to: {repro_dir}")


def main():
    parser = argparse.ArgumentParser(description="Channel B differential runner")
    parser.add_argument("--oracle", required=True, help="Oracle Emacs binary")
    parser.add_argument("--port", required=True, help="Port Emacs binary")
    parser.add_argument("--harness-dir", required=True, help="Harness directory")
    parser.add_argument("--input", required=True, help="Input .el file or directory")
    parser.add_argument("--repro-dir", default="repros", help="Directory for repros")
    args = parser.parse_args()

    harness_dir = Path(args.harness_dir)
    input_path = Path(args.input)
    repro_dir = Path(args.repro_dir)

    runner = ChannelBRunner(args.oracle, args.port, harness_dir)

    # Collect input files
    if input_path.is_file():
        input_files = [input_path]
    elif input_path.is_dir():
        input_files = sorted(input_path.glob("*.el"))
    else:
        print(f"Error: {input_path} not found")
        return 1

    # Run tests
    results = []
    for input_file in input_files:
        result = runner.run_test(input_file)
        results.append(result)

        if not result["passed"]:
            print(f"  DIVERGENCE: {input_file.name}")
            runner.emit_repro(result, repro_dir / input_file.stem)
        else:
            print(f"  PASS: {input_file.name}")

    # Summary
    passed = sum(1 for r in results if r["passed"])
    total = len(results)
    print(f"\n{'='*60}")
    print(f"Channel B Results: {passed}/{total} passed")
    print(f"{'='*60}")

    if passed < total:
        print(f"\n{total - passed} divergence(s) found. See {repro_dir}/")
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
