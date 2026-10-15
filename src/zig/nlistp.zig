// Port of Fnlistp from src/data.c:346
// Returns t if OBJECT is not a list (lists include nil)
//
// Upstream C:
//   if (CONSP (object) || NILP (object))
//     return Qnil;
//   return Qt;
//
// Behavior: bug-for-bug identical to upstream
// - Cons cell → Qnil (is a list)
// - nil → Qnil (is a list)
// - Anything else (symbols, integers, strings, vectors, etc.) → Qt
// - Pure function (const attribute, no side effects)

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declarations for shim functions (macro/inline API wrappers)
extern "c" fn zig_CONSP(obj: Lisp_Object) bool;
extern "c" fn zig_NILP(obj: Lisp_Object) bool;
extern "c" fn zig_Qnil() Lisp_Object;
extern "c" fn zig_Qt() Lisp_Object;

// Export the Zig implementation as zig_nlistp
// This will be called from the C dispatcher in data.c
export fn zig_nlistp(object: Lisp_Object) Lisp_Object {
    // Match upstream logic exactly:
    // if (CONSP (object) || NILP (object))
    //   return Qnil;
    // return Qt;

    if (zig_CONSP(object) or zig_NILP(object)) {
        // Object is a list (either a cons or nil) → return Qnil
        return zig_Qnil();
    } else {
        // Object is not a list → return Qt
        return zig_Qt();
    }
}
