/* zig_spike_glue.c - C glue for Phase-1 Zig interop spike
   ADDITIVE/INERT spike — NOT a port. Proves C↔Zig linkage only. */

#include <config.h>
#include "lisp.h"

/* Import Zig export functions */
extern Lisp_Object zig_spike_add1 (Lisp_Object number);
extern Lisp_Object zig_spike_cons (Lisp_Object car, Lisp_Object cdr);
extern Lisp_Object zig_spike_selftest (Lisp_Object number);
extern Lisp_Object zig_spike_simple_test (Lisp_Object n);

/* Elisp primitive: zigmacs--interop-selftest
   Double-dash namespace signals internal/additive/experimental.
   Returns a list demonstrating C↔Zig interop:
   - Element 0: result of Zig calling Emacs's Fadd1 on fixnum 41 (should be 42)
   - Element 1: a cons built by Zig using Emacs's Fcons
   Tests all four proof requirements in one call. */
DEFUN ("zigmacs--interop-selftest", Fzigmacs__interop_selftest,
       Szigmacs__interop_selftest, 0, 0, 0,
       doc: /* Run the Phase-1 C↔Zig interop self-test.
Returns a list with test results:
  (SIMPLE-TEST CONS-TEST COMPLEX-TEST)
where:
  SIMPLE-TEST is the result of Zig calling Fadd1 on 41 (should be 42)
  CONS-TEST is a cons cell (99 . 100) built by Zig via Fcons
  COMPLEX-TEST is a nested cons built by Zig: (43 . (44 . 0))

This is an ADDITIVE spike to prove Zig linkage. Do not use in production. */)
  (void)
{
  Lisp_Object simple_result, cons_result, complex_result;

  /* Test 1: Simple Zig→C call (Zig calls Fadd1) */
  simple_result = zig_spike_simple_test (make_fixnum (41));

  /* Test 2: Zig builds a cons using Fcons */
  cons_result = zig_spike_cons (make_fixnum (99), make_fixnum (100));

  /* Test 3: Complex test (Zig calls Fadd1 multiple times and builds nested cons) */
  complex_result = zig_spike_selftest (make_fixnum (42));

  /* Return results as a list */
  return list3 (simple_result, cons_result, complex_result);
}

/* Register the primitive */
void
syms_of_zig_spike (void)
{
  defsubr (&Szigmacs__interop_selftest);
}
