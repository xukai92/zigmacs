/* C shim layer for @cImport spike
   Exposes Emacs macro/inline API as linkable functions for Zig extern calls.

   CRITICAL FINDING: Zig 0.17.0 removed @cImport; translate-c crashes on lisp.h.
   This shim proves the viable binding strategy: C wrappers for macro-based API. */

#include <config.h>
#include "lisp.h"

/* Fixnum operations - these are inline/macro in lisp.h */

Lisp_Object
zig_shim_make_fixnum (intptr_t n)
{
  return make_fixnum (n);
}

intptr_t
zig_shim_XFIXNUM (Lisp_Object obj)
{
  return XFIXNUM (obj);
}

bool
zig_shim_FIXNUMP (Lisp_Object obj)
{
  return FIXNUMP (obj);
}

/* Cons operations */

bool
zig_shim_CONSP (Lisp_Object obj)
{
  return CONSP (obj);
}

Lisp_Object
zig_shim_XCAR (Lisp_Object cons)
{
  return XCAR (cons);
}

Lisp_Object
zig_shim_XCDR (Lisp_Object cons)
{
  return XCDR (cons);
}

/* Nil and predicates */

Lisp_Object
zig_shim_Qnil (void)
{
  return Qnil;
}

Lisp_Object
zig_shim_Qt (void)
{
  return Qt;
}

bool
zig_shim_NILP (Lisp_Object obj)
{
  return NILP (obj);
}

/* Symbol operations */

bool
zig_shim_SYMBOLP (Lisp_Object obj)
{
  return SYMBOLP (obj);
}

/* String operations */

Lisp_Object
zig_shim_build_string (const char *str)
{
  return build_string (str);
}
