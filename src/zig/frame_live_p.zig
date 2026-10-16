// Port of Fframe_live_p from src/frame.c
// Returns non-nil if OBJECT is a live frame, nil otherwise
//
// Upstream C:
//   return ((FRAMEP (object) && FRAME_LIVE_P (XFRAME (object)))
//           ? Fframep (object) : Qnil);
//
// Behavior: bug-for-bug identical to upstream
// - Live frame → return value from Fframep (indicates terminal type)
// - Deleted frame or non-frame → Qnil
// - Pure function (const attribute, no side effects)

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Opaque type for struct frame
const Frame = opaque {};

// Extern declarations for shim functions (macro/inline API wrappers)
extern "c" fn zig_FRAMEP(obj: Lisp_Object) bool;
extern "c" fn zig_XFRAME(obj: Lisp_Object) *Frame;
extern "c" fn zig_FRAME_LIVE_P(f: *Frame) bool;
extern "c" fn zig_Fframep(obj: Lisp_Object) Lisp_Object;
extern "c" fn zig_Qnil() Lisp_Object;

// Export the Zig implementation as zig_frame_live_p
// This will be called from the C dispatcher in frame.c
export fn zig_frame_live_p(object: Lisp_Object) Lisp_Object {
    // Match upstream logic exactly:
    // return ((FRAMEP (object) && FRAME_LIVE_P (XFRAME (object)))
    //         ? Fframep (object) : Qnil);

    if (zig_FRAMEP(object) and zig_FRAME_LIVE_P(zig_XFRAME(object))) {
        // Object is a live frame → return Fframep result (terminal type)
        return zig_Fframep(object);
    } else {
        // Object is not a frame or is a deleted frame → return Qnil
        return zig_Qnil();
    }
}
