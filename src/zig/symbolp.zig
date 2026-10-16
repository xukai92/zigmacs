// Port of Fsymbolp from src/data.c:430
// Returns t if OBJECT is a symbol, nil otherwise
//
// Upstream C:
//   if (SYMBOLP (object))
//     return Qt;
//   return Qnil;
//
// Behavior: bug-for-bug identical to upstream
// - Symbol (t, nil, :keyword, 'foo, etc.) → Qt
// - CRITICAL: nil and t ARE symbols → symbolp returns Qt for them
// - Integer (fixnum or bignum) → Qnil
// - Float → Qnil
// - String, list, vector, etc. → Qnil
// - Pure function (const attribute, no side effects)

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declarations for shim functions (macro/inline API wrappers)
extern "c" fn zig_SYMBOLP(obj: Lisp_Object) bool;
extern "c" fn zig_Qnil() Lisp_Object;
extern "c" fn zig_Qt() Lisp_Object;

// Export the Zig implementation as zig_symbolp
// This will be called from the C dispatcher in data.c
export fn zig_symbolp(object: Lisp_Object) Lisp_Object {
    // Match upstream logic exactly:
    // if (SYMBOLP (object))
    //   return Qt;
    // return Qnil;

    if (zig_SYMBOLP(object)) {
        // Object is a symbol (including nil and t) → return Qt
        return zig_Qt();
    } else {
        // Object is not a symbol → return Qnil
        return zig_Qnil();
    }
}
