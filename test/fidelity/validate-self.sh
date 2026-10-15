#!/bin/bash
# Validate harness with emacs 30.1 vs itself (ZERO divergence expected)

set -e

EMACS="${EMACS:-/home/linuxbrew/.linuxbrew/bin/emacs}"
HARNESS_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=========================================="
echo "Fidelity Harness Self-Validation"
echo "=========================================="
echo "Binary (oracle): $EMACS"
echo "Binary (port):   $EMACS (same - self-test)"
echo "Harness dir:     $HARNESS_DIR"
echo ""

# Ensure we have the right emacs
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Test 1: Channel B on curated corpus
echo "=========================================="
echo "Test 1: Channel B - Curated Corpus"
echo "=========================================="
python3 "$HARNESS_DIR/channel-b.py" \
    --oracle "$EMACS" \
    --port "$EMACS" \
    --harness-dir "$HARNESS_DIR" \
    --input "$HARNESS_DIR/corpus" \
    --repro-dir "$HARNESS_DIR/repros-self"

echo ""

# Test 2: Byte-compile replay on corpus
echo "=========================================="
echo "Test 2: Byte-Compile Replay - Corpus"
echo "=========================================="
python3 "$HARNESS_DIR/byte-compile-replay.py" \
    --oracle "$EMACS" \
    --port "$EMACS" \
    --harness-dir "$HARNESS_DIR" \
    --input "$HARNESS_DIR/corpus"

echo ""

# Test 3: Check if emacs source lisp files exist for a slice
if [ -d "/tmp/emacs-src/lisp" ]; then
    echo "=========================================="
    echo "Test 3: Byte-Compile Replay - lisp/ Slice"
    echo "=========================================="

    # Create a small slice
    SLICE_DIR="$HARNESS_DIR/lisp-slice"
    mkdir -p "$SLICE_DIR"

    # Copy a small selection of lisp files
    cp /tmp/emacs-src/lisp/subr.el "$SLICE_DIR/" 2>/dev/null || true
    cp /tmp/emacs-src/lisp/simple.el "$SLICE_DIR/" 2>/dev/null || true
    cp /tmp/emacs-src/lisp/files.el "$SLICE_DIR/" 2>/dev/null || true
    cp /tmp/emacs-src/lisp/emacs-lisp/byte-opt.el "$SLICE_DIR/" 2>/dev/null || true

    if [ "$(ls -1 "$SLICE_DIR"/*.el 2>/dev/null | wc -l)" -gt 0 ]; then
        python3 "$HARNESS_DIR/byte-compile-replay.py" \
            --oracle "$EMACS" \
            --port "$EMACS" \
            --harness-dir "$HARNESS_DIR" \
            --input "$SLICE_DIR"
        echo ""
    else
        echo "No lisp files found in /tmp/emacs-src/lisp, skipping slice test"
        echo ""
    fi
else
    echo "=========================================="
    echo "Test 3: Byte-Compile Replay - lisp/ Slice"
    echo "=========================================="
    echo "/tmp/emacs-src/lisp not found, skipping"
    echo ""
fi

echo "=========================================="
echo "Self-Validation Complete!"
echo "=========================================="
echo ""
echo "If all tests passed with ZERO divergence, the harness"
echo "determinism controls are working correctly."
