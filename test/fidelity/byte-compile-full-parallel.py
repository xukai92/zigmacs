#!/usr/bin/env python3
"""
Full-lisp/ byte-compile replay with parallelization.

Byte-compiles every .el under lisp/ with both oracle and port binaries,
compares for byte-identical .elc files, and investigates divergences.
"""

import argparse
import hashlib
import json
import multiprocessing as mp
import os
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path
from typing import Dict, List, Optional, Tuple


class ByteCompiler:
    """Parallel byte-compile runner."""

    def __init__(self, oracle_bin: str, port_bin: str, harness_dir: Path):
        self.oracle_bin = oracle_bin
        self.port_bin = port_bin
        self.harness_dir = harness_dir
        self.preamble = harness_dir / "preamble.el"

    def compile_file(self, binary: str, el_file: Path, work_dir: Path) -> Tuple[Optional[Path], str, int]:
        """
        Byte-compile el_file with binary.

        Returns (elc_path, stderr, exit_code).
        """
        # Compile script
        compile_script = f"""
(load "{self.preamble}")
(setq byte-compile-error-on-warn nil)
(batch-byte-compile)
"""
        script_file = work_dir / "compile.el"
        script_file.write_text(compile_script)

        # Copy source to work dir (handle various encodings)
        src_copy = work_dir / el_file.name
        try:
            src_copy.write_bytes(el_file.read_bytes())
        except Exception as e:
            return None, f"Failed to copy source: {e}", -1

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

    def file_hash(self, path: Optional[Path]) -> str:
        """Compute SHA256 hash of file."""
        if not path or not path.exists():
            return "NONE"
        return hashlib.sha256(path.read_bytes()).hexdigest()

    def compare_single_file(self, el_file: Path) -> Dict:
        """
        Compile el_file with both binaries and compare .elc files.

        Returns result dict.
        """
        oracle_work = Path(tempfile.mkdtemp(prefix="oracle-"))
        port_work = Path(tempfile.mkdtemp(prefix="port-"))

        try:
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
                "oracle_stderr": oracle_stderr if not byte_identical else "",
                "port_stderr": port_stderr if not byte_identical else "",
            }

            return result

        finally:
            # Cleanup temp dirs
            shutil.rmtree(oracle_work, ignore_errors=True)
            shutil.rmtree(port_work, ignore_errors=True)


def worker_process(args_tuple):
    """Worker function for parallel processing."""
    oracle_bin, port_bin, harness_dir, el_file = args_tuple
    compiler = ByteCompiler(oracle_bin, port_bin, harness_dir)
    return compiler.compare_single_file(el_file)


def classify_divergence(result: Dict) -> str:
    """
    Classify a divergence as 'inherent' or 'real'.

    Inherent: timestamps, paths, etc. per divergences.toml
    Real: actual reader/compiler difference (a finding!)
    """
    # Check if both compiled successfully
    if result["oracle_exit"] != 0 or result["port_exit"] != 0:
        # Compilation failures should match between oracle and port
        if result["oracle_exit"] == result["port_exit"]:
            return "inherent-compile-failure"  # Both failed the same way
        else:
            return "REAL-compile-divergence"  # Different compile results!

    # If we got here, both compiled but produced different bytecode
    # This needs investigation - could be:
    # - Embedded timestamps in .elc (inherent)
    # - Embedded absolute paths (inherent)
    # - Actual semantic difference (REAL)

    # For now, mark for investigation
    return "needs-investigation"


