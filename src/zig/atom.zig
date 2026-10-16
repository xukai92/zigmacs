// Port of Fatom from src/data.c:393
// Returns t if OBJECT is not a cons cell (atom includes nil), nil otherwise
//
// Upstream C:
//   if (CONSP (object))
//     return Qnil;
//   return Qt;
//
// Behavior: bug-for-bug identical to upstream
// - CRITICAL: inverted logic compared to other predicates!
// - Cons cell (a . b), non-empty list (1 2 3) → Qnil (atoms are NOT conses)
// - nil (empty list) → Qt (nil is an atom)
// - Integer, float, symbol, string, vector, etc. → Qt (all are atoms)
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

// Export the Zig implementation as zig_atom
// This will be called from the C dispatcher in data.c
export fn zig_atom(object: Lisp_Object) Lisp_Object {
    // Match upstream logic exactly:
    // if (CONSP (object))
    //   return Qnil;
    // return Qt;

    if (zig_CONSP(object)) {
        // Object is a cons cell → NOT an atom → return Qnil
        return zig_Qnil();
    } else {
        // Object is not a cons cell → IS an atom → return Qt
        return zig_Qt();
    }
}
