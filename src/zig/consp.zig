// Port of Fconsp from src/data.c:333
// Returns t if OBJECT is a cons cell, nil otherwise
//
// Upstream C:
//   if (CONSP (object))
//     return Qt;
//   return Qnil;
//
// Behavior: bug-for-bug identical to upstream
// - Cons cell ((1 . 2), (1 2 3), etc.) → Qt
// - nil → Qnil (CRITICAL: nil is NOT a cons, contrast with listp)
// - Integer (fixnum, bignum, character) → Qnil
// - Float → Qnil
// - Symbol (t, :keyword, 'foo, etc.) → Qnil
// - String → Qnil
// - Vector → Qnil
// - Pure function (const attribute, no side effects)

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declarations for shim functions (macro/inline API wrappers)
extern "c" fn zig_CONSP(obj: Lisp_Object) bool;
extern "c" fn zig_Qnil() Lisp_Object;
extern "c" fn zig_Qt() Lisp_Object;

// Export the Zig implementation as zig_consp
// This will be called from the C dispatcher in data.c
export fn zig_consp(object: Lisp_Object) Lisp_Object {
    // Match upstream logic exactly:
    // if (CONSP (object))
    //   return Qt;
    // return Qnil;

    if (zig_CONSP(object)) {
        // Object is a cons cell → return Qt
        return zig_Qt();
    } else {
        // Object is not a cons cell → return Qnil
        return zig_Qnil();
    }
}
