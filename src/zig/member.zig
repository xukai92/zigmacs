// Port of Fmember from src/fns.c:2130
// Return non-nil if ELT is an element of LIST. Comparison done with `equal'.
// The value is actually the tail of LIST whose car is ELT.
//
// Upstream C:
//   if (eq_comparable_value (elt))
//     return Fmemq (elt, list);
//   Lisp_Object tail = list;
//   FOR_EACH_TAIL (tail)
//     if (! NILP (Fequal (elt, XCAR (tail))))
//       return tail;
//   CHECK_LIST_END (tail, list);
//   return Qnil;
//
// Behavior: bug-for-bug identical to upstream
// - For eq-comparable values (symbols, fixnums): delegates to Fmemq (eq comparison)
// - For other values: uses equal comparison via helper
// - Returns the tail of LIST whose car is ELT, or Qnil if not found
// - Signals error on circular lists (via FOR_EACH_TAIL in helper)
// - Signals error on improper lists (via CHECK_LIST_END in helper)
//
// Implementation note:
// The eq_comparable_value(x) check is inlined as: SYMBOLP(x) || FIXNUMP(x)
// The FOR_EACH_TAIL + equal comparison is delegated to zig_member_equal_helper.

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declarations for predicates and functions
extern "c" fn zig_SYMBOLP(o: Lisp_Object) bool;
extern "c" fn zig_FIXNUMP(o: Lisp_Object) bool;
extern "c" fn zig_Fmemq(elt: Lisp_Object, list: Lisp_Object) Lisp_Object;
extern "c" fn zig_member_equal_helper(elt: Lisp_Object, list: Lisp_Object) Lisp_Object;

// Export the Zig implementation as zig_member
// This will be called from the C dispatcher in fns.c
export fn zig_member(elt: Lisp_Object, list: Lisp_Object) Lisp_Object {
    // Inline eq_comparable_value: SYMBOLP(elt) || FIXNUMP(elt)
    if (zig_SYMBOLP(elt) or zig_FIXNUMP(elt)) {
        return zig_Fmemq(elt, list);
    }
    // Delegate equal-comparison traversal to C helper
    return zig_member_equal_helper(elt, list);
}
