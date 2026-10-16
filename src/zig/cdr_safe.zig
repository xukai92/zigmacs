// Port of Fcdr_safe from src/data.c:1261
// Return the cdr of OBJECT if it is a cons cell, or else nil.
//
// Upstream C:
//   return CDR_SAFE (object);
//
// Behavior: bug-for-bug identical to upstream
// - Returns the cdr of OBJECT if it is a cons cell
// - Returns Qnil if OBJECT is not a cons cell
// - Never signals an error (safe variant)
//
// Implementation note:
// CDR_SAFE is a simple macro wrapper, available as zig_CDR_SAFE in the shim.

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declaration for the CDR_SAFE wrapper
extern "c" fn zig_CDR_SAFE(obj: Lisp_Object) Lisp_Object;

// Export the Zig implementation as zig_cdr_safe
// This will be called from the C dispatcher in data.c
export fn zig_cdr_safe(object: Lisp_Object) Lisp_Object {
    return zig_CDR_SAFE(object);
}
