// Port of Fkeywordp from src/data.c:696
// Returns t if OBJECT is a keyword, nil otherwise
//
// Upstream C:
//   if (SYMBOLP (object)
//       && SREF (SYMBOL_NAME (object), 0) == ':'
//       && SYMBOL_INTERNED_IN_INITIAL_OBARRAY_P (object))
//     return Qt;
//   return Qnil;
//
// Behavior: bug-for-bug identical to upstream
// - Keyword symbol (:foo, :bar, etc.) → Qt
// - Non-keyword symbol (foo, nil, etc.) → Qnil
// - Non-symbol (integer, string, etc.) → Qnil
// - Pure function (const attribute, no side effects)

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declarations for shim functions (macro/inline API wrappers)
extern "c" fn zig_SYMBOLP(obj: Lisp_Object) bool;
extern "c" fn zig_SREF(str: Lisp_Object, idx: isize) u8;
extern "c" fn zig_SYMBOL_NAME(sym: Lisp_Object) Lisp_Object;
extern "c" fn zig_SYMBOL_INTERNED_IN_INITIAL_OBARRAY_P(sym: Lisp_Object) bool;
extern "c" fn zig_Qnil() Lisp_Object;
extern "c" fn zig_Qt() Lisp_Object;

// Export the Zig implementation as zig_keywordp
// This will be called from the C dispatcher in data.c
export fn zig_keywordp(object: Lisp_Object) Lisp_Object {
    // Match upstream logic exactly:
    // if (SYMBOLP (object)
    //     && SREF (SYMBOL_NAME (object), 0) == ':'
    //     && SYMBOL_INTERNED_IN_INITIAL_OBARRAY_P (object))
    //   return Qt;
    // return Qnil;

    if (zig_SYMBOLP(object) and
        zig_SREF(zig_SYMBOL_NAME(object), 0) == ':' and
        zig_SYMBOL_INTERNED_IN_INITIAL_OBARRAY_P(object)) {
        // Object is a keyword symbol → return Qt
        return zig_Qt();
    } else {
        // Object is not a keyword → return Qnil
        return zig_Qnil();
    }
}
