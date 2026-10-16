// Port of Ffile_name_directory from src/fileio.c
// Returns the directory component in file name FILENAME
//
// Upstream C logic:
//   1. CHECK_STRING (filename)
//   2. handler = Ffind_file_name_handler (filename, Qfile_name_directory)
//   3. if (!NILP (handler)):
//        handled_name = call2 (handler, Qfile_name_directory, filename)
//        if (STRINGP (handled_name)) return handled_name
//        else return Qnil
//   4. return file_name_directory (filename)
//
// Behavior: bug-for-bug identical to upstream
// - "/a/b/c.txt" → "/a/b/"
// - "/a/b/" → "/a/b/"
// - "noslash" → nil
// - "" → nil
// - "/" → "/"
// - "x/y" → "x/"
// - Multibyte strings: "/tmp/файл/x" → "/tmp/файл/"
// - File name handler support

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declarations for shim functions (macro/inline API wrappers)
extern "c" fn zig_CHECK_STRING(obj: Lisp_Object) void;
extern "c" fn zig_Ffind_file_name_handler(filename: Lisp_Object, operation: Lisp_Object) Lisp_Object;
extern "c" fn zig_NILP(obj: Lisp_Object) bool;
extern "c" fn zig_call2(func: Lisp_Object, arg1: Lisp_Object, arg2: Lisp_Object) Lisp_Object;
extern "c" fn zig_STRINGP(obj: Lisp_Object) bool;
extern "c" fn zig_Qfile_name_directory() Lisp_Object;
extern "c" fn zig_Qnil() Lisp_Object;

// Extern declaration for C shim wrapper of file_name_directory
// This is defined in shim.c and wraps the C file_name_directory function
extern "c" fn zig_file_name_directory(filename: Lisp_Object) Lisp_Object;

// Export the Zig implementation as zig_Ffile_name_directory
// This will be called from the C dispatcher in fileio.c
// Note: Different name to avoid clash with the C shim wrapper
export fn zig_Ffile_name_directory(filename: Lisp_Object) Lisp_Object {
    // 1. CHECK_STRING (filename)
    zig_CHECK_STRING(filename);

    // 2. Check for file name handler
    const handler = zig_Ffind_file_name_handler(filename, zig_Qfile_name_directory());

    // 3. If handler exists, delegate to it
    if (!zig_NILP(handler)) {
        const handled_name = zig_call2(handler, zig_Qfile_name_directory(), filename);
        if (zig_STRINGP(handled_name)) {
            return handled_name;
        }
        // Unlike file-name-nondirectory, this returns Qnil for non-string handler result
        return zig_Qnil();
    }

    // 4. No handler - call the C implementation via shim wrapper
    return zig_file_name_directory(filename);
}
