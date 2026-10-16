// Port of Ffile_name_absolute_p from src/fileio.c
// Returns t if FILENAME is an absolute file name
//
// Upstream C:
//   CHECK_STRING (filename);
//   return file_name_absolute_p (SSDATA (filename)) ? Qt : Qnil;
//
// Behavior: bug-for-bug identical to upstream
// - Absolute paths on Unix: start with `/` → t
// - Tilde-prefixed paths: `~`, `~/...`, `~user/...` → t
// - Relative paths: anything else → nil
// - Non-string: signals wrong-type-argument error via CHECK_STRING
// - Pure function aside from error signaling

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declarations for shim functions (macro/inline API wrappers)
extern "c" fn zig_CHECK_STRING(x: Lisp_Object) void;
extern "c" fn zig_SSDATA(string: Lisp_Object) [*:0]u8;
extern "c" fn zig_Qnil() Lisp_Object;
extern "c" fn zig_Qt() Lisp_Object;

// Extern declaration for C helper function from fileio.c
// This is the platform-specific implementation that handles:
//   - IS_ABSOLUTE_FILE_NAME (platform-specific absolute path check)
//   - Tilde expansion logic (~, ~/..., ~user/...)
extern "c" fn file_name_absolute_p(filename: [*:0]const u8) bool;

// Export the Zig implementation as zig_file_name_absolute_p
// This will be called from the C dispatcher in fileio.c
export fn zig_file_name_absolute_p(filename: Lisp_Object) Lisp_Object {
    // Match upstream logic exactly:
    // CHECK_STRING (filename);
    // return file_name_absolute_p (SSDATA (filename)) ? Qt : Qnil;

    // Validate filename is a string (signals error if not)
    zig_CHECK_STRING(filename);

    // Get C string data
    const c_filename = zig_SSDATA(filename);

    // Call C helper function to check if absolute
    if (file_name_absolute_p(c_filename)) {
        // Absolute file name → return Qt
        return zig_Qt();
    } else {
        // Relative file name → return Qnil
        return zig_Qnil();
    }
}
