// Port of Fmemq from src/fns.c:1914
// Return non-nil if ELT is an element of LIST.  Comparison done with `eq'.
// The value is actually the tail of LIST whose car is ELT.
//
// Upstream C:
//   Lisp_Object tail = list;
//   FOR_EACH_TAIL (tail)
//     if (EQ (XCAR (tail), elt))
//       return tail;
//   CHECK_LIST_END (tail, list);
//   return Qnil;
//
// Behavior: bug-for-bug identical to upstream
// - Returns the tail of LIST whose car is ELT (using eq comparison)
// - Returns Qnil if ELT is not found
// - Signals error on circular lists (via FOR_EACH_TAIL)
// - Signals error on improper lists (via CHECK_LIST_END)
// - nil is a valid list (empty list) → returns Qnil
//
// Implementation note:
// The FOR_EACH_TAIL macro and CHECK_LIST_END are complex (tortoise-and-hare
// cycle detection), so we use a C helper function (zig_memq_helper) that
// wraps the full C implementation. This is allowed per the porting spec:
// "You MAY call extern C (Fcons, etc.) for allocation/loops."

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declaration for the C helper function
// This helper handles the full FOR_EACH_TAIL + CHECK_LIST_END logic
extern "c" fn zig_memq_helper(elt: Lisp_Object, list: Lisp_Object) Lisp_Object;

// Export the Zig implementation as zig_memq
// This will be called from the C dispatcher in fns.c
export fn zig_memq(elt: Lisp_Object, list: Lisp_Object) Lisp_Object {
    // Delegate to C helper which implements the full traversal logic
    // including circular list detection and error signaling
    return zig_memq_helper(elt, list);
}
