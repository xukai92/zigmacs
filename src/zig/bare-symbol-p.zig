// Port of Fbare_symbol_p from src/data.c:506
// Returns t if OBJECT is a symbol (but not a symbol-with-position), nil otherwise
//
// Upstream C:
//   if (BARE_SYMBOL_P (object))
//     return Qt;
//   return Qnil;
//
// Behavior: bug-for-bug identical to upstream
// - Bare symbol (t, nil, 'foo, :keyword, etc.) → Qt
// - Symbol-with-position → Qnil (CRITICAL: only *bare* symbols return t)
// - Integer, float, string, list, vector, etc. → Qnil
// - Pure function (const attribute, no side effects)

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declarations for shim functions (macro/inline API wrappers)
extern "c" fn zig_BARE_SYMBOL_P(obj: Lisp_Object) bool;
extern "c" fn zig_Qnil() Lisp_Object;
extern "c" fn zig_Qt() Lisp_Object;

// Export the Zig implementation as zig_bare_symbol_p
// This will be called from the C dispatcher in data.c
export fn zig_bare_symbol_p(object: Lisp_Object) Lisp_Object {
    // Match upstream logic exactly:
    // if (BARE_SYMBOL_P (object))
    //   return Qt;
    // return Qnil;

    if (zig_BARE_SYMBOL_P(object)) {
        // Object is a bare symbol → return Qt
        return zig_Qt();
    } else {
        // Object is not a bare symbol → return Qnil
        return zig_Qnil();
    }
}
