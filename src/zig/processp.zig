// Port of Fprocessp from src/process.c
// Returns t if OBJECT is a process, nil otherwise
//
// Upstream C:
//   return PROCESSP (object) ? Qt : Qnil;
//
// Behavior: bug-for-bug identical to upstream
// - Process object → Qt
// - All other types (nil, symbols, numbers, strings, etc.) → Qnil
// - Pure function (const attribute, no side effects)

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declarations for shim functions (macro/inline API wrappers)
extern "c" fn zig_PROCESSP(obj: Lisp_Object) bool;
extern "c" fn zig_Qnil() Lisp_Object;
extern "c" fn zig_Qt() Lisp_Object;

// Export the Zig implementation as zig_processp
// This will be called from the C dispatcher in process.c
export fn zig_processp(object: Lisp_Object) Lisp_Object {
    // Match upstream logic exactly:
    // return PROCESSP (object) ? Qt : Qnil;

    if (zig_PROCESSP(object)) {
        // Object is a process → return Qt
        return zig_Qt();
    } else {
        // Object is not a process → return Qnil
        return zig_Qnil();
    }
}
