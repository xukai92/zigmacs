// Port of Ffunctionp from src/eval.c:2984
// Returns t if OBJECT is a function, nil otherwise
//
// Upstream C:
//   if (FUNCTIONP (object))
//     return Qt;
//   return Qnil;
//
// Behavior: bug-for-bug identical to upstream
// - Function objects → Qt
// - Symbols with function bindings → Qt
// - Macros and special forms → Qnil
// - Anything else → Qnil
// - Pure function (const attribute, no side effects)

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declarations for shim functions (macro/inline API wrappers)
extern "c" fn zig_FUNCTIONP(obj: Lisp_Object) bool;
extern "c" fn zig_Qnil() Lisp_Object;
extern "c" fn zig_Qt() Lisp_Object;

// Export the Zig implementation as zig_functionp
// This will be called from the C dispatcher in eval.c
export fn zig_functionp(object: Lisp_Object) Lisp_Object {
    // Match upstream logic exactly:
    // if (FUNCTIONP (object))
    //   return Qt;
    // return Qnil;

    if (zig_FUNCTIONP(object)) {
        // Object is a function → return Qt
        return zig_Qt();
    } else {
        // Object is not a function → return Qnil
        return zig_Qnil();
    }
}
