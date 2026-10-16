/* C shim layer prototypes for Zig ports */

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

#endif /* ZIG_SHIM_H */
