# Zigmacs Porting Log

This document tracks all patches, workarounds, and findings from porting GNU Emacs 30.1 to build with `zig cc`.

## Phase 0: Establish `zig cc` Build

**Goal:** Make GNU Emacs 30.1 build cleanly with `zig cc 0.17.0`, pass tests, and run in CI.

### Build Environment

- **Base:** GNU Emacs 30.1 (official tarball, commit `8ac894e`)
- **Toolchain:** Zig 0.17.0 (public release, pinned in CI)
- **Compiler:** `CC="zig cc"`
- **Platform:** CentOS Stream 9 (GLIBC 2.34), x86_64 Linux (local); ubuntu-latest (CI)
- **Dependencies:** Via linuxbrew (gnutls 3.8.12, libxml2 2.13.8, tree-sitter 0.25.6, ncurses 6.6) on local; via apt on CI

### Configure Flags (Ground-Truth Match)

```bash
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
```

### Required Environment Variables

```bash
# PKG_CONFIG_PATH - to find linuxbrew dependencies
export PKG_CONFIG_PATH="/home/linuxbrew/.linuxbrew/lib/pkgconfig"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/home/linuxbrew/.linuxbrew/opt/gnutls/lib/pkgconfig"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/home/linuxbrew/.linuxbrew/opt/libxml2/lib/pkgconfig"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/home/linuxbrew/.linuxbrew/opt/tree-sitter/lib/pkgconfig"

# LDFLAGS/CPPFLAGS - for ncurses
export LDFLAGS="-L/home/linuxbrew/.linuxbrew/opt/ncurses/lib"
export CPPFLAGS="-I/home/linuxbrew/.linuxbrew/opt/ncurses/include"

# LD_LIBRARY_PATH - CRITICAL: system /usr/lib64 must come BEFORE brew paths
# This ensures the system libstdc++ (compatible with GLIBC 2.34) is used instead
# of brew's libstdc++ (which requires GLIBC 2.36+). Tree-sitter links against
# libstdc++, creating a transitive dependency.
export LD_LIBRARY_PATH="/usr/lib64:/home/linuxbrew/.linuxbrew/lib:$LD_LIBRARY_PATH"
```

### Source Code Patches

**NONE REQUIRED.** Emacs 30.1 builds with `zig cc 0.17.0` with zero source modifications.

### Build Warnings (Non-Fatal)

The following warnings are emitted by `zig cc` but do not prevent a successful build:

1. **`dispnew.c:3685:12`**: `variable 'changed_p' set but not used`
   - GCC doesn't warn on this; `zig cc` is stricter
   - No semantic impact; variable written but never read
   
2. **`json.c:326` and `fns.c:6084`**: `initializer-string for character array is too long`
   - Hex digit arrays declared as `char[16]` initialized with 17-char string literal (includes NUL)
   - `zig cc` suggests `nonstring` attribute
   - No runtime impact (NUL terminator is truncated)

3. **`keyboard.c:5418:19`**: `no previous extern declaration for non-static variable 'lispy_function_keys'`
   - `zig cc` prefers explicit `extern` or `static` for file-scope variables
   - GCC accepts implicit extern
   - No linkage issue

These warnings reflect `zig cc`'s stricter diagnostics compared to GCC. They are **tracked but not fixed** in Phase 0, as the goal is a byte-compatible build. If any become errors in future Zig versions, they will be addressed minimally.

### Runtime Environment Fix (RESOLVED - Defect 3)

**Issue:** The linked `emacs` binary transitively depends on `libstdc++.so.6` (via `libtree-sitter.so`). Linuxbrew's `libstdc++` (from gcc 14.2.0) requires GLIBC 2.36+, but CentOS Stream 9 ships GLIBC 2.34. Previous workaround used `LD_LIBRARY_PATH=/usr/lib64:...` which:
- Polluted shell environment
- Broke child processes (gh, unzip, bwrap in tests)
- Propagated to all subprocesses

**Solution (IMPLEMENTED):** Use **rpath** in LDFLAGS at configure time:

```bash
export LDFLAGS="-L/home/linuxbrew/.linuxbrew/opt/ncurses/lib"
export LDFLAGS="$LDFLAGS -Wl,-rpath,/usr/lib64"
export LDFLAGS="$LDFLAGS -Wl,-rpath,/home/linuxbrew/.linuxbrew/lib"
```

Rpath embeds library search paths in the binary and does NOT propagate to child processes.

**Verification:**
```bash
# Check rpath
readelf -d src/emacs | grep RUNPATH

# Run without any env pollution
unset LD_LIBRARY_PATH
src/emacs --version  # works!
```

**Launcher:** `scripts/zigmacs` provides clean invocation
**Build script:** `scripts/build-with-rpath.sh` documents the process

**Status:** `RESOLVED`. No environment variables needed, child processes run cleanly.

### Build Artifacts

- **Binary:** `src/emacs` (dynamically linked)
- **PDump:** `src/emacs.pdmp` (portable dumper format, Emacs 27+ default)
- **Warnings:** 4 diagnostics (see above), all non-fatal

### Test Results

_(To be filled after `make check`)_

### Files Modified

**NONE.** All changes are environment/build-system level.

### Commit History

1. `279988e` - Add oracle build script for fidelity testing
2. `59b7979` - Add .gitignore for build artifacts
3. `b6d2fc3` - Vendor pristine GNU Emacs 30.1
4. `323d710` - Add initial architecture documentation

---

## Phase N Roadmap (Not Implemented)

Future phases will:
- Port individual C modules to Zig
- Replace autotools with `build.zig`
- Establish fidelity harness comparing zig-emacs to gcc-oracle

See `ARCH.md` for the full incremental porting strategy.
