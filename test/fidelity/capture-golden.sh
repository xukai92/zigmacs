#!/bin/bash
# Capture golden outputs from oracle emacs for the curated corpus

set -e

EMACS="${1:-/home/linuxbrew/.linuxbrew/bin/emacs}"
HARNESS_DIR="$(cd "$(dirname "$0")" && pwd)"
CORPUS_DIR="$HARNESS_DIR/corpus"
GOLDEN_DIR="$HARNESS_DIR/golden"
PREAMBLE="$HARNESS_DIR/preamble.el"

echo "Capturing golden outputs with: $EMACS"
echo "Corpus: $CORPUS_DIR"
echo "Output: $GOLDEN_DIR"

mkdir -p "$GOLDEN_DIR"

export LC_ALL=C.UTF-8
export TZ=UTC

for test_file in "$CORPUS_DIR"/*.el; do
    test_name=$(basename "$test_file" .el)
    golden_file="$GOLDEN_DIR/${test_name}.golden"

    echo "Capturing: $test_name"

    # Run with preamble and capture output
    "$EMACS" -Q --batch -l "$PREAMBLE" -l "$test_file" > "$golden_file" 2>&1 || true

    echo "  -> $golden_file"
done

echo "Done! Captured $(ls -1 "$GOLDEN_DIR" | wc -l) golden files."
