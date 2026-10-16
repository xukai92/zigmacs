// Port of Flength from src/fns.c:128
// Returns the length of vector, list or string SEQUENCE
//
// Upstream C (simplified):
//   if (STRINGP (sequence))
//     val = SCHARS (sequence);
//   else if (CONSP (sequence))
//     val = list_length (sequence);
//   else if (NILP (sequence))
//     val = 0;
//   else if (VECTORP (sequence))
//     val = ASIZE (sequence);
//   else if (CHAR_TABLE_P (sequence))
//     val = MAX_CHAR;
//   else if (BOOL_VECTOR_P (sequence))
//     val = bool_vector_size (sequence);
//   else if (CLOSUREP (sequence) || RECORDP (sequence))
//     val = PVSIZE (sequence);
//   else
//     wrong_type_argument (Qsequencep, sequence);
//   return make_fixnum (val);
//
// Behavior: bug-for-bug identical to upstream
// - For strings: returns number of CHARACTERS (not bytes for multibyte)
// - For lists: signals error on circular or improper lists
// - For nil: returns 0
// - For vectors, char-tables, bool-vectors, closures, records: returns size
// - For other types: signals wrong-type-argument error

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declarations for shim functions (macro/inline API wrappers)
extern "c" fn zig_STRINGP(obj: Lisp_Object) bool;
extern "c" fn zig_CONSP(obj: Lisp_Object) bool;
extern "c" fn zig_NILP(obj: Lisp_Object) bool;
extern "c" fn zig_VECTORP(obj: Lisp_Object) bool;
extern "c" fn zig_CHAR_TABLE_P(obj: Lisp_Object) bool;
extern "c" fn zig_BOOL_VECTOR_P(obj: Lisp_Object) bool;
extern "c" fn zig_CLOSUREP(obj: Lisp_Object) bool;
extern "c" fn zig_RECORDP(obj: Lisp_Object) bool;

extern "c" fn zig_SCHARS(obj: Lisp_Object) isize;
extern "c" fn zig_ASIZE(obj: Lisp_Object) isize;
extern "c" fn zig_PVSIZE(obj: Lisp_Object) isize;
extern "c" fn zig_MAX_CHAR() isize;
extern "c" fn zig_bool_vector_size(obj: Lisp_Object) isize;
extern "c" fn zig_list_length(list: Lisp_Object) isize;

extern "c" fn zig_make_fixnum(n: isize) Lisp_Object;

// Extern declaration for error signaling (C function, not a shim)
extern "c" fn wrong_type_argument(predicate: Lisp_Object, value: Lisp_Object) Lisp_Object;
extern "c" fn zig_build_string(str: [*:0]const u8) Lisp_Object;

// Global symbols we need
extern "c" var Qsequencep: Lisp_Object;

// Export the Zig implementation as zig_length
// This will be called from the C dispatcher in fns.c
export fn zig_length(sequence: Lisp_Object) Lisp_Object {
    // Match upstream logic exactly
    var val: isize = undefined;

    if (zig_STRINGP(sequence)) {
        // String: return number of characters
        val = zig_SCHARS(sequence);
    } else if (zig_CONSP(sequence)) {
        // List: use list_length (signals error on circular/improper lists)
        val = zig_list_length(sequence);
    } else if (zig_NILP(sequence)) {
        // nil: length is 0
        val = 0;
    } else if (zig_VECTORP(sequence)) {
        // Vector: return size
        val = zig_ASIZE(sequence);
    } else if (zig_CHAR_TABLE_P(sequence)) {
        // Char-table: return MAX_CHAR
        val = zig_MAX_CHAR();
    } else if (zig_BOOL_VECTOR_P(sequence)) {
        // Bool-vector: return size
        val = zig_bool_vector_size(sequence);
    } else if (zig_CLOSUREP(sequence) or zig_RECORDP(sequence)) {
        // Closure or record: return pseudo-vector size
        val = zig_PVSIZE(sequence);
    } else {
        // Wrong type: signal error
        // This never returns, but Zig needs a return value for type checking
        return wrong_type_argument(Qsequencep, sequence);
    }

    return zig_make_fixnum(val);
}
