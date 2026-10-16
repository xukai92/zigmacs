// Port of Fbool_vector_p from src/data.c:822
// Returns t if OBJECT is a bool-vector, nil otherwise
//
// Upstream C:
//   if (BOOL_VECTOR_P (object))
//     return Qt;
//   return Qnil;
//
// Behavior: bug-for-bug identical to upstream
// - Bool-vector (created via make-bool-vector) → Qt
// - Regular vector → Qnil (CRITICAL: bool-vectors are distinct from vectors)
// - Anything else (cons, nil, string, integer, symbol, etc.) → Qnil
// - Pure function (const attribute, no side effects)

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declarations for shim functions (macro/inline API wrappers)
extern "c" fn zig_BOOL_VECTOR_P(obj: Lisp_Object) bool;
extern "c" fn zig_Qnil() Lisp_Object;
extern "c" fn zig_Qt() Lisp_Object;

// Export the Zig implementation as zig_bool_vector_p
// This will be called from the C dispatcher in data.c
export fn zig_bool_vector_p(object: Lisp_Object) Lisp_Object {
    // Match upstream logic exactly:
    // if (BOOL_VECTOR_P (object))
    //   return Qt;
    // return Qnil;

    if (zig_BOOL_VECTOR_P(object)) {
        // Object is a bool-vector → return Qt
        return zig_Qt();
    } else {
        // Object is not a bool-vector → return Qnil
        return zig_Qnil();
    }
}
