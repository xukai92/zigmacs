// Port of Fnatnump from src/data.c:585
// Returns t if OBJECT is a nonnegative integer, nil otherwise
//
// Upstream C:
//   return ((FIXNUMP (object) ? 0 <= XFIXNUM (object)
//            : BIGNUMP (object) && 0 <= mpz_sgn (*xbignum_val (object)))
//           ? Qt : Qnil);
//
// Behavior: bug-for-bug identical to upstream
// - Fixnum >= 0 → Qt
// - Bignum with sign >= 0 → Qt
// - Anything else (negative integers, non-integers) → Qnil
// - Pure function (const attribute, no side effects)

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declarations for shim functions (macro/inline API wrappers)
extern "c" fn zig_FIXNUMP(obj: Lisp_Object) bool;
extern "c" fn zig_XFIXNUM(obj: Lisp_Object) isize;
extern "c" fn zig_BIGNUMP(obj: Lisp_Object) bool;
extern "c" fn zig_bignum_nonnegative(obj: Lisp_Object) bool;
extern "c" fn zig_Qnil() Lisp_Object;
extern "c" fn zig_Qt() Lisp_Object;

// Export the Zig implementation as zig_natnump
// This will be called from the C dispatcher in data.c
export fn zig_natnump(object: Lisp_Object) Lisp_Object {
    // Match upstream logic exactly:
    // (FIXNUMP (object) ? 0 <= XFIXNUM (object)
    //  : BIGNUMP (object) && 0 <= mpz_sgn (*xbignum_val (object)))
    // ? Qt : Qnil

    const is_nonneg: bool = blk: {
        if (zig_FIXNUMP(object)) {
            // Fixnum case: extract value and check >= 0
            const val = zig_XFIXNUM(object);
            break :blk 0 <= val;
        } else if (zig_BIGNUMP(object)) {
            // Bignum case: check sign via shim (wraps mpz_sgn)
            break :blk zig_bignum_nonnegative(object);
        } else {
            // Not an integer at all → false
            break :blk false;
        }
    };

    // Return Qt or Qnil based on result
    return if (is_nonneg) zig_Qt() else zig_Qnil();
}
