#!/bin/bash
# Build Zigmacs with rpath (no LD_LIBRARY_PATH pollution)
#
# This script builds Emacs with Zig cc and embeds rpath in the binary.
# RPATH is superior to LD_LIBRARY_PATH because:
# 1. It's baked into the binary (no env variable needed)
# 2. It does NOT propagate to child processes (fixes subprocess failures)
#
# Usage: ./scripts/build-with-rpath.sh

set -e

# Set up brew environment
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Configure pkg-config to find dependencies
export PKG_CONFIG_PATH="/home/linuxbrew/.linuxbrew/lib/pkgconfig"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/home/linuxbrew/.linuxbrew/opt/gnutls/lib/pkgconfig"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/home/linuxbrew/.linuxbrew/opt/libxml2/lib/pkgconfig"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/home/linuxbrew/.linuxbrew/opt/tree-sitter/lib/pkgconfig"

# LDFLAGS with rpath
# Priority: /usr/lib64 first (system libs), then brew libs
# Note: Zig doesn't use libstdc++, so we don't need gcc/current lib directory
export LDFLAGS="-L/home/linuxbrew/.linuxbrew/opt/ncurses/lib"
export LDFLAGS="$LDFLAGS -L/home/linuxbrew/.linuxbrew/opt/libxml2/lib"
export LDFLAGS="$LDFLAGS -L/home/linuxbrew/.linuxbrew/opt/gnutls/lib"
export LDFLAGS="$LDFLAGS -Wl,-rpath,/usr/lib64"
export LDFLAGS="$LDFLAGS -Wl,-rpath,/home/linuxbrew/.linuxbrew/lib"
export LDFLAGS="$LDFLAGS -Wl,-rpath,/home/linuxbrew/.linuxbrew/opt/ncurses/lib"
export LDFLAGS="$LDFLAGS -Wl,-rpath,/home/linuxbrew/.linuxbrew/opt/libxml2/lib"
export LDFLAGS="$LDFLAGS -Wl,-rpath,/home/linuxbrew/.linuxbrew/opt/gnutls/lib"

export CPPFLAGS="-I/home/linuxbrew/.linuxbrew/opt/ncurses/include"
export CC="/home/kai/.local/zig/0.17.0/zig cc"
export ZIG="/home/kai/.local/zig/0.17.0/zig"

# Prevent autotools re-runs
touch configure aclocal.m4

# Configure
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

# Build
make -j$(nproc) src

echo ""
echo "Build complete!"
echo "Binary: src/emacs"
echo "Launcher: scripts/zigmacs"
echo ""
echo "Verify rpath:"
readelf -d src/emacs | grep RUNPATH
echo ""
echo "Test (no LD_LIBRARY_PATH needed):"
unset LD_LIBRARY_PATH
src/emacs --version
