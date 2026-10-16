// Port of Fcar_safe from src/data.c:1243
// Return the car of OBJECT if it is a cons cell, or else nil.
//
// Upstream C:
//   return CAR_SAFE (object);
//
// Behavior: bug-for-bug identical to upstream
// - Returns the car of OBJECT if it is a cons cell
// - Returns Qnil if OBJECT is not a cons cell
// - Never signals an error (safe variant)
//
// Implementation note:
// CAR_SAFE is a simple macro wrapper, available as zig_CAR_SAFE in the shim.

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declaration for the CAR_SAFE wrapper
extern "c" fn zig_CAR_SAFE(obj: Lisp_Object) Lisp_Object;

// Export the Zig implementation as zig_car_safe
// This will be called from the C dispatcher in data.c
export fn zig_car_safe(object: Lisp_Object) Lisp_Object {
    return zig_CAR_SAFE(object);
}
