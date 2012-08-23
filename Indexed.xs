/*******************************************************************************
*
* MODULE: C.xs
*
********************************************************************************
*
* DESCRIPTION: XS Interface for Tie::Hash::Indexed Perl extension module
*
********************************************************************************
*
* $Project: /Tie-Hash-Indexed $
* $Author: mhx $
* $Date: 2003/11/03 19:05:10 +0000 $
* $Revision: 4 $
* $Snapshot: /Tie-Hash-Indexed/0.02 $
* $Source: /Indexed.xs $
*
********************************************************************************
*
* Copyright (c) 2002-2003 Marcus Holland-Moritz. All rights reserved.
* This program is free software; you can redistribute it and/or modify
* it under the same terms as Perl itself.
*
*******************************************************************************/

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

/* #define THI_DEBUGGING */

typedef struct sIxLink IxLink;

struct sIxLink {
  SV     *key;
  SV     *val;
  IxLink *prev;
  IxLink *next;
};

typedef struct {
  HV     *hv;
  IxLink *root;
  IxLink *iter;
} IXHV;

#define IxLink_new(link)                                                       \
        do {                                                                   \
          Newz(0, link, 1, IxLink);                                            \
          (link)->key = NULL;                                                  \
          (link)->val = NULL;                                                  \
          (link)->prev = (link)->next = link;                                  \
        } while (0)

#define IxLink_delete(link)   Safefree(link)

#define IxLink_push(root, link)                                                \
        do {                                                                   \
          (link)->prev       = (root)->prev;                                   \
          (link)->next       = (root);                                         \
          (root)->prev->next = (link);                                         \
          (root)->prev       = (link);                                         \
        } while (0)

#define IxLink_extract(link)                                                   \
        do {                                                                   \
          (link)->prev->next = (link)->next;                                   \
          (link)->next->prev = (link)->prev;                                   \
          (link)->next       = (link);                                         \
          (link)->prev       = (link);                                         \
        } while (0)

#ifdef THI_DEBUGGING
#  define THI_DEBUG(x) debug_printf x
static void debug_printf(char *f, ...)
{
  va_list l;
  va_start(l, f);
  vfprintf(stderr, f, l);
  va_end(l);
}
#else
#  define THI_DEBUG(x)
#endif


MODULE = Tie::Hash::Indexed		PACKAGE = Tie::Hash::Indexed		

PROTOTYPES: ENABLE

IXHV *
TIEHASH(CLASS)
	char *CLASS

	CODE:
		THI_DEBUG(("IXHV::TIEHASH()\n"));

		Newz(0, RETVAL, 1, IXHV);

		RETVAL->hv   = newHV();
		RETVAL->iter = NULL;
		IxLink_new(RETVAL->root);

	OUTPUT:
		RETVAL


void
IXHV::DESTROY()
	PREINIT:
		IxLink *cur;

	CODE:
		THI_DEBUG(("IXHV::DESTROY()\n"));

		for (cur = THIS->root->next; cur != THIS->root;)
		{
		  IxLink *del = cur;
		  cur = cur->next;
		  SvREFCNT_dec(del->key);
                  if (del->val)
		    SvREFCNT_dec(del->val);
		  IxLink_delete(del);
		}

		IxLink_delete(THIS->root);
		SvREFCNT_dec(THIS->hv);
		Safefree(THIS);


void
IXHV::FETCH(key)
	SV *key

	PREINIT:
		HE *he;

	PPCODE:
		THI_DEBUG(("IXHV::FETCH()\n"));

		if ((he = hv_fetch_ent(THIS->hv, key, 0, 0)) == NULL)
		  XSRETURN_UNDEF;

		ST(0) = sv_mortalcopy((INT2PTR(IxLink *, SvIV(HeVAL(he))))->val);
		XSRETURN(1);


void
IXHV::STORE(key, value)
	SV *key
	SV *value

	PREINIT:
		HE *he;

	CODE:
		THI_DEBUG(("IXHV::STORE()\n"));

		if ((he = hv_fetch_ent(THIS->hv, key, 1, 0)) == NULL)
		  Perl_croak(aTHX_ "couldn't store value");

		if (SvTYPE(HeVAL(he)) == SVt_NULL)
		{
		  IxLink *cur;
		  IxLink_new(cur);
		  IxLink_push(THIS->root, cur);
		  sv_setiv(HeVAL(he), PTR2IV(cur));
		  cur->key = newSVsv(key);
		  cur->val = newSVsv(value);
		}
		else
		  sv_setsv((INT2PTR(IxLink *, SvIV(HeVAL(he))))->val, value);


void
IXHV::FIRSTKEY()
	PPCODE:
		THI_DEBUG(("IXHV::FIRSTKEY()\n"));

		THIS->iter = THIS->root->next;

		if (THIS->iter->key == NULL)
		  XSRETURN_UNDEF;

		ST(0) = sv_mortalcopy(THIS->iter->key);
		XSRETURN(1);


void
IXHV::NEXTKEY(last)
	SV *last

	PPCODE:
		THI_DEBUG(("IXHV::NEXTKEY()\n"));

		THIS->iter = THIS->iter->next;

		if (THIS->iter->key == NULL)
		  XSRETURN_UNDEF;

		ST(0) = sv_mortalcopy(THIS->iter->key);
		XSRETURN(1);


void
IXHV::EXISTS(key)
	SV *key

	PPCODE:
		THI_DEBUG(("IXHV::EXISTS()\n"));

		if (hv_exists_ent(THIS->hv, key, 0))
		  XSRETURN_YES;
		else
		  XSRETURN_NO;


void
IXHV::DELETE(key)
	SV *key

	PREINIT:
		IxLink *cur;
		SV *sv;

	PPCODE:
		THI_DEBUG(("IXHV::DELETE()\n"));

		if ((sv = hv_delete_ent(THIS->hv, key, 0, 0)) == NULL)
		  XSRETURN_UNDEF;

		cur = INT2PTR(IxLink *, SvIV(sv));
		SvREFCNT_dec(cur->key);
		sv = cur->val;
		IxLink_extract(cur);
		IxLink_delete(cur);

		ST(0) = sv_2mortal(sv);
		XSRETURN(1);


void
IXHV::CLEAR()
	PREINIT:
		IxLink *cur;

	CODE:
		THI_DEBUG(("IXHV::CLEAR()\n"));

		for (cur = THIS->root->next; cur != THIS->root;)
		{
		  IxLink *del = cur;
		  cur = cur->next;
		  SvREFCNT_dec(del->key);
                  if (del->val)
		    SvREFCNT_dec(del->val);
		  IxLink_delete(del);
		}

		THIS->root->next = THIS->root->prev = THIS->root;

		hv_clear(THIS->hv);

