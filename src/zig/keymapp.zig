// Port of Fkeymapp from src/keymap.c
// Returns t if OBJECT is a keymap, nil otherwise
//
// Upstream C:
//   return (KEYMAPP (object) ? Qt : Qnil);
//
// Behavior: bug-for-bug identical to upstream
// - Keymap object → Qt
// - Symbol whose function definition is a keymap → Qt (KEYMAPP handles this)
// - All other types → Qnil
// - Pure function (const attribute, no side effects)

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declarations for shim functions (macro/inline API wrappers)
extern "c" fn zig_KEYMAPP(obj: Lisp_Object) bool;
extern "c" fn zig_Qnil() Lisp_Object;
extern "c" fn zig_Qt() Lisp_Object;

// Export the Zig implementation as zig_keymapp
// This will be called from the C dispatcher in keymap.c
export fn zig_keymapp(object: Lisp_Object) Lisp_Object {
    // Match upstream logic exactly:
    // return (KEYMAPP (object) ? Qt : Qnil);

    if (zig_KEYMAPP(object)) {
        // Object is a keymap → return Qt
        return zig_Qt();
    } else {
        // Object is not a keymap → return Qnil
        return zig_Qnil();
    }
}
