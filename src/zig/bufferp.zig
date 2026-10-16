// Port of Fbufferp from src/data.c:1031
// Returns t if OBJECT is an editor buffer, nil otherwise
//
// Upstream C:
//   if (BUFFERP (object))
//     return Qt;
//   return Qnil;
//
// Behavior: bug-for-bug identical to upstream
// - Buffer → Qt
// - Anything else → Qnil
// - Pure function (const attribute, no side effects)

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declarations for shim functions (macro/inline API wrappers)
extern "c" fn zig_BUFFERP(obj: Lisp_Object) bool;
extern "c" fn zig_Qnil() Lisp_Object;
extern "c" fn zig_Qt() Lisp_Object;

// Export the Zig implementation as zig_bufferp
// This will be called from the C dispatcher in data.c
export fn zig_bufferp(object: Lisp_Object) Lisp_Object {
    // Match upstream logic exactly:
    // if (BUFFERP (object))
    //   return Qt;
    // return Qnil;

    if (zig_BUFFERP(object)) {
        // Object is a buffer → return Qt
        return zig_Qt();
    } else {
        // Object is not a buffer → return Qnil
        return zig_Qnil();
    }
}
