// Port of Fvectorp from src/data.c:544
// Returns t if OBJECT is a vector, nil otherwise
//
// Upstream C:
//   if (VECTORP (object))
//     return Qt;
//   return Qnil;
//
// Behavior: bug-for-bug identical to upstream
// - Vector ([1 2 3], [], (make-vector 3 0)) → Qt
// - String ("s", "", etc.) → Qnil (CRITICAL: strings are NOT vectors)
// - Bool-vector (make-bool-vector 3 t) → Qnil (CRITICAL: bool-vectors are NOT vectors)
// - Char-table (make-char-table 'test) → Qnil (CRITICAL: char-tables are NOT vectors)
// - List ('(1 2), nil, (1 2 3)) → Qnil
// - Integer (fixnum, bignum, character) → Qnil
// - Float → Qnil
// - Symbol (t, nil, :keyword, 'foo, etc.) → Qnil
// - Pure function (const attribute, no side effects)

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declarations for shim functions (macro/inline API wrappers)
extern "c" fn zig_VECTORP(obj: Lisp_Object) bool;
extern "c" fn zig_Qnil() Lisp_Object;
extern "c" fn zig_Qt() Lisp_Object;

// Export the Zig implementation as zig_vectorp
// This will be called from the C dispatcher in data.c
export fn zig_vectorp(object: Lisp_Object) Lisp_Object {
    // Match upstream logic exactly:
    // if (VECTORP (object))
    //   return Qt;
    // return Qnil;

    if (zig_VECTORP(object)) {
        // Object is a vector → return Qt
        return zig_Qt();
    } else {
        // Object is not a vector → return Qnil
        return zig_Qnil();
    }
}
