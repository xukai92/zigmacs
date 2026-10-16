// Port of Fgoto_char from src/editfns.c:205
// Set point to POSITION, a number or marker.
// Beginning of buffer is position (point-min), end is (point-max).
//
// Upstream C:
//   if (MARKERP (position))
//     set_point_from_marker (position);
//   else if (FIXNUMP (position))
//     SET_PT (clip_to_bounds (BEGV, XFIXNUM (position), ZV));
//   else
//     wrong_type_argument (Qinteger_or_marker_p, position);
//   return position;
//
// Behavior: bug-for-bug identical to upstream
// - If position is a marker, set point from the marker (with clamping)
// - If position is a fixnum, clamp to [BEGV, ZV] and set point
// - Otherwise, signal wrong-type-argument error
// - Returns position (the input argument)
//
// Implementation note:
// Uses C helpers for marker handling and error signaling:
// - set_point_from_marker: handles marker→point conversion with clamping
// - wrong_type_argument: signals type error
// - Qinteger_or_marker_p: predicate symbol for error messages

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Type predicates
extern "c" fn zig_MARKERP(obj: Lisp_Object) bool;
extern "c" fn zig_FIXNUMP(obj: Lisp_Object) bool;

// Fixnum operations
extern "c" fn zig_XFIXNUM(obj: Lisp_Object) isize;

// Buffer/point operations
extern "c" fn zig_BEGV() isize;
extern "c" fn zig_ZV() isize;
extern "c" fn zig_SET_PT(position: isize) void;

// Marker operations (C helper)
extern "c" fn set_point_from_marker(marker: Lisp_Object) void;

// Error signaling
extern "c" fn wrong_type_argument(predicate: Lisp_Object, value: Lisp_Object) Lisp_Object;
extern "c" fn zig_Qinteger_or_marker_p() Lisp_Object;

// Helper function: clip a value to bounds [min, max]
fn clip_to_bounds(min: isize, value: isize, max: isize) isize {
    if (value < min) {
        return min;
    } else if (value > max) {
        return max;
    } else {
        return value;
    }
}

// Export the Zig implementation as zig_goto_char
// This will be called from the C dispatcher in editfns.c
export fn zig_goto_char(position: Lisp_Object) Lisp_Object {
    if (zig_MARKERP(position)) {
        // Marker: delegate to C helper (handles buffer check + byte position)
        set_point_from_marker(position);
    } else if (zig_FIXNUMP(position)) {
        // Fixnum: clamp to [BEGV, ZV] and set point
        const pos = zig_XFIXNUM(position);
        const begv = zig_BEGV();
        const zv = zig_ZV();
        const clamped = clip_to_bounds(begv, pos, zv);
        zig_SET_PT(clamped);
    } else {
        // Neither marker nor fixnum: signal type error
        return wrong_type_argument(zig_Qinteger_or_marker_p(), position);
    }

    return position;
}
