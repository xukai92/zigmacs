/* C glue for Phase-2 @cImport spike
   CRITICAL ARCHITECTURAL FINDING documented here.

   Zig 0.17.0 REMOVED @cImport (deprecated in 0.16).
   zig translate-c CRASHES (SEGV) when run on Emacs's lisp.h.

   VIABLE BINDING STRATEGY for the incremental port:
   - C shim layer (zig_cimport_spike_shim.c) exposes macro/inline API as functions
   - Zig code uses extern declarations to call shims + real Emacs functions
   - Type-exact via matching Lisp_Object representation

   This is ADDITIVE/INERT spike — NOT a port. */

#include <config.h>
#include "lisp.h"

/* Import Zig export function */
extern Lisp_Object zig_cimport_selftest (void);

/* Elisp primitive: zigmacs--cimport-selftest
   Tests the C shim binding strategy with REAL Emacs API.

   Returns: (42 (99 . 100) nil t)

   Proves:
   - Zig can call real Emacs functions (Fcons, list3) directly
   - Zig can access macro/inline API (make_fixnum, XFIXNUM, CONSP, etc.) via shims
   - Type correctness through Lisp_Object round-trips
   - The scalable binding strategy for the incremental port */
DEFUN ("zigmacs--cimport-selftest", Fzigmacs__cimport_selftest,
       Szigmacs__cimport_selftest, 0, 0, 0,
       doc: /* Run the Phase-2 @cImport binding strategy self-test.

Returns a list demonstrating Zig calling real Emacs API via C shims:
  (42 (99 . 100) nil t)

CRITICAL FINDING: Zig 0.17.0 removed @cImport; translate-c crashes on lisp.h.
The viable binding strategy is: Zig extern → C shim → Emacs macro/inline API.

This is an ADDITIVE spike to prove binding strategy. Not for production. */)
  (void)
{
  return zig_cimport_selftest ();
}

/* Register the primitive */
void
syms_of_zig_cimport_spike (void)
{
  defsubr (&Szigmacs__cimport_selftest);
}
