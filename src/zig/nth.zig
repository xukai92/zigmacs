// Port of Fnth from src/fns.c:1900
// Return the Nth element of LIST.
// N counts from zero.  If LIST is not that long, nil is returned.
//
// Upstream C:
//   return Fcar (Fnthcdr (n, list));
//
// Behavior: bug-for-bug identical to upstream
// - Returns the Nth element of LIST (0-indexed)
// - Returns nil if LIST is not that long
// - Signals error if N is not an integer
// - Signals error on circular/improper lists (via Fnthcdr)
//
// Implementation note:
// We call Fnthcdr to skip N elements, then Fcar to get the first element
// of the result. This matches upstream exactly.

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declarations for Fcar and Fnthcdr
extern "c" fn zig_Fcar(list: Lisp_Object) Lisp_Object;
extern "c" fn zig_Fnthcdr(n: Lisp_Object, list: Lisp_Object) Lisp_Object;

// Export the Zig implementation as zig_nth
// This will be called from the C dispatcher in fns.c
export fn zig_nth(n: Lisp_Object, list: Lisp_Object) Lisp_Object {
    return zig_Fcar(zig_Fnthcdr(n, list));
}
