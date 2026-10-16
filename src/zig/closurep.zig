// Port of Fclosurep from src/data.c:1203
// Returns t if OBJECT is a function of type 'closure', nil otherwise
//
// Upstream C:
//   if (CLOSUREP (object))
//     return Qt;
//   return Qnil;
//
// Behavior: bug-for-bug identical to upstream
// - Closure function (lambda, etc.) → Qt
// - Anything else (cons, integer, string, etc.) → Qnil
// - Pure function (const attribute, no side effects)

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declarations for shim functions (macro/inline API wrappers)
extern "c" fn zig_CLOSUREP(obj: Lisp_Object) bool;
extern "c" fn zig_Qnil() Lisp_Object;
extern "c" fn zig_Qt() Lisp_Object;

// Export the Zig implementation as zig_closurep
// This will be called from the C dispatcher in data.c
export fn zig_closurep(object: Lisp_Object) Lisp_Object {
    // Match upstream logic exactly:
    // if (CLOSUREP (object))
    //   return Qt;
    // return Qnil;

    if (zig_CLOSUREP(object)) {
        // Object is a closure → return Qt
        return zig_Qt();
    } else {
        // Object is not a closure → return Qnil
        return zig_Qnil();
    }
}
