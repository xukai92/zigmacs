// Port of Felt from src/fns.c:1998
// Return element of SEQUENCE at index N.
//
// Upstream C:
//   if (CONSP (sequence) || NILP (sequence))
//     return Fcar (Fnthcdr (n, sequence));
//   CHECK_ARRAY (sequence, Qsequencep);
//   return Faref (sequence, n);
//
// Behavior: bug-for-bug identical to upstream
// - For lists (cons or nil): delegates to Fcar(Fnthcdr(n, sequence))
// - For arrays (vectors, strings, etc.): delegates to Faref after CHECK_ARRAY
// - Signals wrong-type-argument if sequence is not a sequence
// - Signals args-out-of-range if index is out of bounds (via Faref)
// - Signals wrong-type-argument if n is not an integer (via Fnthcdr)
//
// Implementation note:
// We call existing primitives (Fcar, Fnthcdr, Faref) which handle all
// error signaling and boundary checks. This matches upstream exactly.

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declarations for predicates and primitives
extern "c" fn zig_CONSP(o: Lisp_Object) bool;
extern "c" fn zig_NILP(o: Lisp_Object) bool;
extern "c" fn zig_Fcar(list: Lisp_Object) Lisp_Object;
extern "c" fn zig_Fnthcdr(n: Lisp_Object, list: Lisp_Object) Lisp_Object;
extern "c" fn zig_CHECK_ARRAY(x: Lisp_Object, predicate: Lisp_Object) void;
extern "c" fn zig_Faref(array: Lisp_Object, idx: Lisp_Object) Lisp_Object;
extern "c" fn zig_Qsequencep() Lisp_Object;

// Export the Zig implementation as zig_elt
// This will be called from the C dispatcher in fns.c
export fn zig_elt(sequence: Lisp_Object, n: Lisp_Object) Lisp_Object {
    // Lists (including nil) use the cons-traversal path
    if (zig_CONSP(sequence) or zig_NILP(sequence)) {
        return zig_Fcar(zig_Fnthcdr(n, sequence));
    }

    // Arrays (vectors, strings, bool-vectors, char-tables) use Faref
    // CHECK_ARRAY signals wrong-type-argument if sequence is not an array
    zig_CHECK_ARRAY(sequence, zig_Qsequencep());
    return zig_Faref(sequence, n);
}
