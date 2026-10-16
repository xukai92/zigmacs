// Port of Fhash_table_p from src/fns.c:6265
// Return t if OBJ is a Lisp hash table object.
//
// Upstream C:
//   return HASH_TABLE_P (obj) ? Qt : Qnil;
//
// Behavior: bug-for-bug identical to upstream
// - Returns Qt if obj is a hash table
// - Returns Qnil otherwise
// - No error signaling (hash-table-p is a pure predicate)
//
// Implementation note:
// Simple predicate that delegates to the HASH_TABLE_P type check.

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declarations for predicate and constants
extern "c" fn zig_HASH_TABLE_P(o: Lisp_Object) bool;
extern "c" fn zig_Qt() Lisp_Object;
extern "c" fn zig_Qnil() Lisp_Object;

// Export the Zig implementation as zig_hash_table_p
// This will be called from the C dispatcher in fns.c
export fn zig_hash_table_p(obj: Lisp_Object) Lisp_Object {
    if (zig_HASH_TABLE_P(obj)) {
        return zig_Qt();
    }
    return zig_Qnil();
}
