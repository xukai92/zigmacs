// Port of Fchar_table_p from src/data.c:862
// Returns t if OBJECT is a char-table, nil otherwise
//
// Upstream C:
//   if (CHAR_TABLE_P (object))
//     return Qt;
//   return Qnil;
//
// Behavior: bug-for-bug identical to upstream
// - Char-table → Qt
// - Anything else → Qnil
// - Pure function (const attribute, no side effects)

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declarations for shim functions (macro/inline API wrappers)
extern "c" fn zig_CHAR_TABLE_P(obj: Lisp_Object) bool;
extern "c" fn zig_Qnil() Lisp_Object;
extern "c" fn zig_Qt() Lisp_Object;

// Export the Zig implementation as zig_char_table_p
// This will be called from the C dispatcher in data.c
export fn zig_char_table_p(object: Lisp_Object) Lisp_Object {
    // Match upstream logic exactly:
    // if (CHAR_TABLE_P (object))
    //   return Qt;
    // return Qnil;

    if (zig_CHAR_TABLE_P(object)) {
        // Object is a char-table → return Qt
        return zig_Qt();
    } else {
        // Object is not a char-table → return Qnil
        return zig_Qnil();
    }
}
