/* C shim layer for Zig ports
   Exposes Emacs macro/inline/GMP API as linkable functions for Zig extern calls.

   CORE SHIM — orchestrator-owned. Port agents use these read-only;
   if a wrapper is missing, REPORT it for addition here — do NOT edit
   this file in parallel worktrees (it would create merge conflicts).

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
#include "process.h"
#include "coding.h"
#include "buffer.h"
#include "window.h"
#include "keymap.h"
#include "frame.h"
#include "zig/shim.h"

/* move_point: de-static'd in cmds.c (prototype in lisp.h) so the Cat-C
   forward/backward-char Zig ports can call it via zig_move_point. */

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
}

/* === Array / sequence size operations === */

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

/* === Additional type predicates === */

bool
zig_ARRAYP (Lisp_Object obj)
{
  return ARRAYP (obj);
}

bool
zig_HASH_TABLE_P (Lisp_Object obj)
{
  return HASH_TABLE_P (obj);
}

bool
zig_MARKERP (Lisp_Object obj)
{
  return MARKERP (obj);
}

bool
zig_BUFFERP (Lisp_Object obj)
{
  return BUFFERP (obj);
}

bool
zig_WINDOWP (Lisp_Object obj)
{
  return WINDOWP (obj);
}

bool
zig_FRAMEP (Lisp_Object obj)
{
  return FRAMEP (obj);
}

bool
zig_OVERLAYP (Lisp_Object obj)
{
  return OVERLAYP (obj);
}

bool
zig_SUBRP (Lisp_Object obj)
{
  return SUBRP (obj);
}

bool
zig_VECTORLIKEP (Lisp_Object obj)
{
  return VECTORLIKEP (obj);
}

/* === Additional accessors === */

ptrdiff_t
zig_SBYTES (Lisp_Object string)
{
  return SBYTES (string);
}

unsigned char
zig_SREF (Lisp_Object string, ptrdiff_t index)
{
  return SREF (string, index);
}

unsigned char *
zig_SDATA (Lisp_Object string)
{
  return SDATA (string);
}

Lisp_Object
zig_AREF (Lisp_Object array, ptrdiff_t idx)
{
  return AREF (array, idx);
}

double
zig_XFLOAT_DATA (Lisp_Object f)
{
  return XFLOAT_DATA (f);
}

/* === Buffer and point accessors (Category C ports) === */

ptrdiff_t
zig_PT (void)
{
  return PT;
}

ptrdiff_t
zig_PT_BYTE (void)
{
  return PT_BYTE;
}

ptrdiff_t
zig_BEGV (void)
{
  return BEGV;
}

ptrdiff_t
zig_ZV (void)
{
  return ZV;
}

ptrdiff_t
zig_ZV_BYTE (void)
{
  return ZV_BYTE;
}

void
zig_SET_PT (ptrdiff_t position)
{
  SET_PT (position);
}

struct buffer *
zig_current_buffer (void)
{
  return current_buffer;
}

/* === Symbol accessors (for type error reporting) === */

Lisp_Object
zig_Qinteger_or_marker_p (void)
{
  return Qinteger_or_marker_p;
}

/* ============================================================
   Fan-out round #2 wrappers (added solo by orchestrator).
   ============================================================ */

/* === Cat A: function predicate (eval.c Ffunctionp) === */

bool
zig_FUNCTIONP (Lisp_Object obj)
{
  return FUNCTIONP (obj);
}

/* === Cat B: list / sequence primitives (data.c, fns.c) === */

Lisp_Object
zig_CAR_SAFE (Lisp_Object obj)
{
  return CAR_SAFE (obj);
}

Lisp_Object
zig_CDR_SAFE (Lisp_Object obj)
{
  return CDR_SAFE (obj);
}

Lisp_Object
zig_Fcar (Lisp_Object list)
{
  return Fcar (list);
}

Lisp_Object
zig_Fnthcdr (Lisp_Object n, Lisp_Object list)
{
  return Fnthcdr (n, list);
}

/* Helper for safe-length: counts list length via FOR_EACH_TAIL_SAFE.
   Never errors; for a circular list returns at least the number of
   distinct elements.  Caller (Zig) wraps result in make_fixnum. */
