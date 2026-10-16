// Port of Fforward_char from src/cmds.c:71
// Move point N characters forward (backward if N is negative).
// On reaching end or beginning of buffer, stop and signal error.
//
// Upstream C:
//   return move_point (n, 1);
//
// Behavior: bug-for-bug identical to upstream
// - Calls move_point with forward=true (1)
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

// Export the Zig implementation as zig_forward_char
// This will be called from the C dispatcher in cmds.c
export fn zig_forward_char(n: Lisp_Object) Lisp_Object {
    return zig_move_point(n, true);
}
