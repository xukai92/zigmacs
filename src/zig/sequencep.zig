// Port of Fsequencep from src/data.c:840
// Returns t if OBJECT is a sequence (list or array), nil otherwise
//
// Upstream C:
//   if (CONSP (object) || NILP (object) || ARRAYP (object))
//     return Qt;
//   return Qnil;
//
// Behavior: bug-for-bug identical to upstream
// - Cons cell ((1 2 3), (1 . 2), etc.) → Qt
// - nil (empty list) → Qt (CRITICAL: nil is a sequence)
// - Array (string, vector, bool-vector, char-table) → Qt
// - Integer, symbol, etc. → Qnil
// - Pure function (const attribute, no side effects)

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declarations for shim functions (macro/inline API wrappers)
extern "c" fn zig_CONSP(obj: Lisp_Object) bool;
extern "c" fn zig_NILP(obj: Lisp_Object) bool;
extern "c" fn zig_ARRAYP(obj: Lisp_Object) bool;
extern "c" fn zig_Qnil() Lisp_Object;
extern "c" fn zig_Qt() Lisp_Object;

// Export the Zig implementation as zig_sequencep
// This will be called from the C dispatcher in data.c
export fn zig_sequencep(object: Lisp_Object) Lisp_Object {
    // Match upstream logic exactly:
    // if (CONSP (object) || NILP (object) || ARRAYP (object))
    //   return Qt;
    // return Qnil;

    if (zig_CONSP(object) or zig_NILP(object) or zig_ARRAYP(object)) {
        // Object is a sequence (cons, nil, or array) → return Qt
        return zig_Qt();
    } else {
        // Object is not a sequence → return Qnil
        return zig_Qnil();
    }
}
