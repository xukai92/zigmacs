// Port of Fnumberp from src/data.c:687
// Returns t if OBJECT is a number (floating point or integer), nil otherwise
//
// Upstream C:
//   if (NUMBERP (object))
//     return Qt;
//   else
//     return Qnil;
//
// Behavior: bug-for-bug identical to upstream
// - Fixnum → Qt
// - Bignum → Qt
// - Float → Qt
// - Anything else → Qnil
// - Pure function (const attribute, no side effects)

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declarations for shim functions (macro/inline API wrappers)
extern "c" fn zig_NUMBERP(obj: Lisp_Object) bool;
extern "c" fn zig_Qnil() Lisp_Object;
extern "c" fn zig_Qt() Lisp_Object;

// Export the Zig implementation as zig_numberp
// This will be called from the C dispatcher in data.c
export fn zig_numberp(object: Lisp_Object) Lisp_Object {
    // Match upstream logic exactly:
    // if (NUMBERP (object))
    //   return Qt;
    // else
    //   return Qnil;

    if (zig_NUMBERP(object)) {
        // Object is a number (fixnum, bignum, or float) → return Qt
        return zig_Qt();
    } else {
        // Object is not a number → return Qnil
        return zig_Qnil();
    }
}
