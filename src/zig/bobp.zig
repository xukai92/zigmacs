// Port of Fbobp from src/editfns.c:1083
// Return t if point is at the beginning of the buffer.
// If the buffer is narrowed, this means the beginning of the narrowed part.
//
// Upstream C:
//   if (PT == BEGV)
//     return Qt;
//   return Qnil;
//
// Behavior: bug-for-bug identical to upstream
// - Returns Qt if PT == BEGV (point at beginning of visible region)
// - Returns Qnil otherwise
// - Pure read-only predicate (no state mutation)

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Buffer/point operations
extern "c" fn zig_PT() isize;
extern "c" fn zig_BEGV() isize;

// Constants
extern "c" fn zig_Qt() Lisp_Object;
extern "c" fn zig_Qnil() Lisp_Object;

// Export the Zig implementation as zig_bobp
// This will be called from the C dispatcher in editfns.c
export fn zig_bobp() Lisp_Object {
    if (zig_PT() == zig_BEGV()) {
        return zig_Qt();
    }
    return zig_Qnil();
}
