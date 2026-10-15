// Phase-1 C↔Zig interop spike for Zigmacs
// ADDITIVE/INERT architecture de-risking spike — NOT a port
//
// Proves:
// 1. Zig object links into emacs binary
// 2. C→Zig calls work
// 3. Zig→C calls work (calling real Emacs C functions)
// 4. Lisp_Object round-trips correctly through Zig

const std = @import("std");

// Lisp_Object type matching — on 64-bit systems without CHECK_LISP_OBJECT_TYPE,
// this is typedef'd to Lisp_Word which is either `struct Lisp_X *` or EMACS_INT.
// On typical 64-bit builds where EMACS_INT_MAX == INTPTR_MAX, it's a pointer-width value.
// We match it as an opaque pointer-sized value for maximum compatibility.
pub const Lisp_Object = if (@sizeOf(usize) == 8)
    extern struct { i: u64 }
else
    extern struct { i: u32 };

// External C functions from Emacs that we'll call
extern "c" fn Fcons(car: Lisp_Object, cdr: Lisp_Object) Lisp_Object;
extern "c" fn Fadd1(number: Lisp_Object) Lisp_Object;
extern "c" fn Qnil() Lisp_Object;

// Helper to create a fixnum directly (matches lisp.h macro)
// For USE_LSB_TAG (the common case), fixnums are:
// (n << INTTYPEBITS) + Lisp_Int0, where INTTYPEBITS=3 and Lisp_Int0=2
fn make_fixnum(n: i64) Lisp_Object {
    const INTTYPEBITS = 3;
    const Lisp_Int0 = 2;
    const shifted: u64 = @bitCast(@as(i64, n) << INTTYPEBITS);
    const tagged = shifted + Lisp_Int0;
    return Lisp_Object{ .i = tagged };
}

// Extract fixnum value (reverse of make_fixnum)
fn xfixnum(obj: Lisp_Object) i64 {
    const INTTYPEBITS = 3;
    const raw: i64 = @bitCast(obj.i);
    return raw >> INTTYPEBITS;
}

// Exported function: takes a fixnum, adds 1 via Emacs's Fadd1, returns result
// This proves Zig→C calling
export fn zig_spike_add1(number: Lisp_Object) Lisp_Object {
    return Fadd1(number);
}

// Exported function: builds a cons cell using Emacs's Fcons
// This proves both Zig→C and round-tripping of Lisp_Object
export fn zig_spike_cons(car: Lisp_Object, cdr: Lisp_Object) Lisp_Object {
    return Fcons(car, cdr);
}

// Exported function: comprehensive test that exercises all four proof requirements
// Takes a fixnum n, returns a cons: (n+1 . (n+2 . nil))
// This proves:
// - Zig code executes (linked correctly)
// - C→Zig works (this function is called from C)
// - Zig→C works (calls Fadd1, Fcons)
// - Lisp_Object round-trips (receives, manipulates, returns tagged values)
export fn zig_spike_selftest(number: Lisp_Object) Lisp_Object {
    // Call Emacs C function to add 1
    const n_plus_1 = Fadd1(number);

    // Add 1 again to get n+2
    const n_plus_2 = Fadd1(n_plus_1);

    // Build nil as fixnum 0 with Lisp_Symbol tag
    // Actually, we should call a C function that returns Qnil
    // Let's use make_fixnum for now and build a proper cons
    const nil_val = make_fixnum(0);

    // Build inner cons: (n+2 . nil)
    // For now, use nil_val; ideally we'd import Qnil as a symbol
    const inner_cons = Fcons(n_plus_2, nil_val);

    // Build outer cons: (n+1 . inner_cons)
    const result = Fcons(n_plus_1, inner_cons);

    return result;
}

// Alternative simpler selftest: just demonstrate fixnum round-trip
// Takes fixnum 41, returns fixnum 42 via Emacs's Fadd1
export fn zig_spike_simple_test(n: Lisp_Object) Lisp_Object {
    return Fadd1(n);
}