intptr_t
zig_safe_length_count (Lisp_Object list)
{
  intptr_t len = 0;
  FOR_EACH_TAIL_SAFE (list)
    len++;
  return len;
}

/* === Cat C: byte fetch at buffer position (read-only point preds) === */

int
zig_FETCH_BYTE (ptrdiff_t n)
{
  return FETCH_BYTE (n);
}

/* === Cat H1: liveness / keymap predicates === */

struct buffer *
zig_XBUFFER (Lisp_Object obj)
{
  return XBUFFER (obj);
}

bool
zig_BUFFER_LIVE_P (struct buffer *b)
{
  return BUFFER_LIVE_P (b);
}

bool
zig_KEYMAPP (Lisp_Object obj)
{
  return KEYMAPP (obj);
}

bool
zig_WINDOW_LIVE_P (Lisp_Object obj)
{
  return WINDOW_LIVE_P (obj);
}

/* ============================================================
   Fan-out round #3 wrappers (added solo by orchestrator).
   ============================================================ */

/* === Cat B: elt / proper-list-p / rassq (fns.c) === */

void
zig_CHECK_ARRAY (Lisp_Object x, Lisp_Object predicate)
{
  CHECK_ARRAY (x, predicate);
}

Lisp_Object
zig_Faref (Lisp_Object array, Lisp_Object idx)
{
  return Faref (array, idx);
}

Lisp_Object
zig_Qsequencep (void)
{
  return Qsequencep;
}

/* Full impl of proper-list-p's traversal (FOR_EACH_TAIL_SAFE + rarely_quit
   cycle/quit handling is complex; mirror upstream exactly here).
   Returns make_fixnum(len) for a proper list, else Qnil. */
Lisp_Object
zig_proper_list_p_full (Lisp_Object object)
{
  intptr_t len = 0;
  Lisp_Object last_tail = object;
  Lisp_Object tail = object;
  FOR_EACH_TAIL_SAFE (tail)
    {
      len++;
      rarely_quit (len);
      last_tail = XCDR (tail);
    }
  if (!NILP (last_tail))
    return Qnil;
  return make_fixnum (len);
}

/* Helper for rassq: FOR_EACH_TAIL + CHECK_LIST_END (cycle/improper detection).
   Returns first element of ALIST whose cdr is `eq' to KEY, or Qnil. */
Lisp_Object
zig_rassq_helper (Lisp_Object key, Lisp_Object alist)
{
  Lisp_Object tail = alist;
  FOR_EACH_TAIL (tail)
    if (CONSP (XCAR (tail)) && EQ (XCDR (XCAR (tail)), key))
      return XCAR (tail);
  CHECK_LIST_END (tail, alist);
  return Qnil;
}

/* === Cat C: point movers (cmds.c) — stateful, snapshot→replay === */

Lisp_Object
zig_move_point (Lisp_Object n, bool forward)
{
  return move_point (n, forward);
}

void
zig_CHECK_INTEGER (Lisp_Object x)
{
  CHECK_INTEGER (x);
}

Lisp_Object
zig_Fnatnump (Lisp_Object x)
{
  return Fnatnump (x);
}

intptr_t
zig_BUF_BYTES_MAX (void)
{
  return BUF_BYTES_MAX;
}

void
zig_SET_PT_BOTH (ptrdiff_t position, ptrdiff_t byte)
{
  SET_PT_BOTH (position, byte);
}

/* forward-line's `excessive` path computes CALLN (Fplus, make_fixnum (…), n). */
Lisp_Object
zig_call_Fplus2 (Lisp_Object a, Lisp_Object b)
{
  return CALLN (Fplus, a, b);
}

/* === Cat H1: frame/window liveness + file-name string ops === */

struct frame *
zig_XFRAME (Lisp_Object obj)
{
  return XFRAME (obj);
}

bool
zig_FRAME_LIVE_P (struct frame *f)
{
  return FRAME_LIVE_P (f);
}

Lisp_Object
zig_Fframep (Lisp_Object obj)
{
  return Fframep (obj);
}

bool
zig_WINDOW_VALID_P (Lisp_Object obj)
{
  return WINDOW_VALID_P (obj);
}

