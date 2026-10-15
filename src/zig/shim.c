/* C shim layer for Zig ports
   Exposes Emacs macro/inline/GMP API as linkable functions for Zig extern calls.

   This is the SHARED shim for all Zig ports. Each wrapper follows the pattern:
   - Prefix: zig_
   - Name: matches the original macro/inline name
   - Body: thin wrapper, typically one line

   Rationale: Zig 0.17.0 has no @cImport; translate-c crashes on lisp.h.
   This shim exposes the macro-based API as callable symbols. */

#include <config.h>
#include "lisp.h"
#include "bignum.h"
#include "zig/shim.h"

/* === Fixnum operations (inline/macro in lisp.h) === */

bool
zig_FIXNUMP (Lisp_Object obj)
{
  return FIXNUMP (obj);
}

intptr_t
zig_XFIXNUM (Lisp_Object obj)
{
  return XFIXNUM (obj);
}

Lisp_Object
zig_make_fixnum (intptr_t n)
{
  return make_fixnum (n);
}

/* === Bignum operations === */

bool
zig_BIGNUMP (Lisp_Object obj)
{
  return BIGNUMP (obj);
}

/* Wrapper for "0 <= mpz_sgn (*xbignum_val (obj))"
   Returns true if bignum is nonnegative (>= 0).
   PRECONDITION: obj must be a bignum (caller must check BIGNUMP first). */
bool
zig_bignum_nonnegative (Lisp_Object obj)
{
  return 0 <= mpz_sgn (*xbignum_val (obj));
}

/* === Nil and Qt === */

Lisp_Object
zig_Qnil (void)
{
  return Qnil;
}

Lisp_Object
zig_Qt (void)
{
  return Qt;
}

bool
zig_NILP (Lisp_Object obj)
{
  return NILP (obj);
}

/* === Cons operations === */

bool
zig_CONSP (Lisp_Object obj)
{
  return CONSP (obj);
}

Lisp_Object
zig_XCAR (Lisp_Object cons)
{
  return XCAR (cons);
}

Lisp_Object
zig_XCDR (Lisp_Object cons)
{
  return XCDR (cons);
}

/* === Symbol operations === */

bool
zig_SYMBOLP (Lisp_Object obj)
{
  return SYMBOLP (obj);
}

/* === String operations === */

Lisp_Object
zig_build_string (const char *str)
{
  return build_string (str);
}
