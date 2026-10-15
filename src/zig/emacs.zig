// Shared Emacs bindings for Zig ports
// Provides Lisp_Object type and extern declarations for C API

const std = @import("std");

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// === Extern declarations for real Emacs functions (linkable symbols) ===

// Cons operations - these are actual exported functions
extern "c" fn Fcons(car: Lisp_Object, cdr: Lisp_Object) Lisp_Object;

// List builders
extern "c" fn list1(arg1: Lisp_Object) Lisp_Object;
extern "c" fn list2(arg1: Lisp_Object, arg2: Lisp_Object) Lisp_Object;
extern "c" fn list3(arg1: Lisp_Object, arg2: Lisp_Object, arg3: Lisp_Object) Lisp_Object;

// === Extern declarations for shim functions (macro/inline API wrappers) ===

// Fixnum operations (inline/macro in lisp.h)
pub extern "c" fn zig_FIXNUMP(obj: Lisp_Object) bool;
pub extern "c" fn zig_XFIXNUM(obj: Lisp_Object) isize;
pub extern "c" fn zig_make_fixnum(n: isize) Lisp_Object;

// Bignum operations
pub extern "c" fn zig_BIGNUMP(obj: Lisp_Object) bool;
pub extern "c" fn zig_bignum_nonnegative(obj: Lisp_Object) bool;

// Nil and Qt accessors
pub extern "c" fn zig_Qnil() Lisp_Object;
pub extern "c" fn zig_Qt() Lisp_Object;
pub extern "c" fn zig_NILP(obj: Lisp_Object) bool;

// Cons predicates and accessors
pub extern "c" fn zig_CONSP(obj: Lisp_Object) bool;
pub extern "c" fn zig_XCAR(cons: Lisp_Object) Lisp_Object;
pub extern "c" fn zig_XCDR(cons: Lisp_Object) Lisp_Object;

// Symbol operations
pub extern "c" fn zig_SYMBOLP(obj: Lisp_Object) bool;

// String operations
pub extern "c" fn zig_build_string(str: [*:0]const u8) Lisp_Object;
