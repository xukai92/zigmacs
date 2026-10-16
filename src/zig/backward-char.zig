// Port of Fbackward_char from src/cmds.c:85
// Move point N characters backward (forward if N is negative).
// On attempt to pass beginning or end of buffer, stop and signal error.
//
// Upstream C:
//   return move_point (n, 0);
//
// Behavior: bug-for-bug identical to upstream
// - Calls move_point with forward=false (0)
// - Returns nil on success
// - Signals beginning-of-buffer or end-of-buffer error at edges

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// move_point - moves point N characters in the given direction
// forward: true for forward, false for backward
// Returns nil on success, signals error at buffer edges
extern "c" fn zig_move_point(n: Lisp_Object, forward: bool) Lisp_Object;

// Export the Zig implementation as zig_backward_char
// This will be called from the C dispatcher in cmds.c
export fn zig_backward_char(n: Lisp_Object) Lisp_Object {
    return zig_move_point(n, false);
}
