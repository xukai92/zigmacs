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
#include "character.h"
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

/* === Vector operations === */

bool
zig_VECTORP (Lisp_Object obj)
{
  return VECTORP (obj);
}

/* === Bare symbol operations === */

bool
zig_BARE_SYMBOL_P (Lisp_Object obj)
{
  return BARE_SYMBOL_P (obj);
}

/* === Character operations === */

bool
zig_CHARACTERP (Lisp_Object obj)
{
  return CHARACTERP (obj);
intptr_t
zig_ASIZE (Lisp_Object obj)
{
  return ASIZE (obj);
}

/* === String operations === */

intptr_t
zig_SCHARS (Lisp_Object obj)
{
  return SCHARS (obj);
}

/* === Sequence type checks === */

bool
zig_CHAR_TABLE_P (Lisp_Object obj)
{
  return CHAR_TABLE_P (obj);
}

bool
zig_BOOL_VECTOR_P (Lisp_Object obj)
{
  return BOOL_VECTOR_P (obj);
}

bool
zig_CLOSUREP (Lisp_Object obj)
{
  return CLOSUREP (obj);
}

bool
zig_RECORDP (Lisp_Object obj)
{
  return RECORDP (obj);
}

/* === Sequence size operations === */

intptr_t
zig_PVSIZE (Lisp_Object obj)
{
  return PVSIZE (obj);
}

intptr_t
zig_MAX_CHAR (void)
{
  return MAX_CHAR;
}

intptr_t
zig_bool_vector_size (Lisp_Object obj)
{
  return bool_vector_size (obj);
}

/* === List operations === */

intptr_t
zig_list_length (Lisp_Object list)
{
  return list_length (list);
}

/* === Equality === */

bool
zig_EQ (Lisp_Object obj1, Lisp_Object obj2)
{
  return EQ (obj1, obj2);
}

bool
zig_BASE_EQ (Lisp_Object obj1, Lisp_Object obj2)
{
  return BASE_EQ (obj1, obj2);
}

/* === Helper functions for list traversal === */

/* Helper for memq: search for ELT in LIST using eq comparison.
   Returns the tail of LIST whose car is ELT, or Qnil if not found.
   Signals error on circular or improper list. */
Lisp_Object
zig_memq_helper (Lisp_Object elt, Lisp_Object list)
{
  Lisp_Object tail = list;
  FOR_EACH_TAIL (tail)
    if (EQ (XCAR (tail), elt))
      return tail;
  CHECK_LIST_END (tail, list);
  return Qnil;
}

/* Helper for assq: search for KEY in association list ALIST.
   Returns the first element of ALIST whose car is KEY, or Qnil if not found.
   Ignores non-cons elements in the alist.
   Signals error on circular or improper list. */
Lisp_Object
zig_assq_helper (Lisp_Object key, Lisp_Object alist)
{
  Lisp_Object tail = alist;
  FOR_EACH_TAIL (tail)
    if (CONSP (XCAR (tail)) && EQ (XCAR (XCAR (tail)), key))
      return XCAR (tail);
  CHECK_LIST_END (tail, alist);
  return Qnil;
}
