// Port of Fwindow_live_p from src/window.c
// Returns t if OBJECT is a live window, nil otherwise
//
// Upstream C:
//   return WINDOW_LIVE_P (object) ? Qt : Qnil;
//
// Behavior: bug-for-bug identical to upstream
// - Live window (displays a buffer) → Qt
// - Deleted or internal window → Qnil
// - Non-window → Qnil
// - Pure function (const attribute, no side effects)

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declarations for shim functions (macro/inline API wrappers)
extern "c" fn zig_WINDOW_LIVE_P(obj: Lisp_Object) bool;
extern "c" fn zig_Qnil() Lisp_Object;
extern "c" fn zig_Qt() Lisp_Object;

// Export the Zig implementation as zig_window_live_p
// This will be called from the C dispatcher in window.c
export fn zig_window_live_p(object: Lisp_Object) Lisp_Object {
    // Match upstream logic exactly:
    // return WINDOW_LIVE_P (object) ? Qt : Qnil;

    if (zig_WINDOW_LIVE_P(object)) {
        // Object is a live window → return Qt
        return zig_Qt();
    } else {
        // Object is not a live window → return Qnil
        return zig_Qnil();
    }
}
