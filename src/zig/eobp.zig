// Port of Feobp from src/editfns.c:1093
// Return t if point is at the end of the buffer.
// If the buffer is narrowed, this means the end of the narrowed part.
//
// Upstream C:
//   if (PT == ZV)
//     return Qt;
//   return Qnil;
//
// Behavior: bug-for-bug identical to upstream
// - Returns Qt if PT == ZV (point at end of visible region)
// - Returns Qnil otherwise
// - Pure read-only predicate (no state mutation)

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Buffer/point operations
extern "c" fn zig_PT() isize;
extern "c" fn zig_ZV() isize;

// Constants
extern "c" fn zig_Qt() Lisp_Object;
extern "c" fn zig_Qnil() Lisp_Object;

// Export the Zig implementation as zig_eobp
// This will be called from the C dispatcher in editfns.c
export fn zig_eobp() Lisp_Object {
    if (zig_PT() == zig_ZV()) {
        return zig_Qt();
    }
    return zig_Qnil();
}
