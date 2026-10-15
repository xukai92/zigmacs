#!/usr/bin/env python3
"""
Byte-compile replay per HARNESS.md §9.

Assert byte-identical .elc files between oracle and port across a corpus
of .el files.
"""

import argparse
import hashlib
import os
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Dict, List, Tuple


class ByteCompileReplay:
    """Byte-compile fidelity checker."""

    def __init__(self, oracle_bin: str, port_bin: str, harness_dir: Path):
        self.oracle_bin = oracle_bin
        self.port_bin = port_bin
        self.harness_dir = harness_dir
        self.preamble = harness_dir / "preamble.el"

    def compile_file(self, binary: str, el_file: Path, work_dir: Path) -> Tuple[Path, str, int]:
        """
        Byte-compile el_file with binary.

        Returns (elc_path, stderr, exit_code).
        """
        elc_file = work_dir / (el_file.stem + ".elc")

        # Compile script
        compile_script = f"""
(load "{self.preamble}")
(setq byte-compile-error-on-warn nil)
(batch-byte-compile)
"""
        script_file = work_dir / "compile.el"
        script_file.write_text(compile_script)

        # Copy source to work dir
        src_copy = work_dir / el_file.name
        src_copy.write_text(el_file.read_text())

        cmd = [
            binary,
            "-Q",
            "--batch",
            "-l", str(script_file),
            str(src_copy)
        ]

        env = os.environ.copy()
        env["LC_ALL"] = "C.UTF-8"

        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                cwd=work_dir,
                env=env,
                timeout=30
            )

            expected_elc = work_dir / (src_copy.stem + ".elc")
            if expected_elc.exists():
                return expected_elc, result.stderr, result.returncode
            else:
                return None, result.stderr, result.returncode

        except subprocess.TimeoutExpired:
            return None, "TIMEOUT", -1
        except Exception as e:
            return None, str(e), -1

    def file_hash(self, path: Path) -> str:
        """Compute SHA256 hash of file."""
        if not path or not path.exists():
            return "NONE"
        return hashlib.sha256(path.read_bytes()).hexdigest()

    def compare_bytecode(self, el_file: Path) -> Dict:
        """
        Compile el_file with both binaries and compare .elc files.

        Returns result dict.
        """
        print(f"Testing: {el_file.name}")

        oracle_work = Path(tempfile.mkdtemp(prefix="oracle-"))
        port_work = Path(tempfile.mkdtemp(prefix="port-"))

        # Compile with oracle
        oracle_elc, oracle_stderr, oracle_exit = self.compile_file(
            self.oracle_bin, el_file, oracle_work
        )

        # Compile with port
        port_elc, port_stderr, port_exit = self.compile_file(
            self.port_bin, el_file, port_work
        )

        # Compare
        oracle_hash = self.file_hash(oracle_elc)
        port_hash = self.file_hash(port_elc)

        byte_identical = (oracle_hash == port_hash and oracle_hash != "NONE")

        result = {
            "file": str(el_file),
            "byte_identical": byte_identical,
            "oracle_hash": oracle_hash,
            "port_hash": port_hash,
            "oracle_exit": oracle_exit,
            "port_exit": port_exit,
            "oracle_elc": str(oracle_elc) if oracle_elc else None,
            "port_elc": str(port_elc) if port_elc else None,
        }

        if byte_identical:
            print(f"  PASS: byte-identical")
        else:
            print(f"  FAIL: oracle={oracle_hash[:8]}, port={port_hash[:8]}")
            if oracle_exit != 0:
                print(f"    Oracle compile failed: {oracle_stderr[:100]}")
            if port_exit != 0:
                print(f"    Port compile failed: {port_stderr[:100]}")

        return result

    def run_corpus(self, el_files: List[Path]) -> List[Dict]:
        """Run byte-compile comparison on all files."""
        results = []
        for el_file in el_files:
            result = self.compare_bytecode(el_file)
            results.append(result)
        return results


def main():
    parser = argparse.ArgumentParser(description="Byte-compile replay")
    parser.add_argument("--oracle", required=True, help="Oracle Emacs binary")
    parser.add_argument("--port", required=True, help="Port Emacs binary")
    parser.add_argument("--harness-dir", required=True, help="Harness directory")
    parser.add_argument("--input", required=True, help="Input .el file or directory")
    args = parser.parse_args()

    harness_dir = Path(args.harness_dir)
    input_path = Path(args.input)

    # Collect input files
    if input_path.is_file() and input_path.suffix == ".el":
        el_files = [input_path]
    elif input_path.is_dir():
        el_files = sorted(input_path.glob("**/*.el"))
    else:
        print(f"Error: {input_path} is not a .el file or directory")
        return 1

    print(f"Byte-compile replay: {len(el_files)} files")
    print(f"Oracle: {args.oracle}")
    print(f"Port: {args.port}")
    print("=" * 60)

    runner = ByteCompileReplay(args.oracle, args.port, harness_dir)
    results = runner.run_corpus(el_files)

    # Summary
    passed = sum(1 for r in results if r["byte_identical"])
    total = len(results)

    print("=" * 60)
    print(f"Results: {passed}/{total} byte-identical")
    print("=" * 60)

    if passed < total:
        print(f"\n{total - passed} file(s) differ!")
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
