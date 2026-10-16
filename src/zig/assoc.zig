// Port of Fassoc from src/fns.c:2317
// Return non-nil if KEY is equal to the car of an element of ALIST.
// The value is actually the first element of ALIST whose car equals KEY.
// Equality is defined by the function TESTFN, defaulting to `equal'.
//
// Upstream C:
//   if (eq_comparable_value (key) && NILP (testfn))
//     return Fassq (key, alist);
//   Lisp_Object tail = alist;
//   FOR_EACH_TAIL (tail)
//     {
//       Lisp_Object car = XCAR (tail);
//       if (!CONSP (car))
//         continue;
//       if ((NILP (testfn)
//            ? (EQ (XCAR (car), key) || !NILP (Fequal (XCAR (car), key)))
//            : !NILP (call2 (testfn, XCAR (car), key))))
//         return car;
//     }
//   CHECK_LIST_END (tail, alist);
//   return Qnil;
//
// Behavior: bug-for-bug identical to upstream
// - For eq-comparable keys with no testfn: delegates to Fassq (eq comparison)
// - For other cases: uses equal/testfn comparison via helper
// - Returns the first element of ALIST whose car equals KEY, or Qnil if not found
// - Ignores non-cons elements in the alist
// - Signals error on circular lists (via FOR_EACH_TAIL in helper)
// - Signals error on improper lists (via CHECK_LIST_END in helper)
//
// Implementation note:
// The eq_comparable_value(x) check is inlined as: SYMBOLP(x) || FIXNUMP(x)
// The FOR_EACH_TAIL + equal/testfn comparison is delegated to zig_assoc_helper.

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declarations for predicates and functions
extern "c" fn zig_SYMBOLP(o: Lisp_Object) bool;
extern "c" fn zig_FIXNUMP(o: Lisp_Object) bool;
extern "c" fn zig_NILP(o: Lisp_Object) bool;
extern "c" fn zig_Fassq(key: Lisp_Object, alist: Lisp_Object) Lisp_Object;
extern "c" fn zig_assoc_helper(key: Lisp_Object, alist: Lisp_Object, testfn: Lisp_Object) Lisp_Object;

// Export the Zig implementation as zig_assoc
// This will be called from the C dispatcher in fns.c
export fn zig_assoc(key: Lisp_Object, alist: Lisp_Object, testfn: Lisp_Object) Lisp_Object {
    // Inline eq_comparable_value: SYMBOLP(key) || FIXNUMP(key)
    // Fast path: eq-comparable key with no custom test function
    if ((zig_SYMBOLP(key) or zig_FIXNUMP(key)) and zig_NILP(testfn)) {
        return zig_Fassq(key, alist);
    }
    // Delegate equal/testfn-comparison traversal to C helper
    return zig_assoc_helper(key, alist, testfn);
}