Lisp_Object
zig_make_specified_string (const char *contents, ptrdiff_t nchars,
			   ptrdiff_t nbytes, bool multibyte)
{
  return make_specified_string (contents, nchars, nbytes, multibyte);
}

bool
zig_IS_DIRECTORY_SEP (int c)
{
  return IS_DIRECTORY_SEP (c);
}

bool
zig_STRING_MULTIBYTE (Lisp_Object str)
{
  return STRING_MULTIBYTE (str);
}

Lisp_Object
zig_Ffind_file_name_handler (Lisp_Object filename, Lisp_Object operation)
{
  return Ffind_file_name_handler (filename, operation);
}

Lisp_Object
zig_call2 (Lisp_Object fn, Lisp_Object arg1, Lisp_Object arg2)
{
  return call2 (fn, arg1, arg2);
}

Lisp_Object
zig_Qfile_name_nondirectory (void)
{
  return Qfile_name_nondirectory;
}

/* Fixed-string error for file-name-nondirectory's invalid-handler path. */
void
zig_error_invalid_file_handler (void)
{
  error ("Invalid handler in `file-name-handler-alist'");
}

/* ============================================================
   Fan-out round #4 wrappers (added solo by orchestrator).
   ============================================================ */

/* === Cat A: keywordp (data.c) === */

Lisp_Object
zig_SYMBOL_NAME (Lisp_Object sym)
{
  return SYMBOL_NAME (sym);
}

bool
zig_SYMBOL_INTERNED_IN_INITIAL_OBARRAY_P (Lisp_Object sym)
{
  return SYMBOL_INTERNED_IN_INITIAL_OBARRAY_P (sym);
}

/* === Cat B: member / assoc (fns.c) ===
   eq_comparable_value is trivially (SYMBOLP||FIXNUMP) and is inlined in the
   Zig ports; these helpers cover the `equal`/testfn traversal + CHECK_LIST_END. */

Lisp_Object
zig_Fmemq (Lisp_Object elt, Lisp_Object list)
{
  return Fmemq (elt, list);
}

Lisp_Object
zig_Fassq (Lisp_Object key, Lisp_Object alist)
{
  return Fassq (key, alist);
}

/* member's non-eq branch: first tail whose car is `equal' to ELT, else Qnil. */
Lisp_Object
zig_member_equal_helper (Lisp_Object elt, Lisp_Object list)
{
  Lisp_Object tail = list;
  FOR_EACH_TAIL (tail)
    if (!NILP (Fequal (elt, XCAR (tail))))
      return tail;
  CHECK_LIST_END (tail, list);
  return Qnil;
}

/* assoc's non-fast branch: first alist elt whose car matches KEY (via `equal'
   or TESTFN), ignoring non-cons elements; else Qnil. */
Lisp_Object
zig_assoc_helper (Lisp_Object key, Lisp_Object alist, Lisp_Object testfn)
{
  Lisp_Object tail = alist;
  FOR_EACH_TAIL (tail)
    {
      Lisp_Object car = XCAR (tail);
      if (!CONSP (car))
	continue;
      if ((NILP (testfn)
	   ? (EQ (XCAR (car), key) || !NILP (Fequal (XCAR (car), key)))
	   : !NILP (call2 (testfn, XCAR (car), key))))
	return car;
    }
  CHECK_LIST_END (tail, alist);
  return Qnil;
}

/* === Cat C: beginning-of-line / end-of-line (cmds.c) — point movers === */

void
zig_CHECK_FIXNUM (Lisp_Object x)
{
  CHECK_FIXNUM (x);
}

Lisp_Object
zig_Fline_beginning_position (Lisp_Object n)
{
  return Fline_beginning_position (n);
}

Lisp_Object
zig_Fline_end_position (Lisp_Object n)
{
  return Fline_end_position (n);
}

/* === Cat H: file-name-directory (fileio.c) === */

Lisp_Object
zig_file_name_directory (Lisp_Object filename)
{
  return file_name_directory (filename);
}

Lisp_Object
zig_Qfile_name_directory (void)
{
  return Qfile_name_directory;
}
