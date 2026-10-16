// Port of Fend_of_line from src/cmds.c:380
// Move point to end of current line (in the logical order).
// With argument N not nil or 1, move forward N - 1 lines first.
//
// Upstream C (lines 393-427):
//   ptrdiff_t newpos;
//   if (NILP (n))
//     XSETFASTINT (n, 1);
//   else
//     CHECK_FIXNUM (n);
//   while (1)
//     {
//       newpos = XFIXNUM (Fline_end_position (n));
//       SET_PT (newpos);
//       if (PT > newpos
//           && FETCH_BYTE (PT_BYTE - 1) == '\n')
//         {
//           /* If we skipped over a newline that follows
//              an invisible intangible run,
//              move back to the last tangible position
//              within the line.  */
//           SET_PT (PT - 1);
//           break;
//         }
//       else if (PT > newpos && PT < ZV
//                && FETCH_BYTE (PT_BYTE) != '\n')
//         /* If we skipped something intangible
//            and now we're not really at eol,
//            keep going.  */
//         n = make_fixnum (1);
//       else
//         break;
//     }
//   return Qnil;
//
// Behavior: bug-for-bug identical to upstream
// - Moves point to end of the Nth line
// - N defaults to 1 (current line)
// - Handles invisible/intangible text with a retry loop
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
extern "c" fn zig_PT() isize;
extern "c" fn zig_PT_BYTE() isize;
extern "c" fn zig_ZV() isize;
extern "c" fn zig_FETCH_BYTE(n: isize) c_int;

// Lisp functions
extern "c" fn zig_Fline_end_position(n: Lisp_Object) Lisp_Object;
extern "c" fn zig_Qnil() Lisp_Object;

// Export the Zig implementation as zig_end_of_line
// This will be called from the C dispatcher in cmds.c
export fn zig_end_of_line(n: Lisp_Object) Lisp_Object {
    var nn = n;

    if (zig_NILP(nn)) {
        nn = zig_make_fixnum(1);
    } else {
        zig_CHECK_FIXNUM(nn);
    }

    while (true) {
        const newpos = zig_XFIXNUM(zig_Fline_end_position(nn));
        zig_SET_PT(newpos);

        // Re-read PT and PT_BYTE after SET_PT
        const pt = zig_PT();
        const pt_byte = zig_PT_BYTE();

        if (pt > newpos and zig_FETCH_BYTE(pt_byte - 1) == 10) { // '\n' == 10
            // If we skipped over a newline that follows
            // an invisible intangible run,
            // move back to the last tangible position
            // within the line.
            zig_SET_PT(pt - 1);
            break;
        } else if (pt > newpos and pt < zig_ZV() and zig_FETCH_BYTE(pt_byte) != 10) {
            // If we skipped something intangible
            // and now we're not really at eol,
            // keep going.
            nn = zig_make_fixnum(1);
        } else {
            break;
        }
    }

    return zig_Qnil();
}
