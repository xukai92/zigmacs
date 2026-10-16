// Port of Frecordp from src/data.c:732
// Returns t if OBJECT is a record, nil otherwise
//
// Upstream C:
//   if (RECORDP (object))
//     return Qt;
//   return Qnil;
//
// Behavior: bug-for-bug identical to upstream
// - Record (created via 'record' function) → Qt
// - Anything else (cons, nil, vector, string, integer, symbol, etc.) → Qnil
// - Pure function (const attribute, no side effects)

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declarations for shim functions (macro/inline API wrappers)
extern "c" fn zig_RECORDP(obj: Lisp_Object) bool;
extern "c" fn zig_Qnil() Lisp_Object;
extern "c" fn zig_Qt() Lisp_Object;

// Export the Zig implementation as zig_recordp
// This will be called from the C dispatcher in data.c
export fn zig_recordp(object: Lisp_Object) Lisp_Object {
    // Match upstream logic exactly:
    // if (RECORDP (object))
    //   return Qt;
    // return Qnil;

    if (zig_RECORDP(object)) {
        // Object is a record → return Qt
        return zig_Qt();
    } else {
        // Object is not a record → return Qnil
        return zig_Qnil();
    }
}
