// Port of Fchar_or_string_p from src/data.c:836
// Returns t if OBJECT is a character or string, nil otherwise
//
// Upstream C:
//   if (CHARACTERP (object) || STRINGP (object))
//     return Qt;
//   return Qnil;
//
// Behavior: bug-for-bug identical to upstream
// - Character (fixnum representing a character, ?a, ?\n, etc.) → Qt
// - String ("foo", "", etc.) → Qt
// - CRITICAL: characters are represented as fixnums in Emacs Lisp
// - Integer (non-character fixnum or bignum) → Qnil
// - Symbol, list, vector, etc. → Qnil
// - Pure function (const attribute, no side effects)

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declarations for shim functions (macro/inline API wrappers)
extern "c" fn zig_CHARACTERP(obj: Lisp_Object) bool;
extern "c" fn zig_STRINGP(obj: Lisp_Object) bool;
extern "c" fn zig_Qnil() Lisp_Object;
extern "c" fn zig_Qt() Lisp_Object;

// Export the Zig implementation as zig_char_or_string_p
// This will be called from the C dispatcher in data.c
export fn zig_char_or_string_p(object: Lisp_Object) Lisp_Object {
    // Match upstream logic exactly:
    // if (CHARACTERP (object) || STRINGP (object))
    //   return Qt;
    // return Qnil;

    if (zig_CHARACTERP(object) or zig_STRINGP(object)) {
        // Object is a character or string → return Qt
        return zig_Qt();
    } else {
        // Object is neither character nor string → return Qnil
        return zig_Qnil();
    }
}
