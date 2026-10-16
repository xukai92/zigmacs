/* C shim layer prototypes for Zig ports

   CORE SHIM — orchestrator-owned. Port agents use these read-only;
   if a wrapper is missing, REPORT it for addition here — do NOT edit
   this file in parallel worktrees (it would create merge conflicts). */

#ifndef ZIG_SHIM_H
#define ZIG_SHIM_H

#include "lisp.h"

/* Fixnum operations */
extern bool zig_FIXNUMP (Lisp_Object obj);
extern intptr_t zig_XFIXNUM (Lisp_Object obj);
extern Lisp_Object zig_make_fixnum (intptr_t n);

/* Bignum operations */
extern bool zig_BIGNUMP (Lisp_Object obj);
extern bool zig_bignum_nonnegative (Lisp_Object obj);

/* Number operations */
extern bool zig_NUMBERP (Lisp_Object obj);
extern bool zig_INTEGERP (Lisp_Object obj);
extern bool zig_FLOATP (Lisp_Object obj);

/* Nil and Qt */
extern Lisp_Object zig_Qnil (void);
extern Lisp_Object zig_Qt (void);
extern bool zig_NILP (Lisp_Object obj);

/* Cons operations */
extern bool zig_CONSP (Lisp_Object obj);
extern Lisp_Object zig_XCAR (Lisp_Object cons);
extern Lisp_Object zig_XCDR (Lisp_Object cons);

/* Symbol operations */
extern bool zig_SYMBOLP (Lisp_Object obj);

/* String operations */
extern bool zig_STRINGP (Lisp_Object obj);
extern Lisp_Object zig_build_string (const char *str);
extern char *zig_SSDATA (Lisp_Object string);
extern void zig_CHECK_STRING (Lisp_Object x);

/* Vector operations */
extern bool zig_VECTORP (Lisp_Object obj);
extern intptr_t zig_ASIZE (Lisp_Object obj);

/* String operations */
extern intptr_t zig_SCHARS (Lisp_Object obj);

/* Sequence type checks */
extern bool zig_CHAR_TABLE_P (Lisp_Object obj);
extern bool zig_BOOL_VECTOR_P (Lisp_Object obj);
extern bool zig_CLOSUREP (Lisp_Object obj);
extern bool zig_RECORDP (Lisp_Object obj);

/* Sequence size operations */
extern intptr_t zig_PVSIZE (Lisp_Object obj);
extern intptr_t zig_MAX_CHAR (void);
extern intptr_t zig_bool_vector_size (Lisp_Object obj);

/* List operations */
extern intptr_t zig_list_length (Lisp_Object list);

/* Equality */
extern bool zig_EQ (Lisp_Object obj1, Lisp_Object obj2);
extern bool zig_BASE_EQ (Lisp_Object obj1, Lisp_Object obj2);

/* Error signaling - these are extern C functions, not shims */
/* (declared here for Zig's use) */

/* Helper functions for list traversal with circular detection */
/* Returns: tail of list where element found, or Qnil if not found.
   Signals error on circular or improper list. */
extern Lisp_Object zig_memq_helper (Lisp_Object elt, Lisp_Object list);
extern Lisp_Object zig_assq_helper (Lisp_Object key, Lisp_Object alist);

/* Bare symbol operations */
extern bool zig_BARE_SYMBOL_P (Lisp_Object obj);

/* Character operations */
extern bool zig_CHARACTERP (Lisp_Object obj);

/* Process operations */
extern bool zig_PROCESSP (Lisp_Object obj);

/* Coding system operations */
extern int zig_CODING_SYSTEM_ID (Lisp_Object obj);
extern Lisp_Object zig_Fget (Lisp_Object symbol, Lisp_Object propname);
extern Lisp_Object zig_Qcoding_system_define_form (void);

/* Additional type predicates */
extern bool zig_ARRAYP (Lisp_Object obj);
extern bool zig_HASH_TABLE_P (Lisp_Object obj);
extern bool zig_MARKERP (Lisp_Object obj);
extern bool zig_BUFFERP (Lisp_Object obj);
extern bool zig_WINDOWP (Lisp_Object obj);
extern bool zig_FRAMEP (Lisp_Object obj);
extern bool zig_OVERLAYP (Lisp_Object obj);
extern bool zig_SUBRP (Lisp_Object obj);
extern bool zig_VECTORLIKEP (Lisp_Object obj);

/* Additional accessors */
extern ptrdiff_t zig_SBYTES (Lisp_Object string);
extern unsigned char zig_SREF (Lisp_Object string, ptrdiff_t index);
extern unsigned char *zig_SDATA (Lisp_Object string);
extern Lisp_Object zig_AREF (Lisp_Object array, ptrdiff_t idx);
extern double zig_XFLOAT_DATA (Lisp_Object f);

/* Buffer and point accessors (Category C ports) */
extern ptrdiff_t zig_PT (void);
extern ptrdiff_t zig_PT_BYTE (void);
extern ptrdiff_t zig_BEGV (void);
extern ptrdiff_t zig_ZV (void);
extern ptrdiff_t zig_ZV_BYTE (void);
extern void zig_SET_PT (ptrdiff_t position);
extern struct buffer *zig_current_buffer (void);

/* Symbol accessors (for type error reporting) */
extern Lisp_Object zig_Qinteger_or_marker_p (void);

#endif /* ZIG_SHIM_H */
