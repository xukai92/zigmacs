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

/* --- Fan-out round #2 wrappers --- */

/* Cat A: function predicate */
extern bool zig_FUNCTIONP (Lisp_Object obj);

/* Cat B: list / sequence primitives */
extern Lisp_Object zig_CAR_SAFE (Lisp_Object obj);
extern Lisp_Object zig_CDR_SAFE (Lisp_Object obj);
extern Lisp_Object zig_Fcar (Lisp_Object list);
extern Lisp_Object zig_Fnthcdr (Lisp_Object n, Lisp_Object list);
extern intptr_t zig_safe_length_count (Lisp_Object list);

/* Cat C: byte fetch at buffer position (read-only point preds) */
extern int zig_FETCH_BYTE (ptrdiff_t n);

/* Cat H1: liveness / keymap predicates */
extern struct buffer *zig_XBUFFER (Lisp_Object obj);
extern bool zig_BUFFER_LIVE_P (struct buffer *b);
extern bool zig_KEYMAPP (Lisp_Object obj);
extern bool zig_WINDOW_LIVE_P (Lisp_Object obj);

/* --- Fan-out round #3 wrappers --- */

/* Cat B: elt / proper-list-p / rassq */
extern void zig_CHECK_ARRAY (Lisp_Object x, Lisp_Object predicate);
extern Lisp_Object zig_Faref (Lisp_Object array, Lisp_Object idx);
extern Lisp_Object zig_Qsequencep (void);
extern Lisp_Object zig_proper_list_p_full (Lisp_Object object);
extern Lisp_Object zig_rassq_helper (Lisp_Object key, Lisp_Object alist);

/* Cat C: point movers (stateful, snapshot→replay) */
extern Lisp_Object zig_move_point (Lisp_Object n, bool forward);
extern void zig_CHECK_INTEGER (Lisp_Object x);
extern Lisp_Object zig_Fnatnump (Lisp_Object x);
extern intptr_t zig_BUF_BYTES_MAX (void);
extern void zig_SET_PT_BOTH (ptrdiff_t position, ptrdiff_t byte);
extern Lisp_Object zig_call_Fplus2 (Lisp_Object a, Lisp_Object b);

/* Cat H1: frame/window liveness + file-name string ops */
extern struct frame *zig_XFRAME (Lisp_Object obj);
extern bool zig_FRAME_LIVE_P (struct frame *f);
extern Lisp_Object zig_Fframep (Lisp_Object obj);
extern bool zig_WINDOW_VALID_P (Lisp_Object obj);
extern Lisp_Object zig_make_specified_string (const char *contents,
					      ptrdiff_t nchars,
					      ptrdiff_t nbytes, bool multibyte);
extern bool zig_IS_DIRECTORY_SEP (int c);
extern bool zig_STRING_MULTIBYTE (Lisp_Object str);
extern Lisp_Object zig_Ffind_file_name_handler (Lisp_Object filename,
						Lisp_Object operation);
extern Lisp_Object zig_call2 (Lisp_Object fn, Lisp_Object arg1,
			      Lisp_Object arg2);
extern Lisp_Object zig_Qfile_name_nondirectory (void);
extern void zig_error_invalid_file_handler (void);

/* --- Fan-out round #4 wrappers --- */

/* Cat A: keywordp */
extern Lisp_Object zig_SYMBOL_NAME (Lisp_Object sym);
extern bool zig_SYMBOL_INTERNED_IN_INITIAL_OBARRAY_P (Lisp_Object sym);

/* Cat B: member / assoc */
extern Lisp_Object zig_Fmemq (Lisp_Object elt, Lisp_Object list);
extern Lisp_Object zig_Fassq (Lisp_Object key, Lisp_Object alist);
extern Lisp_Object zig_member_equal_helper (Lisp_Object elt, Lisp_Object list);
extern Lisp_Object zig_assoc_helper (Lisp_Object key, Lisp_Object alist,
				     Lisp_Object testfn);

/* Cat C: beginning-of-line / end-of-line (point movers) */
extern void zig_CHECK_FIXNUM (Lisp_Object x);
extern Lisp_Object zig_Fline_beginning_position (Lisp_Object n);
extern Lisp_Object zig_Fline_end_position (Lisp_Object n);

/* Cat H: file-name-directory */
extern Lisp_Object zig_file_name_directory (Lisp_Object filename);
extern Lisp_Object zig_Qfile_name_directory (void);

#endif /* ZIG_SHIM_H */
