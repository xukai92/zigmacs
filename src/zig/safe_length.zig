// Port of Fsafe_length from src/fns.c:215
// Return the length of a list, but avoid error or infinite loop.
// This function never gets an error.  If LIST is not really a list,
// it returns 0.  If LIST is circular, it returns an integer that is at
// least the number of distinct elements.
//
// Upstream C:
//   intptr_t len = 0;
//   FOR_EACH_TAIL_SAFE (list)
//     len++;
//   return make_fixnum (len);
//
// Behavior: bug-for-bug identical to upstream
// - Returns the length of a list (as a fixnum)
// - Returns 0 for non-lists (atoms)
// - Never signals an error
// - For circular lists, returns the number of distinct elements (tortoise-and-hare)
//
// Implementation note:
// FOR_EACH_TAIL_SAFE is complex (tortoise-and-hare cycle detection),
// so we use a C helper function (zig_safe_length_count) that implements
// the full traversal logic. Then we convert the count to a fixnum using
// zig_make_fixnum.

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declarations for the C helper and make_fixnum
extern "c" fn zig_safe_length_count(list: Lisp_Object) isize;
extern "c" fn zig_make_fixnum(n: isize) Lisp_Object;

// Export the Zig implementation as zig_safe_length
// This will be called from the C dispatcher in fns.c
export fn zig_safe_length(list: Lisp_Object) Lisp_Object {
    const len: isize = zig_safe_length_count(list);
    return zig_make_fixnum(len);
}
