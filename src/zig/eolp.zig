// Port of Feolp from src/editfns.c:1112
// Return t if point is at the end of a line.
// 'End of a line' includes point being at the end of the buffer.
//
// Upstream C:
//   if (PT == ZV || FETCH_BYTE (PT_BYTE) == '\n')
//     return Qt;
//   return Qnil;
//
// Behavior: bug-for-bug identical to upstream
// - Returns Qt if PT == ZV (at end of visible region) OR
//   the byte at point is a newline
// - Returns Qnil otherwise
// - Pure read-only predicate (no state mutation)

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Buffer/point operations
extern "c" fn zig_PT() isize;
extern "c" fn zig_PT_BYTE() isize;
extern "c" fn zig_ZV() isize;
extern "c" fn zig_FETCH_BYTE(n: isize) c_int;

// Constants
extern "c" fn zig_Qt() Lisp_Object;
extern "c" fn zig_Qnil() Lisp_Object;

// Export the Zig implementation as zig_eolp
// This will be called from the C dispatcher in editfns.c
export fn zig_eolp() Lisp_Object {
    if (zig_PT() == zig_ZV() or zig_FETCH_BYTE(zig_PT_BYTE()) == '\n') {
        return zig_Qt();
    }
    return zig_Qnil();
}
