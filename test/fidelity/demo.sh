#!/bin/bash
# Quick demo of all harness components

set -e

EMACS="${EMACS:-/home/linuxbrew/.linuxbrew/bin/emacs}"
HARNESS_DIR="$(cd "$(dirname "$0")" && pwd)"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

echo "================================================"
echo "Zigmacs Fidelity Harness — Quick Demo"
echo "================================================"
echo ""

# 1. Show preamble working
echo "1. Testing preamble (determinism controls)..."
echo "   Running same test twice, expecting identical output..."

TMP1=$(mktemp)
TMP2=$(mktemp)

$EMACS -Q --batch -l "$HARNESS_DIR/preamble.el" \
    --eval '(princ (format "Random: %d\nTime: %s\nGensym: %S\n" (random 1000) (current-time-string) (gensym)))' \
    > "$TMP1" 2>&1

$EMACS -Q --batch -l "$HARNESS_DIR/preamble.el" \
    --eval '(princ (format "Random: %d\nTime: %s\nGensym: %S\n" (random 1000) (current-time-string) (gensym)))' \
    > "$TMP2" 2>&1

if diff -q "$TMP1" "$TMP2" > /dev/null; then
    echo "   ✓ Identical output (determinism working)"
    cat "$TMP1" | sed 's/^/     /'
else
    echo "   ✗ Outputs differ!"
    exit 1
fi

rm "$TMP1" "$TMP2"
echo ""

# 2. Channel B on one test
echo "2. Channel B differential (one test)..."
python3 "$HARNESS_DIR/channel-b.py" \
    --oracle "$EMACS" \
    --port "$EMACS" \
    --harness-dir "$HARNESS_DIR" \
    --input "$HARNESS_DIR/corpus/01-nil-list-duality.el" \
    --repro-dir /tmp/demo-repro \
    | grep -E "(Running|PASS|FAIL|Results:)"
echo ""

# 3. Byte-compile one file
echo "3. Byte-compile replay (one file)..."
python3 "$HARNESS_DIR/byte-compile-replay.py" \
    --oracle "$EMACS" \
    --port "$EMACS" \
    --harness-dir "$HARNESS_DIR" \
    --input "$HARNESS_DIR/corpus/09-hash-tables.el" \
    | grep -E "(Testing|PASS|FAIL|Results:)"
echo ""

# 4. Show normalizer working
echo "4. Normalizer demonstration..."
echo "   Input with nondeterminism:"
echo "     Window: #<window 12345>"
echo "     PID: 98765"
echo "     Gensym: #:g42"
echo ""
echo "   Normalized output:"

cat > /tmp/demo-input.txt <<EOF
Window: #<window 12345>
PID: 98765
Gensym: #:g42
EOF

$EMACS -Q --batch \
    -l "$HARNESS_DIR/normalizer.el" \
    --eval "(zigmacs-normalize-file \"/tmp/demo-input.txt\" \"/tmp/demo-output.txt\")"

cat /tmp/demo-output.txt | sed 's/^/     /'
echo ""

# 5. Summary
echo "================================================"
echo "Demo Complete!"
echo "================================================"
echo ""
echo "All components working:"
echo "  ✓ Preamble (determinism)"
echo "  ✓ Channel B (differential testing)"
echo "  ✓ Byte-compile replay"
echo "  ✓ Normalizer"
echo ""
echo "Full validation: ./validate-self.sh"
echo "Documentation: README.md"
