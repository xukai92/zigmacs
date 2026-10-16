// Port of Flistp from src/data.c:340
// Returns t if OBJECT is a list (cons cell or nil), nil otherwise
//
// Upstream C:
//   if (CONSP (object) || NILP (object))
//     return Qt;
//   return Qnil;
//
// Behavior: bug-for-bug identical to upstream
// - Cons cell → Qt (is a list)
// - nil → Qt (is a list - CRITICAL: nil IS a list, opposite of consp)
// - Anything else (symbols, integers, strings, vectors, etc.) → Qnil
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

// Export the Zig implementation as zig_listp
// This will be called from the C dispatcher in data.c
export fn zig_listp(object: Lisp_Object) Lisp_Object {
    // Match upstream logic exactly:
    // if (CONSP (object) || NILP (object))
    //   return Qt;
    // return Qnil;

    if (zig_CONSP(object) or zig_NILP(object)) {
        // Object is a list (either a cons or nil) → return Qt
        return zig_Qt();
    } else {
        // Object is not a list → return Qnil
        return zig_Qnil();
    }
}
