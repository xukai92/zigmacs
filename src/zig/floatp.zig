// Port of Ffloatp from src/data.c:796
// Returns t if OBJECT is a floating point number, nil otherwise
//
// Upstream C:
//   if (FLOATP (object))
//     return Qt;
//   return Qnil;
//
// Behavior: bug-for-bug identical to upstream
// - Float (3.0, 3.14, -1.5, 0.0, 1.0e10, etc.) → Qt
// - Integer (fixnum or bignum) → Qnil (CRITICAL: integers are NOT floats)
// - Anything else → Qnil
// - Pure function (const attribute, no side effects)

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declarations for shim functions (macro/inline API wrappers)
extern "c" fn zig_FLOATP(obj: Lisp_Object) bool;
extern "c" fn zig_Qnil() Lisp_Object;
extern "c" fn zig_Qt() Lisp_Object;

// Export the Zig implementation as zig_floatp
// This will be called from the C dispatcher in data.c
export fn zig_floatp(object: Lisp_Object) Lisp_Object {
    // Match upstream logic exactly:
    // if (FLOATP (object))
    //   return Qt;
    // return Qnil;

    if (zig_FLOATP(object)) {
        // Object is a floating point number → return Qt
        return zig_Qt();
    } else {
        // Object is not a float (integer, symbol, etc.) → return Qnil
        return zig_Qnil();
    }
}
