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
extern char *zig_SSDATA (Lisp_Object string);
extern void zig_CHECK_STRING (Lisp_Object x);

/* Vector operations */
extern bool zig_VECTORP (Lisp_Object obj);

/* Process operations */
extern bool zig_PROCESSP (Lisp_Object obj);

/* Coding system operations */
extern int zig_CODING_SYSTEM_ID (Lisp_Object obj);
extern Lisp_Object zig_Fget (Lisp_Object symbol, Lisp_Object propname);
extern Lisp_Object zig_Qcoding_system_define_form (void);

#endif /* ZIG_SHIM_H */
