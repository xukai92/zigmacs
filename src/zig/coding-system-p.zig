// Port of Fcoding_system_p from src/coding.c
// Returns t if OBJECT is nil or a coding-system
//
// Upstream C:
//   if (NILP (object)
//       || CODING_SYSTEM_ID (object) >= 0)
//     return Qt;
//   if (! SYMBOLP (object)
//       || NILP (Fget (object, Qcoding_system_define_form)))
//     return Qnil;
//   return Qt;
//
// Behavior: bug-for-bug identical to upstream
// - nil → t (CRITICAL: nil is considered a valid coding system)
// - Valid coding system (has CODING_SYSTEM_ID >= 0) → t
// - Symbol with coding-system-define-form property → t
// - Non-symbol or symbol without the property → nil
// - Pure function aside from Fget call (property lookup)

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declarations for shim functions (macro/inline API wrappers)
extern "c" fn zig_NILP(obj: Lisp_Object) bool;
extern "c" fn zig_SYMBOLP(obj: Lisp_Object) bool;
extern "c" fn zig_CODING_SYSTEM_ID(obj: Lisp_Object) c_int;
extern "c" fn zig_Fget(symbol: Lisp_Object, propname: Lisp_Object) Lisp_Object;
extern "c" fn zig_Qcoding_system_define_form() Lisp_Object;
extern "c" fn zig_Qnil() Lisp_Object;
extern "c" fn zig_Qt() Lisp_Object;

// Export the Zig implementation as zig_coding_system_p
// This will be called from the C dispatcher in coding.c
export fn zig_coding_system_p(object: Lisp_Object) Lisp_Object {
    // Match upstream logic exactly:
    // if (NILP (object)
    //     || CODING_SYSTEM_ID (object) >= 0)
    //   return Qt;
    // if (! SYMBOLP (object)
    //     || NILP (Fget (object, Qcoding_system_define_form)))
    //   return Qnil;
    // return Qt;

    // First check: nil or has valid CODING_SYSTEM_ID
    if (zig_NILP(object) or zig_CODING_SYSTEM_ID(object) >= 0) {
        return zig_Qt();
    }

    // Second check: if not a symbol, or doesn't have the property, return nil
    if (!zig_SYMBOLP(object)) {
        return zig_Qnil();
    }

    const define_form = zig_Fget(object, zig_Qcoding_system_define_form());
    if (zig_NILP(define_form)) {
        return zig_Qnil();
    }

    // Symbol with coding-system-define-form property → return Qt
    return zig_Qt();
}
