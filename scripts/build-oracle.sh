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

# LDFLAGS with rpath (same as zig-cc build for clean env execution)
export LDFLAGS="-L/home/linuxbrew/.linuxbrew/opt/ncurses/lib"
export LDFLAGS="$LDFLAGS -L/home/linuxbrew/.linuxbrew/opt/nettle/lib"
export LDFLAGS="$LDFLAGS -L/home/linuxbrew/.linuxbrew/opt/gnutls/lib"
export LDFLAGS="$LDFLAGS -Wl,-rpath,/usr/lib64"
export LDFLAGS="$LDFLAGS -Wl,-rpath,/home/linuxbrew/.linuxbrew/lib"
export LDFLAGS="$LDFLAGS -Wl,-rpath,/home/linuxbrew/.linuxbrew/opt/nettle/lib"
export CPPFLAGS="-I/home/linuxbrew/.linuxbrew/opt/ncurses/include"

# Explicitly link hogweed/nettle (gcc doesn't pull them transitively from gnutls)
export LIBS="-lhogweed -lnettle"

# Set LD_LIBRARY_PATH for link-time symbol resolution (not needed at runtime due to rpath)
export LD_LIBRARY_PATH="/home/linuxbrew/.linuxbrew/lib:/home/linuxbrew/.linuxbrew/opt/nettle/lib"

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

# Verify it works (no LD_LIBRARY_PATH needed due to rpath)
echo "=== Oracle binary version ==="
src/emacs --version

# Generate checksum
ORACLE_CHECKSUM=$(sha256sum src/emacs | awk '{print $1}')
echo "=== Oracle checksum ==="
echo "SHA256: $ORACLE_CHECKSUM"

# Copy oracle binary and pdump to a designated location
mkdir -p "$PROJECT_ROOT/oracle"
cp src/emacs "$PROJECT_ROOT/oracle/emacs-gcc"
cp src/emacs.pdmp "$PROJECT_ROOT/oracle/emacs-gcc.pdmp"

# Create CHECKSUMS file with sha256 and build info
cat > "$PROJECT_ROOT/oracle/CHECKSUMS" <<EOF
# Oracle binary checksums (gcc build of vendored GNU Emacs 30.1)
# Built: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
# Compiler: $(gcc --version | head -n1)
# Configure flags: --without-x --with-gnutls --with-xml2 --with-modules --without-ns --without-imagemagick --without-dbus --without-selinux --with-tree-sitter --with-native-compilation=no

SHA256(emacs-gcc) = $ORACLE_CHECKSUM
SHA256(emacs-gcc.pdmp) = $(sha256sum src/emacs.pdmp | awk '{print $1}')
EOF

echo "=== Oracle build complete ==="
echo "Binary: $PROJECT_ROOT/oracle/emacs-gcc"
echo "PDump:  $PROJECT_ROOT/oracle/emacs-gcc.pdmp"
echo "SHA256: $ORACLE_CHECKSUM"
cat "$PROJECT_ROOT/oracle/CHECKSUMS"
