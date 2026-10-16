// Port of Fsubrp from src/data.c:1192
// Returns t if OBJECT is a built-in or native compiled Lisp function, nil otherwise
//
// Upstream C:
//   if (SUBRP (object))
//     return Qt;
//   return Qnil;
//
// Behavior: bug-for-bug identical to upstream
// - Built-in function (car, cdr, etc.) → Qt
// - Native compiled function → Qt
// - Anything else (cons, integer, string, etc.) → Qnil
// - Pure function (const attribute, no side effects)

// === Inline Emacs bindings (no module system in Zig 0.17.0) ===

// Lisp_Object type - matches Emacs's definition on 64-bit USE_LSB_TAG builds
pub const Lisp_Object = extern struct {
    value: usize,
};

// Extern declarations for shim functions (macro/inline API wrappers)
extern "c" fn zig_SUBRP(obj: Lisp_Object) bool;
extern "c" fn zig_Qnil() Lisp_Object;
extern "c" fn zig_Qt() Lisp_Object;

// Export the Zig implementation as zig_subrp
// This will be called from the C dispatcher in data.c
export fn zig_subrp(object: Lisp_Object) Lisp_Object {
    // Match upstream logic exactly:
    // if (SUBRP (object))
    //   return Qt;
    // return Qnil;

    if (zig_SUBRP(object)) {
        // Object is a subr (built-in/native function) → return Qt
        return zig_Qt();
    } else {
        // Object is not a subr → return Qnil
        return zig_Qnil();
    }
}
