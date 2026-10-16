// Port of Fproper_list_p from src/fns.c:344
// Return OBJECT's length if it is a proper list, nil otherwise.
// A proper list is neither circular nor dotted (i.e., its last cdr is nil).
//
// Upstream C:
//   intptr_t len = 0;
//   Lisp_Object last_tail = object;
//   Lisp_Object tail = object;
//   FOR_EACH_TAIL_SAFE (tail)
//     {
//       len++;
//       rarely_quit (len);
//       last_tail = XCDR (tail);
//     }
//   if (!NILP (last_tail))
//     return Qnil;
//   return make_fixnum (len);
//
// Behavior: bug-for-bug identical to upstream
// - Returns a fixnum representing the length if object is a proper list
// - Returns Qnil if object is circular, dotted, or not a list
// - Handles tortoise-and-hare cycle detection via FOR_EACH_TAIL_SAFE
// - Calls rarely_quit for long lists
//
// Implementation note:
// The FOR_EACH_TAIL_SAFE macro is complex (tortoise-and-hare cycle detection,
// rarely_quit integration), so we delegate to a C helper function
// (zig_proper_list_p_full) that wraps the full upstream implementation.
// This is the recommended approach per the porting spec for hairy traversals.

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declaration for the C helper function
// This helper implements the full FOR_EACH_TAIL_SAFE + rarely_quit logic
extern "c" fn zig_proper_list_p_full(object: Lisp_Object) Lisp_Object;

// Export the Zig implementation as zig_proper_list_p
// This will be called from the C dispatcher in fns.c
export fn zig_proper_list_p(object: Lisp_Object) Lisp_Object {
    // Delegate to C helper which implements the full traversal logic
    // including circular list detection and length counting
    return zig_proper_list_p_full(object);
}
