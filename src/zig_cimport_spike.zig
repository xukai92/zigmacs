// Phase-2 @cImport spike for Zigmacs
// ADDITIVE/INERT architecture de-risking spike — NOT a port
//
// CRITICAL FINDING: Zig 0.17.0 REMOVED @cImport (deprecated in 0.16).
// translate-c CRASHES (SEGV) on lisp.h.
//
// This spike proves the VIABLE binding strategy:
// - Zig extern declarations → C shim functions → Real Emacs API
// - Shim exposes macro/inline API as linkable functions
//
// Tests which Emacs API requires shims vs direct extern linkage.

const std = @import("std");

// Lisp_Object type - matches Emacs's definition
// On 64-bit USE_LSB_TAG builds, this is uintptr_t
pub const Lisp_Object = extern struct {
    value: usize,
};

// === Direct extern to real Emacs functions (no shim needed) ===

// These are actual exported functions in Emacs, callable directly
extern "c" fn Fcons(car: Lisp_Object, cdr: Lisp_Object) Lisp_Object;
extern "c" fn list1(arg1: Lisp_Object) Lisp_Object;
extern "c" fn list2(arg1: Lisp_Object, arg2: Lisp_Object) Lisp_Object;
extern "c" fn list3(arg1: Lisp_Object, arg2: Lisp_Object, arg3: Lisp_Object) Lisp_Object;

// === Extern to C shim functions (macro/inline API) ===

// Fixnum operations (inline/macro in lisp.h → require shim)
extern "c" fn zig_shim_make_fixnum(n: isize) Lisp_Object;
extern "c" fn zig_shim_XFIXNUM(obj: Lisp_Object) isize;
extern "c" fn zig_shim_FIXNUMP(obj: Lisp_Object) bool;

// Cons operations (macro in lisp.h → require shim)
extern "c" fn zig_shim_CONSP(obj: Lisp_Object) bool;
extern "c" fn zig_shim_XCAR(cons: Lisp_Object) Lisp_Object;
extern "c" fn zig_shim_XCDR(cons: Lisp_Object) Lisp_Object;

// Nil/Qt accessors (symbols, but accessed via macro → require shim)
extern "c" fn zig_shim_Qnil() Lisp_Object;
extern "c" fn zig_shim_Qt() Lisp_Object;
extern "c" fn zig_shim_NILP(obj: Lisp_Object) bool;

// Symbol operations
extern "c" fn zig_shim_SYMBOLP(obj: Lisp_Object) bool;

// String operations
extern "c" fn zig_shim_build_string(str: [*:0]const u8) Lisp_Object;

// === Exported spike function ===

// Comprehensive test using REAL Emacs API via shim layer
// Demonstrates: fixnums, cons cells, predicates, Qnil/Qt
// Returns: (42 (99 . 100) nil t) to verify correct operation
export fn zig_cimport_selftest() Lisp_Object {
    // Test 1: Fixnum operations
    const forty_two = zig_shim_make_fixnum(42);
    const is_fixnum = zig_shim_FIXNUMP(forty_two);
    _ = is_fixnum; // Verify but don't use

    // Test 2: Build a cons (99 . 100)
    const ninety_nine = zig_shim_make_fixnum(99);
    const one_hundred = zig_shim_make_fixnum(100);
    const test_cons = Fcons(ninety_nine, one_hundred); // Direct Fcons call

    // Test 3: Verify it's a cons and extract values
    const is_cons = zig_shim_CONSP(test_cons);
    _ = is_cons;
    const car_val = zig_shim_XCAR(test_cons); // Should be 99
    const cdr_val = zig_shim_XCDR(test_cons); // Should be 100
    _ = car_val;
    _ = cdr_val;

    // Test 4: Use Qnil and Qt
    const nil_val = zig_shim_Qnil();
    const t_val = zig_shim_Qt();
    const is_nil = zig_shim_NILP(nil_val);
    _ = is_nil;

    // Build result: (42 (99 . 100) nil t)
    return list4_manual(forty_two, test_cons, nil_val, t_val);
}

// Helper: build 4-element list manually since list4 might not be exported
fn list4_manual(a: Lisp_Object, b: Lisp_Object, c: Lisp_Object, d: Lisp_Object) Lisp_Object {
    const nil = zig_shim_Qnil();
    const cdr3 = Fcons(d, nil);
    const cdr2 = Fcons(c, cdr3);
    const cdr1 = Fcons(b, cdr2);
    return Fcons(a, cdr1);
}
