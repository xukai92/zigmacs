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

# Detect compiler: Use ORACLE_CC env var if set, else detect based on platform
# - CentOS/brew: system gcc with brew's libstdc++ (gcc-16 itself needs glibc 2.38+)
# - Ubuntu CI: system gcc (apt's libxml2/libstdc++ are compatible)
if [ -n "${ORACLE_CC:-}" ]; then
    CC="$ORACLE_CC"
else
    CC="gcc"
fi

echo "=== Building oracle with: $CC ==="
$CC --version | head -n1

# Set up build environment
if [ -d "/home/linuxbrew/.linuxbrew" ]; then
    # CentOS with Homebrew
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

    # Homebrew paths (CentOS)
    export PKG_CONFIG_PATH="/home/linuxbrew/.linuxbrew/lib/pkgconfig"
    export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/home/linuxbrew/.linuxbrew/opt/gnutls/lib/pkgconfig"
    export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/home/linuxbrew/.linuxbrew/opt/libxml2/lib/pkgconfig"
    export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/home/linuxbrew/.linuxbrew/opt/tree-sitter/lib/pkgconfig"

    # LDFLAGS with rpath (mirrors build-with-rpath.sh for feature parity)
    # Strategy: Add gcc lib to -L for link-time (so icu4c symbols resolve),
    # but put /usr/lib64 FIRST in rpath so runtime uses system libxml2 (not brew's)
    export LDFLAGS="-L/home/linuxbrew/.linuxbrew/opt/ncurses/lib"
    export LDFLAGS="$LDFLAGS -L/home/linuxbrew/.linuxbrew/opt/nettle/lib"
    export LDFLAGS="$LDFLAGS -L/home/linuxbrew/.linuxbrew/opt/gnutls/lib"
    export LDFLAGS="$LDFLAGS -L/home/linuxbrew/.linuxbrew/opt/libxml2/lib"
    export LDFLAGS="$LDFLAGS -L/home/linuxbrew/.linuxbrew/lib/gcc/current"
    export LDFLAGS="$LDFLAGS -Wl,-rpath,/usr/lib64"
    export LDFLAGS="$LDFLAGS -Wl,-rpath,/home/linuxbrew/.linuxbrew/lib"
    export LDFLAGS="$LDFLAGS -Wl,-rpath,/home/linuxbrew/.linuxbrew/opt/ncurses/lib"
    export LDFLAGS="$LDFLAGS -Wl,-rpath,/home/linuxbrew/.linuxbrew/opt/libxml2/lib"
    export LDFLAGS="$LDFLAGS -Wl,-rpath,/home/linuxbrew/.linuxbrew/opt/gnutls/lib"
    export CPPFLAGS="-I/home/linuxbrew/.linuxbrew/opt/ncurses/include"

    # Explicitly link hogweed/nettle (gcc doesn't pull them transitively from gnutls)
    export LIBS="-lhogweed -lnettle"

    echo "=== Using Homebrew environment (CentOS) ==="
else
    # Ubuntu CI: use system packages with standard paths
    # apt provides gnutls/libxml2/tree-sitter/ncurses/nettle with pkg-config
    # No custom PKG_CONFIG_PATH needed - system default includes:
    #   /usr/lib/x86_64-linux-gnu/pkgconfig
    #   /usr/share/pkgconfig
    #   /usr/lib/pkgconfig

    # Clear any inherited brew-specific flags
    unset PKG_CONFIG_PATH
    unset LDFLAGS
    unset CPPFLAGS
    unset LIBS

    echo "=== Using system packages (Ubuntu) ==="
fi

export CC

# Provide zig for building zig_spike.o (needed even for oracle)
if [ -z "${ZIG:-}" ]; then
    if [ -x "/home/kai/.local/zig/0.17.0/zig" ]; then
        export ZIG="/home/kai/.local/zig/0.17.0/zig"
    elif command -v zig >/dev/null 2>&1; then
        export ZIG="zig"
    fi
fi

# Configure with gcc (exact flags matching zig-cc port)
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

# Create CHECKSUMS file (sha256sum -c compatible format)
cat > "$PROJECT_ROOT/oracle/CHECKSUMS" <<EOF
# Oracle binary checksums (gcc build of vendored GNU Emacs 30.1)
# Built: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
# Compiler: $($CC --version | head -n1)
# Configure flags: --without-x --with-gnutls --with-xml2 --with-modules --without-ns --without-imagemagick --without-dbus --without-selinux --with-tree-sitter --with-native-compilation=no

$ORACLE_CHECKSUM  emacs-gcc
$(sha256sum src/emacs.pdmp | awk '{print $1}')  emacs-gcc.pdmp
EOF

echo "=== Oracle build complete ==="
echo "Binary: $PROJECT_ROOT/oracle/emacs-gcc"
echo "PDump:  $PROJECT_ROOT/oracle/emacs-gcc.pdmp"
echo "SHA256: $ORACLE_CHECKSUM"
cat "$PROJECT_ROOT/oracle/CHECKSUMS"
