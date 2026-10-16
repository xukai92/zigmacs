// Port of Fbeginning_of_line from src/cmds.c:356
// Move point to beginning of current line (in the logical order).
// With argument N not nil or 1, move forward N - 1 lines first.
//
// Upstream C (lines 370-378):
//   if (NILP (n))
//     XSETFASTINT (n, 1);
//   else
//     CHECK_FIXNUM (n);
//   SET_PT (XFIXNUM (Fline_beginning_position (n)));
//   return Qnil;
//
// Behavior: bug-for-bug identical to upstream
// - Moves point to the beginning of the Nth line
// - N defaults to 1 (current line)
// - Always returns Qnil

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Type checking and conversion
extern "c" fn zig_NILP(obj: Lisp_Object) bool;
extern "c" fn zig_CHECK_FIXNUM(obj: Lisp_Object) void;
extern "c" fn zig_XFIXNUM(obj: Lisp_Object) isize;

// Lisp object construction
extern "c" fn zig_make_fixnum(n: isize) Lisp_Object;

// Buffer/point operations
extern "c" fn zig_SET_PT(pos: isize) void;

// Lisp functions
extern "c" fn zig_Fline_beginning_position(n: Lisp_Object) Lisp_Object;
extern "c" fn zig_Qnil() Lisp_Object;

// Export the Zig implementation as zig_beginning_of_line
// This will be called from the C dispatcher in cmds.c
export fn zig_beginning_of_line(n: Lisp_Object) Lisp_Object {
    var nn = n;

    if (zig_NILP(nn)) {
        nn = zig_make_fixnum(1);
    } else {
        zig_CHECK_FIXNUM(nn);
    }

    zig_SET_PT(zig_XFIXNUM(zig_Fline_beginning_position(nn)));

    return zig_Qnil();
}
