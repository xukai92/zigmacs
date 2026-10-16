// Port of Fwindow_valid_p from src/window.c
// Returns t if OBJECT is a valid window, nil otherwise
//
// Upstream C:
//   return WINDOW_VALID_P (object) ? Qt : Qnil;
//
// Behavior: bug-for-bug identical to upstream
// - Valid window (displays a buffer or is internal) → Qt
// - Deleted window → Qnil
// - Non-window → Qnil
// - Pure function (const attribute, no side effects)

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declarations for shim functions (macro/inline API wrappers)
extern "c" fn zig_WINDOW_VALID_P(obj: Lisp_Object) bool;
extern "c" fn zig_Qt() Lisp_Object;
extern "c" fn zig_Qnil() Lisp_Object;

// Export the Zig implementation as zig_window_valid_p
// This will be called from the C dispatcher in window.c
export fn zig_window_valid_p(object: Lisp_Object) Lisp_Object {
    // Match upstream logic exactly:
    // return WINDOW_VALID_P (object) ? Qt : Qnil;

    if (zig_WINDOW_VALID_P(object)) {
        // Object is a valid window → return Qt
        return zig_Qt();
    } else {
        // Object is not a valid window → return Qnil
        return zig_Qnil();
    }
}
