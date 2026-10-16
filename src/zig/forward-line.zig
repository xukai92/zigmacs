// Port of Fforward_line from src/cmds.c:99
// Move N lines forward (backward if N is negative).
// Precisely, if point is on line I, move to the start of line I + N.
// If there isn't room, go as far as possible (no error).
//
// Upstream C (lines 118-148):
//   ptrdiff_t opoint = PT, pos, pos_byte, count;
//   bool excessive = false;
//   if (NILP (n))
//     count = 1;
//   else
//     {
//       CHECK_INTEGER (n);
//       if (FIXNUMP (n)
//           && -BUF_BYTES_MAX <= XFIXNUM (n) && XFIXNUM (n) <= BUF_BYTES_MAX)
//         count = XFIXNUM (n);
//       else
//         {
//           count = !NILP (Fnatnump (n)) ? BUF_BYTES_MAX : -BUF_BYTES_MAX;
//           excessive = true;
//         }
//     }
//   ptrdiff_t counted = scan_newline_from_point (count, &pos, &pos_byte);
//   SET_PT_BOTH (pos, pos_byte);
//   ptrdiff_t shortage = count - (count <= 0) - counted;
//   if (shortage != 0)
//     shortage -= (count <= 0 ? -1
//                  : (BEGV < ZV && PT != opoint
//                     && FETCH_BYTE (PT_BYTE - 1) != '\n'));
//   return (excessive
//           ? CALLN (Fplus, make_fixnum (shortage - count), n)
//           : make_fixnum (shortage));
//
// Behavior: bug-for-bug identical to upstream
// - Returns count of lines left to move (0 on full success)
// - Exception: non-empty line at end counts as successfully moved

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Type checking and conversion
extern "c" fn zig_NILP(obj: Lisp_Object) bool;
extern "c" fn zig_CHECK_INTEGER(obj: Lisp_Object) void;
extern "c" fn zig_FIXNUMP(obj: Lisp_Object) bool;
extern "c" fn zig_XFIXNUM(obj: Lisp_Object) isize;
extern "c" fn zig_Fnatnump(obj: Lisp_Object) Lisp_Object;

// Buffer/point operations
extern "c" fn zig_PT() isize;
extern "c" fn zig_PT_BYTE() isize;
extern "c" fn zig_BEGV() isize;
extern "c" fn zig_ZV() isize;
extern "c" fn zig_FETCH_BYTE(n: isize) c_int;
extern "c" fn zig_SET_PT_BOTH(pos: isize, byte: isize) void;

// Limits
extern "c" fn zig_BUF_BYTES_MAX() isize;

// Lisp object construction
extern "c" fn zig_make_fixnum(n: isize) Lisp_Object;

// Lisp arithmetic
extern "c" fn zig_call_Fplus2(a: Lisp_Object, b: Lisp_Object) Lisp_Object;

// scan_newline_from_point - scans for newlines and updates position
// Returns the count of newlines actually crossed
extern "c" fn scan_newline_from_point(count: isize, charpos: *isize, bytepos: *isize) isize;

// Export the Zig implementation as zig_forward_line
// This will be called from the C dispatcher in cmds.c
export fn zig_forward_line(n: Lisp_Object) Lisp_Object {
    const opoint = zig_PT();
    var pos: isize = undefined;
    var pos_byte: isize = undefined;
    var count: isize = undefined;
    var excessive: bool = false;

    if (zig_NILP(n)) {
        count = 1;
    } else {
        zig_CHECK_INTEGER(n);
        const buf_bytes_max = zig_BUF_BYTES_MAX();
        if (zig_FIXNUMP(n)) {
            const n_value = zig_XFIXNUM(n);
            if (-buf_bytes_max <= n_value and n_value <= buf_bytes_max) {
                count = n_value;
            } else {
                // Out of range fixnum
                count = if (!zig_NILP(zig_Fnatnump(n))) buf_bytes_max else -buf_bytes_max;
                excessive = true;
            }
        } else {
            // Bignum (not a fixnum but is an integer)
            count = if (!zig_NILP(zig_Fnatnump(n))) buf_bytes_max else -buf_bytes_max;
            excessive = true;
        }
    }

    const counted = scan_newline_from_point(count, &pos, &pos_byte);
    zig_SET_PT_BOTH(pos, pos_byte);

    // Calculate shortage: count - (count <= 0) - counted
    // Note: (count <= 0) is a boolean converted to int (0 or 1)
    var shortage = count - @as(isize, if (count <= 0) 1 else 0) - counted;

    if (shortage != 0) {
        // Adjust shortage for the special case of non-empty line at end
        const pt = zig_PT();
        const pt_byte = zig_PT_BYTE();
        const begv = zig_BEGV();
        const zv = zig_ZV();

        const adjustment = if (count <= 0)
            @as(isize, -1)
        else
            @as(isize, if (begv < zv and pt != opoint and zig_FETCH_BYTE(pt_byte - 1) != '\n') 1 else 0);

        shortage -= adjustment;
    }

    return if (excessive)
        zig_call_Fplus2(zig_make_fixnum(shortage - count), n)
    else
        zig_make_fixnum(shortage);
}
