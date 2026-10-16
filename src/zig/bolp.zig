// Port of Fbolp from src/editfns.c:1103
// Return t if point is at the beginning of a line.
//
// Upstream C:
//   if (PT == BEGV || FETCH_BYTE (PT_BYTE - 1) == '\n')
//     return Qt;
//   return Qnil;
//
// Behavior: bug-for-bug identical to upstream
// - Returns Qt if PT == BEGV (at beginning of visible region) OR
//   the byte before point is a newline
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
extern "c" fn zig_BEGV() isize;
extern "c" fn zig_FETCH_BYTE(n: isize) c_int;

// Constants
extern "c" fn zig_Qt() Lisp_Object;
extern "c" fn zig_Qnil() Lisp_Object;

// Export the Zig implementation as zig_bolp
// This will be called from the C dispatcher in editfns.c
export fn zig_bolp() Lisp_Object {
    if (zig_PT() == zig_BEGV() or zig_FETCH_BYTE(zig_PT_BYTE() - 1) == '\n') {
        return zig_Qt();
    }
    return zig_Qnil();
}
