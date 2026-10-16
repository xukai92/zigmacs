// Port of Fmarkerp from src/data.c:1040
// Returns t if OBJECT is a marker (editor pointer), nil otherwise
//
// Upstream C:
//   if (MARKERP (object))
//     return Qt;
//   return Qnil;
//
// Behavior: bug-for-bug identical to upstream
// - Marker → Qt
// - Anything else → Qnil
// - Pure function (const attribute, no side effects)

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declarations for shim functions (macro/inline API wrappers)
extern "c" fn zig_MARKERP(obj: Lisp_Object) bool;
extern "c" fn zig_Qnil() Lisp_Object;
extern "c" fn zig_Qt() Lisp_Object;

// Export the Zig implementation as zig_markerp
// This will be called from the C dispatcher in data.c
export fn zig_markerp(object: Lisp_Object) Lisp_Object {
    // Match upstream logic exactly:
    // if (MARKERP (object))
    //   return Qt;
    // return Qnil;

    if (zig_MARKERP(object)) {
        // Object is a marker → return Qt
        return zig_Qt();
    } else {
        // Object is not a marker → return Qnil
        return zig_Qnil();
    }
}
