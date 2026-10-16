// Port of Fmultibyte_string_p from src/data.c:860
// Returns t if OBJECT is a multibyte string, nil otherwise
//
// Upstream C:
//   if (STRINGP (object) && STRING_MULTIBYTE (object))
//     return Qt;
//   return Qnil;
//
// Behavior: bug-for-bug identical to upstream
// - Multibyte string ("é", "日本語", etc.) → Qt
// - Unibyte string (ASCII-only, etc.) → Qnil
// - Non-string (integer, symbol, etc.) → Qnil
// - Pure function (const attribute, no side effects)

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declarations for shim functions (macro/inline API wrappers)
extern "c" fn zig_STRINGP(obj: Lisp_Object) bool;
extern "c" fn zig_STRING_MULTIBYTE(str: Lisp_Object) bool;
extern "c" fn zig_Qnil() Lisp_Object;
extern "c" fn zig_Qt() Lisp_Object;

// Export the Zig implementation as zig_multibyte_string_p
// This will be called from the C dispatcher in data.c
export fn zig_multibyte_string_p(object: Lisp_Object) Lisp_Object {
    // Match upstream logic exactly:
    // if (STRINGP (object) && STRING_MULTIBYTE (object))
    //   return Qt;
    // return Qnil;

    if (zig_STRINGP(object) and zig_STRING_MULTIBYTE(object)) {
        // Object is a multibyte string → return Qt
        return zig_Qt();
    } else {
        // Object is not a multibyte string (or not a string at all) → return Qnil
        return zig_Qnil();
    }
}
