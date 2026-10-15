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
extern Lisp_Object zig_build_string (const char *str);

#endif /* ZIG_SHIM_H */
