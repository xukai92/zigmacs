#!/bin/bash
# Build the fidelity oracle: pristine GNU Emacs 30.1 compiled with gcc
# This binary serves as the reference implementation for behavioral fidelity testing.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

# Clean previous build
if [ -f Makefile ]; then
    make distclean || true
fi

# Set up build environment
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

export PKG_CONFIG_PATH="/home/linuxbrew/.linuxbrew/lib/pkgconfig"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/home/linuxbrew/.linuxbrew/opt/gnutls/lib/pkgconfig"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/home/linuxbrew/.linuxbrew/opt/libxml2/lib/pkgconfig"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/home/linuxbrew/.linuxbrew/opt/tree-sitter/lib/pkgconfig"

export LDFLAGS="-L/home/linuxbrew/.linuxbrew/opt/ncurses/lib"
export CPPFLAGS="-I/home/linuxbrew/.linuxbrew/opt/ncurses/include"

export LD_LIBRARY_PATH="/home/linuxbrew/.linuxbrew/lib:${LD_LIBRARY_PATH:-}"

# Configure with gcc (exact flags matching ground-truth Emacs 30.1)
./configure \
    --without-x \
    --with-gnutls \
    --with-xml2 \
    --with-modules \
    --without-ns \
    --without-imagemagick \
    --without-dbus \
    --without-selinux \
    --with-tree-sitter \
    --with-native-compilation=no

# Touch configure to prevent autogen re-runs
touch configure aclocal.m4

# Build just the emacs binary (skip docs to avoid makeinfo requirement)
make -j"$(nproc)" src

# Verify it works
echo "=== Oracle binary version ==="
export LD_LIBRARY_PATH="/home/linuxbrew/.linuxbrew/lib:${LD_LIBRARY_PATH:-}"
src/emacs --version

# Generate checksum
ORACLE_CHECKSUM=$(sha256sum src/emacs | awk '{print $1}')
echo "=== Oracle checksum ==="
echo "SHA256: $ORACLE_CHECKSUM"

# Copy oracle binary to a designated location
mkdir -p "$PROJECT_ROOT/oracle"
cp src/emacs "$PROJECT_ROOT/oracle/emacs-gcc"
cp src/emacs.pdmp "$PROJECT_ROOT/oracle/emacs-gcc.pdmp"
echo "$ORACLE_CHECKSUM" > "$PROJECT_ROOT/oracle/emacs-gcc.sha256"

echo "=== Oracle build complete ==="
echo "Binary: $PROJECT_ROOT/oracle/emacs-gcc"
echo "PDump:  $PROJECT_ROOT/oracle/emacs-gcc.pdmp"
echo "SHA256: $ORACLE_CHECKSUM"
