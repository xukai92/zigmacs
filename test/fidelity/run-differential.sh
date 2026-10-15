#!/bin/bash
# Run complete differential test: gcc oracle vs zig-cc port
# This is the FIRST REAL DIFFERENTIAL per HARNESS.md §3.1

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

ORACLE="$PROJECT_ROOT/oracle/emacs-gcc"
PORT="$PROJECT_ROOT/src/emacs"
HARNESS_DIR="$SCRIPT_DIR"
CORPUS_DIR="$HARNESS_DIR/corpus"
LISP_SLICE="$HARNESS_DIR/lisp-slice"
RESULTS_DIR="$PROJECT_ROOT/test-results/differential-$(date +%Y%m%d-%H%M%S)"

mkdir -p "$RESULTS_DIR"

echo "=== Zigmacs Phase-1 Differential Test ==="
echo "Oracle (gcc):  $ORACLE"
echo "Port (zig-cc): $PORT"
echo "Results:       $RESULTS_DIR"
echo ""

# Verify binaries exist and work
echo "--- Verifying binaries ---"
"$ORACLE" --batch --eval '(princ emacs-version)' || { echo "Oracle binary failed!"; exit 1; }
echo " (oracle OK)"
"$PORT" --batch --eval '(princ emacs-version)' || { echo "Port binary failed!"; exit 1; }
echo " (port OK)"
echo ""

# Channel B: Run all corpus cases
echo "--- Channel B: Corpus (12 cases) ---"
for case in "$CORPUS_DIR"/*.el; do
    case_name=$(basename "$case")
    echo "Testing $case_name..."

    python3 "$HARNESS_DIR/channel-b.py" \
        --oracle "$ORACLE" \
        --port "$PORT" \
        --harness-dir "$HARNESS_DIR" \
        --input "$case" \
        --repro-dir "$RESULTS_DIR/repros-corpus" \
        2>&1 | tee -a "$RESULTS_DIR/channel-b-corpus.log"
done

echo ""
echo "--- Byte-compile replay: lisp-slice ---"
# Byte-compile replay over lisp slice
python3 "$HARNESS_DIR/byte-compile-replay.py" \
    --oracle "$ORACLE" \
    --port "$PORT" \
    --harness-dir "$HARNESS_DIR" \
    --input "$LISP_SLICE" \
    2>&1 | tee "$RESULTS_DIR/byte-compile-replay.log"

echo ""
echo "--- ERT comparison ---"
# ERT comparison (if we have a suitable subset)
# For now, just document that this needs a representative subset
echo "ERT comparison: TODO - needs representative subset selection"
echo "(Will run ert-compare.py once subset is defined)"

echo ""
echo "=== Differential complete ==="
echo "Results saved to: $RESULTS_DIR"
echo ""
echo "Summary:"
grep -E '(PASS|FAIL|divergence)' "$RESULTS_DIR"/*.log | sort | uniq -c || echo "No divergences found"
