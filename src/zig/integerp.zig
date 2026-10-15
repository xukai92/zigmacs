// Port of Fintegerp from src/data.c:620
// Returns t if OBJECT is an integer (fixnum or bignum), nil otherwise
//
// Upstream C:
//   if (INTEGERP (object))
//     return Qt;
//   return Qnil;
//
// Behavior: bug-for-bug identical to upstream
// - Fixnum → Qt
// - Bignum → Qt
// - Float → Qnil (CRITICAL: floats are NOT integers)
// - Anything else → Qnil
// - Pure function (const attribute, no side effects)

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declarations for shim functions (macro/inline API wrappers)
extern "c" fn zig_INTEGERP(obj: Lisp_Object) bool;
extern "c" fn zig_Qnil() Lisp_Object;
extern "c" fn zig_Qt() Lisp_Object;

// Export the Zig implementation as zig_integerp
// This will be called from the C dispatcher in data.c
export fn zig_integerp(object: Lisp_Object) Lisp_Object {
    // Match upstream logic exactly:
    // if (INTEGERP (object))
    //   return Qt;
    // return Qnil;

    if (zig_INTEGERP(object)) {
        // Object is an integer (fixnum or bignum) → return Qt
        return zig_Qt();
    } else {
        // Object is not an integer (float, symbol, etc.) → return Qnil
        return zig_Qnil();
    }
}
