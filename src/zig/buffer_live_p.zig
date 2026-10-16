// Port of Fbuffer_live_p from src/buffer.c
// Returns t if OBJECT is a buffer which has not been killed, nil otherwise
//
// Upstream C:
//   return ((BUFFERP (object) && BUFFER_LIVE_P (XBUFFER (object)))
//           ? Qt : Qnil);
//
// Behavior: bug-for-bug identical to upstream
// - Live buffer → Qt
// - Killed buffer → Qnil
// - Non-buffer → Qnil
// - Pure function (const attribute, no side effects)

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Opaque type for struct buffer
const Buffer = opaque {};

// Extern declarations for shim functions (macro/inline API wrappers)
extern "c" fn zig_BUFFERP(obj: Lisp_Object) bool;
extern "c" fn zig_XBUFFER(obj: Lisp_Object) *Buffer;
extern "c" fn zig_BUFFER_LIVE_P(b: *Buffer) bool;
extern "c" fn zig_Qnil() Lisp_Object;
extern "c" fn zig_Qt() Lisp_Object;

// Export the Zig implementation as zig_buffer_live_p
// This will be called from the C dispatcher in buffer.c
export fn zig_buffer_live_p(object: Lisp_Object) Lisp_Object {
    // Match upstream logic exactly:
    // return ((BUFFERP (object) && BUFFER_LIVE_P (XBUFFER (object)))
    //         ? Qt : Qnil);

    if (zig_BUFFERP(object) and zig_BUFFER_LIVE_P(zig_XBUFFER(object))) {
        // Object is a live buffer → return Qt
        return zig_Qt();
    } else {
        // Object is not a buffer or is a killed buffer → return Qnil
        return zig_Qnil();
    }
}
