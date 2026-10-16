// Port of Farrayp from src/data.c:831
// Returns t if OBJECT is an array (string or vector), nil otherwise
//
// Upstream C:
//   if (ARRAYP (object))
//     return Qt;
//   return Qnil;
//
// Behavior: bug-for-bug identical to upstream
// - String ("foo", "", etc.) → Qt
// - Vector ([1 2 3], [], etc.) → Qt
// - Bool-vector (make-bool-vector) → Qt
// - Char-table → Qt
// - Anything else (cons, nil, integer, symbol, etc.) → Qnil
// - Pure function (const attribute, no side effects)

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declarations for shim functions (macro/inline API wrappers)
extern "c" fn zig_ARRAYP(obj: Lisp_Object) bool;
extern "c" fn zig_Qnil() Lisp_Object;
extern "c" fn zig_Qt() Lisp_Object;

// Export the Zig implementation as zig_arrayp
// This will be called from the C dispatcher in data.c
export fn zig_arrayp(object: Lisp_Object) Lisp_Object {
    // Match upstream logic exactly:
    // if (ARRAYP (object))
    //   return Qt;
    // return Qnil;

    if (zig_ARRAYP(object)) {
        // Object is an array (string, vector, bool-vector, or char-table) → return Qt
        return zig_Qt();
    } else {
        // Object is not an array → return Qnil
        return zig_Qnil();
    }
}
