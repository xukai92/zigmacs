// Port of Fstringp from src/data.c:515
// Returns t if OBJECT is a string, nil otherwise
//
// Upstream C:
//   if (STRINGP (object))
//     return Qt;
//   return Qnil;
//
// Behavior: bug-for-bug identical to upstream
// - String ("s", "", "multi\nline", unibyte/multibyte) → Qt
// - Integer (fixnum, bignum, character) → Qnil
// - Float → Qnil
// - Symbol (t, nil, :keyword, 'foo, etc.) → Qnil
// - List, vector, etc. → Qnil
// - Pure function (const attribute, no side effects)

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declarations for shim functions (macro/inline API wrappers)
extern "c" fn zig_STRINGP(obj: Lisp_Object) bool;
extern "c" fn zig_Qnil() Lisp_Object;
extern "c" fn zig_Qt() Lisp_Object;

// Export the Zig implementation as zig_stringp
// This will be called from the C dispatcher in data.c
export fn zig_stringp(object: Lisp_Object) Lisp_Object {
    // Match upstream logic exactly:
    // if (STRINGP (object))
    //   return Qt;
    // return Qnil;

    if (zig_STRINGP(object)) {
        // Object is a string → return Qt
        return zig_Qt();
    } else {
        // Object is not a string → return Qnil
        return zig_Qnil();
    }
}
