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
#include "process.h"
#include "coding.h"
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

/* === Number operations === */

bool
zig_NUMBERP (Lisp_Object obj)
{
  return NUMBERP (obj);
}

bool
zig_INTEGERP (Lisp_Object obj)
{
  return INTEGERP (obj);
}

bool
zig_FLOATP (Lisp_Object obj)
{
  return FLOATP (obj);
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

bool
zig_STRINGP (Lisp_Object obj)
{
  return STRINGP (obj);
}

Lisp_Object
zig_build_string (const char *str)
{
  return build_string (str);
}

char *
zig_SSDATA (Lisp_Object string)
{
  return SSDATA (string);
}

void
zig_CHECK_STRING (Lisp_Object x)
{
  CHECK_STRING (x);
}

/* === Vector operations === */

bool
zig_VECTORP (Lisp_Object obj)
{
  return VECTORP (obj);
}

/* === Process operations === */

bool
zig_PROCESSP (Lisp_Object obj)
{
  return PROCESSP (obj);
}

/* === Coding system operations === */

int
zig_CODING_SYSTEM_ID (Lisp_Object obj)
{
  return CODING_SYSTEM_ID (obj);
}

Lisp_Object
zig_Fget (Lisp_Object symbol, Lisp_Object propname)
{
  return Fget (symbol, propname);
}

Lisp_Object
zig_Qcoding_system_define_form (void)
{
  return Qcoding_system_define_form;
}