def main():
    parser = argparse.ArgumentParser(
        description="Parallel byte-compile replay over full lisp/"
    )
    parser.add_argument("--oracle", required=True, help="Oracle Emacs binary")
    parser.add_argument("--port", required=True, help="Port Emacs binary")
    parser.add_argument("--harness-dir", required=True, help="Harness directory")
    parser.add_argument("--lisp-dir", required=True, help="lisp/ directory")
    parser.add_argument("--jobs", type=int, default=None,
                       help="Parallel jobs (default: CPU count)")
    parser.add_argument("--output", help="Output JSON file for results")
    args = parser.parse_args()

    harness_dir = Path(args.harness_dir)
    lisp_dir = Path(args.lisp_dir)

    if not lisp_dir.exists():
        print(f"Error: {lisp_dir} not found")
        return 1

    # Collect all .el files
    el_files = sorted(lisp_dir.glob("**/*.el"))

    # Filter out files that shouldn't be byte-compiled
    # (based on Emacs conventions)
    excluded_patterns = [
        "obsolete/",  # Obsolete files may not compile
        "ldefs-boot.el",  # Bootstrap file
    ]

    filtered_files = []
    for f in el_files:
        rel_path = str(f.relative_to(lisp_dir))
        if not any(excl in rel_path for excl in excluded_patterns):
            filtered_files.append(f)

    total = len(filtered_files)
    print(f"Full-lisp/ byte-compile replay")
    print(f"Oracle: {args.oracle}")
    print(f"Port: {args.port}")
    print(f"Files: {total} (filtered from {len(el_files)})")
    print(f"Cores: {args.jobs or mp.cpu_count()}")
    print("=" * 70)

    # Prepare worker arguments
    worker_args = [
        (args.oracle, args.port, harness_dir, el_file)
        for el_file in filtered_files
    ]

    # Run in parallel
    start_time = time.time()
    jobs = args.jobs or mp.cpu_count()

    with mp.Pool(processes=jobs) as pool:
        results = []
        # Use imap_unordered for progress tracking
        for i, result in enumerate(pool.imap_unordered(worker_process, worker_args), 1):
            results.append(result)
            if i % 50 == 0 or i == total:
                elapsed = time.time() - start_time
                rate = i / elapsed if elapsed > 0 else 0
                print(f"Progress: {i}/{total} ({100*i/total:.1f}%) - {rate:.1f} files/sec")

    elapsed = time.time() - start_time

    print("=" * 70)
    print(f"Completed in {elapsed:.1f}s ({total/elapsed:.1f} files/sec)")
    print()

    # Analyze results
    identical = [r for r in results if r["byte_identical"]]
    divergent = [r for r in results if not r["byte_identical"]]

    print(f"RESULTS:")
    print(f"  Total: {total}")
    print(f"  Byte-identical: {len(identical)} ({100*len(identical)/total:.1f}%)")
    print(f"  Divergent: {len(divergent)} ({100*len(divergent)/total:.1f}%)")
    print()

    if divergent:
        print(f"DIVERGENCE CLASSIFICATION:")
        print()

        # Classify each divergence
        classifications = {}
        for result in divergent:
            classification = classify_divergence(result)
            if classification not in classifications:
                classifications[classification] = []
            classifications[classification].append(result)

        for category, items in sorted(classifications.items()):
            print(f"{category}: {len(items)} files")
            for item in items[:5]:  # Show first 5
                rel_path = Path(item["file"]).relative_to(lisp_dir)
                print(f"  - {rel_path}")
                if item["oracle_exit"] != 0:
                    print(f"    Oracle exit: {item['oracle_exit']}")
                if item["port_exit"] != 0:
                    print(f"    Port exit: {item['port_exit']}")
            if len(items) > 5:
                print(f"  ... and {len(items) - 5} more")
            print()

    # Save detailed results
    if args.output:
        output_path = Path(args.output)
        output_data = {
            "summary": {
                "total": total,
                "identical": len(identical),
                "divergent": len(divergent),
                "elapsed_sec": elapsed,
            },
            "divergent_files": divergent,
        }
        output_path.write_text(json.dumps(output_data, indent=2))
        print(f"Detailed results saved to: {output_path}")

    # Exit code
    if divergent:
        print(f"\n⚠ {len(divergent)} divergent files require investigation")
        return 1
    else:
        print(f"\n✓ All {total} files are byte-identical")
        return 0


if __name__ == "__main__":
    sys.exit(main())
