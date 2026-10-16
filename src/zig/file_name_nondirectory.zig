// Port of Ffile_name_nondirectory from src/fileio.c
// Returns file name FILENAME sans its directory
//
// Upstream C logic:
//   1. CHECK_STRING (filename)
//   2. handler = Ffind_file_name_handler (filename, Qfile_name_nondirectory)
//   3. if (!NILP (handler)):
//        handled_name = call2 (handler, Qfile_name_nondirectory, filename)
//        if (STRINGP (handled_name)) return handled_name
//        else error ("Invalid handler in `file-name-handler-alist'")
//   4. beg = SSDATA (filename); end = p = beg + SBYTES (filename)
//   5. while (p != beg && !IS_DIRECTORY_SEP (p[-1])) p--
//      (ignoring DOS_NT branch - POSIX build only)
//   6. return make_specified_string (p, -1, end - p, STRING_MULTIBYTE (filename))
//
// Behavior: bug-for-bug identical to upstream
// - "/a/b/c.txt" → "c.txt"
// - "noslash" → "noslash"
// - "/dir/" → ""
// - Multibyte strings preserved
// - File name handler support
// - Errors on invalid handler

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
extern "c" fn zig_error_invalid_file_handler() void;
extern "c" fn zig_SSDATA(str: Lisp_Object) [*c]u8;
extern "c" fn zig_SBYTES(str: Lisp_Object) isize;
extern "c" fn zig_IS_DIRECTORY_SEP(c: c_int) bool;
extern "c" fn zig_make_specified_string(contents: [*c]const u8, nchars: isize, nbytes: isize, multibyte: bool) Lisp_Object;
extern "c" fn zig_STRING_MULTIBYTE(str: Lisp_Object) bool;
extern "c" fn zig_Qfile_name_nondirectory() Lisp_Object;

// Export the Zig implementation as zig_file_name_nondirectory
// This will be called from the C dispatcher in fileio.c
export fn zig_file_name_nondirectory(filename: Lisp_Object) Lisp_Object {
    // 1. CHECK_STRING (filename)
    zig_CHECK_STRING(filename);

    // 2. Check for file name handler
    const handler = zig_Ffind_file_name_handler(filename, zig_Qfile_name_nondirectory());

    // 3. If handler exists, delegate to it
    if (!zig_NILP(handler)) {
        const handled_name = zig_call2(handler, zig_Qfile_name_nondirectory(), filename);
        if (zig_STRINGP(handled_name)) {
            return handled_name;
        }
        // Error: invalid handler
        zig_error_invalid_file_handler();
        // Note: zig_error_invalid_file_handler doesn't return, but Zig doesn't know that
        // Return unreachable to satisfy type checker (dead code)
        unreachable;
    }

    // 4. No handler - process normally
    const beg: [*c]u8 = zig_SSDATA(filename);
    const end: [*c]u8 = beg + @as(usize, @intCast(zig_SBYTES(filename)));
    var p: [*c]u8 = end;

    // 5. Walk backward to find last directory separator
    // while (p != beg && !IS_DIRECTORY_SEP (p[-1])) p--
    // (Skip DOS_NT branch - POSIX build only)
    while (p != beg) {
        // Check character before p (p[-1])
        const prev_char = (p - 1)[0];
        if (zig_IS_DIRECTORY_SEP(@as(c_int, @intCast(prev_char)))) {
            break;
        }
        p -= 1;
    }

    // 6. Return substring from p to end
    const nbytes: isize = @intCast(@intFromPtr(end) - @intFromPtr(p));
    const multibyte = zig_STRING_MULTIBYTE(filename);
    return zig_make_specified_string(p, -1, nbytes, multibyte);
}
