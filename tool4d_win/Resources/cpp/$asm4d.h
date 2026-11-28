/*
Ce fichier fait partie des Sources de 4D.
Les droits de propriete intellectuelle concernant les Sources sont la
propriete exclusive de 4D.
En dehors des droits qui seraient expressement accordes, aucun autre droit
sur les Sources n'est accorde par 4D a quiconque, y compris les personnes
employes de 4D agissant en dehors de l'exercice de leurs fonctions.
Toute reproduction autorisee des Sources, partielle ou totale, n'est
consentie que sous la condition absolue qu'elle contienne le present texte.

L'acces aux Sources est strictement confidentiel, et toute personne en
beneficiant, devra maintenir ce caractere confidentiel.
*/

/*
This file is part of the Sources of 4D.
The Source is the exclusive property of 4D.
Except the rights that might be expressly granted, no other rights are
granted by 4D to anyone, including 4D's employees acting beyond their
functions' scope.
Any partial or complete reproduction of the Source, is authorized provided
that such reproduction contains the present text.

The Source must be considered as confidential information, and must be
maintained as such.


*/

#ifndef ASM4D_HEADER
#define ASM4D_HEADER

/*
	This file is intended for building 4D code as a cpp dynamic library
	It is NOT to be compiled within 4D.
*/

using int64_t = long long;
using uint64_t = unsigned long long;
using int32_t = int;
using uint32_t = unsigned int;
using int16_t = short;
using uint16_t = unsigned short;
using uint8_t = unsigned char;
#if __APPLE__
using intptr_t = long;
using size_t = unsigned long;
#else
using intptr_t = long long;
using size_t = unsigned long long;
#endif

#define offsetof(type,field) ((size_t)(&((type*)0)->field))

inline void* operator new(size_t, void* p)	{ return p;}

// intrinsic functions
extern "C" double fabs(double);
extern "C" long int lrint(double);

// non intrinsic functions
extern "C" void* memcpy(void* __dst, const void* __src, size_t __n);
extern "C" double pow(double, double);
extern "C" double floor(double);

using Handle = char**;
using sLONG8 = int64_t;
using uLONG8 = uint64_t;
using sLONG = int32_t;
using uLONG = uint32_t;
using sWORD = int16_t;
using uWORD = uint16_t;
using uBYTE = uint8_t;
using uCHAR = unsigned char;
using Str255 = unsigned char[256];
struct Rect	{ short top, left, bottom, right;};
using sLONG_PTR = sLONG8;

// packing de 2 pour vInlineString qui vient de xtoolbox
#pragma pack( push, 2 )

namespace xbox
{
struct VInlineString
{
	sLONG		fLength;
	uWORD*		fString;
	sLONG		fMaxLength;
	uLONG		fTag;
};
class VPicture;
class VValueBag;
class VJSONObject;
class VJSONArray;
class VString;
};
#pragma pack( pop )


// some necessary definitions for legacy_language_types.h
#define COMPILING_4DCOMPILER
#define XBOX xbox

#ifndef WITH
// Testing a macro issuing an error if the feature flag is not defined
#define WITH(FEATURE)	((WITH_##FEATURE)/(defined WITH_##FEATURE))
#endif

#define WITH_WIN_COMPILE_BASE_AS_CPP 1
#define WITH_AST_INTERPRETER 1

#include "legacy_language_types.h"
#include "cp4drt_shared.h"


using CV = champvar;
using PCV = ptrchampvar;

//=====================================================================================================================

extern Asm4d_runtime*	g;

class Asm4d_handler_impl : public Asm4d_handler_v2
{
public:
	virtual	sLONG						GetVersion() override;
	virtual	bool						GetRoutines( Asm4d_ProcPtr *outRoutines, size_t inCount) override;

	virtual	bool						Init( sLONG in4DVersion) override;
	virtual	void						Deinit() override;

	inline static Asm4d_handler_impl&	Get()	{ static Asm4d_handler_impl sInstance; return sInstance;}

private:
	static	size_t			sFunctionCount;	// defined in $functions.cpp produced during compilation
	static	Asm4d_ProcPtr	sFunctions[];	// defined in $functions.cpp produced during compilation
};

//=====================================================================================================================

struct Value_longint
{
	using value_type = sLONG;
	
	Value_longint()	// don't use aggregate initializers because it calls memset to clear the whole cv!
		{
			fCV.tt = d4_enums::longentier;
			fCV.fil = 3;
			fCV.variant.l = 0;
		}
	Value_longint( sLONG inValue)
		{
			fCV.tt = d4_enums::longentier;
			fCV.fil = 3;
			fCV.variant.l = inValue;
		}

	champvar*	cv()			{ return &fCV;}
	
	sLONG		get() const					{ return fCV.variant.l;}
	void		set( sLONG inValue)			{ fCV.variant.l = inValue;}
	void		operator=( sLONG inValue)	{ fCV.variant.l = inValue;}
	void		setNull()					{ fCV.variant.l = 0;}
	bool		truthy() const				{ return true;}

	champvar	fCV;
};
using Long = Value_longint;


struct Value_int
{
	using value_type = sWORD;

	Value_int()	// don't use aggregate initializers because it calls memset to clear the whole cv!
		{
			fCV.tt = d4_enums::entier;
			fCV.fil = 3;
			fCV.variant.i = 0;
		}
	Value_int( sWORD inValue)
		{
			fCV.tt = d4_enums::entier;
			fCV.fil = 3;
			fCV.variant.i = inValue;
		}

	champvar*	cv()			{ return &fCV;}

	sWORD		get() const					{ return fCV.variant.i;}
	void		set( sWORD inValue)			{ fCV.variant.i = inValue;}
	void		operator=( sWORD inValue)	{ fCV.variant.i = inValue;}
	void		setNull()					{ fCV.variant.i = 0;}
	bool		truthy() const				{ return true;}

	champvar	fCV;
};
using Int = Value_int;

struct Value_time
{
	using value_type = sLONG;
	
	Value_time()	// don't use aggregate initializers because it calls memset to clear the whole cv!
		{
			fCV.tt = d4_enums::timex;
			fCV.fil = 3;
			fCV.variant.l = 0;
		}
	Value_time( sLONG inValue)
		{
			fCV.tt = d4_enums::timex;
			fCV.fil = 3;
			fCV.variant.l = inValue;
		}

	champvar*	cv()			{ return &fCV;}

	sLONG		get() const					{ return fCV.variant.l;}
	void		set( sLONG inValue)			{ fCV.variant.l = inValue;}
	void		operator=( sLONG inValue)	{ fCV.variant.l = inValue;}
	void		setNull()					{ fCV.variant.l = 0;}
	bool		truthy() const				{ return true;}

	champvar	fCV;
};
using Time = Value_time;


struct Value_number
{
	using value_type = double;
	
	Value_number()
		{
			fCV.tt = d4_enums::reel;
			fCV.fil = 3;
			fCV.variant.r = 0;
		}

	Value_number( double inValue)
		{
			fCV.tt = d4_enums::reel;
			fCV.fil = 3;
			fCV.variant.r = inValue;
		}
	
	champvar*	cv()			{ return &fCV;}
	
	double		get() const				{ return fCV.variant.r;}
	void		set( double inValue)	{ fCV.variant.r = inValue;}
	void		operator=( double inValue)	{ fCV.variant.r = inValue;}
	void		setNull()				{ fCV.variant.r = 0;}
	bool		truthy() const			{ return true;}

	champvar	fCV;
};
using Num = Value_number;


struct Value_bool
{
	using value_type = bool;
	
	Value_bool()
		{
			fCV.tt = d4_enums::Bool4D;
			fCV.fil = 3;
			fCV.variant.b = 0;
		}

	Value_bool( uBYTE inValue)
		{
			fCV.tt = d4_enums::Bool4D;
			fCV.fil = 3;
			fCV.variant.b = inValue;
		}

	champvar*	cv()			{ return &fCV;}
	
	bool		get() const				{ return fCV.variant.b;}
	void		set( bool inValue)		{ fCV.variant.b = inValue;}
	void		operator=( bool inValue){ fCV.variant.b = inValue;}
	void		setNull()				{ fCV.variant.b = 0;}
	bool		truthy() const			{ return fCV.variant.b != 0;}

	champvar	fCV;
};
using Bool = Value_bool;


struct Value_date
{
	using value_type = datum;
	
	Value_date()
		{
			fCV.tt = d4_enums::date;
			fCV.fil = 3;
			fCV.variant.d.jour = 0;
			fCV.variant.d.mois = 0;
			fCV.variant.d.annee = 0;
		}

	Value_date( sWORD inDay, sWORD inMonth, sWORD inYear)
		{
			fCV.tt = d4_enums::date;
			fCV.fil = 3;
			fCV.variant.d.jour = inDay;
			fCV.variant.d.mois = inMonth;
			fCV.variant.d.annee = inYear;
		}
	
	champvar*			cv()			{ return &fCV;}
	
	const value_type&	get() const							{ return fCV.variant.d;}
	void				set( const value_type&  inValue)	{ fCV.variant.d = inValue;}
	void				operator=( const value_type&  inValue)	{ fCV.variant.d = inValue;}
	void				setNull()							{ fCV.variant.d.jour = fCV.variant.d.mois = fCV.variant.d.annee = 0;}
	bool				truthy() const						{ return (fCV.variant.d.jour != 0 || fCV.variant.d.mois != 0 || fCV.variant.d.annee != 0);}

	champvar			fCV;
};
using Date = Value_date;


struct Value_blob_byte
{
	Value_blob_byte( tProcessGlobals *inCtx, STBlob& inBlob, sLONG inIndex):fCtx( inCtx), fBlob( inBlob), fIndex( inIndex) {}

	void		set( sLONG inValue)
	{
		if (fIndex >= 0 && fIndex < fBlob.len)
			(*(uBYTE**)fBlob.h)[fIndex] = (uBYTE) inValue;
		else
			g->Error( fCtx, errOutOfBounds_blob);
	}

	void		operator=( sLONG inValue)	{ set( inValue);}

	sLONG		get()
	{
		if (fIndex >= 0 && fIndex < fBlob.len)
			return (*(uBYTE**)fBlob.h)[fIndex];
		g->Error( fCtx, errOutOfBounds_blob);
		return 0;
	}

	STBlob&		fBlob;
	tProcessGlobals	*fCtx;
	sLONG		fIndex;
};
using Byte = Value_blob_byte;


struct Value_blob
{
	using value_type = STBlob;
	
	Value_blob()
		{
			fCV.tt = d4_enums::blob;
			fCV.fil = 3;
			fCV.variant.Blob.h = nullptr;
			fCV.variant.Blob.len = 0;
		}

	~Value_blob()
		{
			g->ClearBlob( fCV.variant.Blob);
		}
	
	champvar*	cv()			{ return &fCV;}
	
	STBlob&		get()							{ return fCV.variant.Blob;}
	void		set( const STBlob& inValue)		{ g->AssignBlob( fCV.variant.Blob, inValue);}
	void		operator=( const STBlob& inValue)		{ g->AssignBlob( fCV.variant.Blob, inValue);}
	void		setNull()						{ g->ClearBlob( fCV.variant.Blob);}
	bool		truthy() const					{ return true;}

	Value_blob_byte	blobByte( tProcessGlobals *inCtx, sLONG inIndex)	{ return Value_blob_byte( inCtx, fCV.variant.Blob, inIndex);}

	champvar	fCV;
};
using Blb = Value_blob;


inline bool operator==( const datum& inDate1, const datum& inDate2)
{
	return (inDate1.annee == inDate2.annee) && (inDate1.mois == inDate2.mois) && (inDate1.jour == inDate2.jour);
}

inline bool operator!=( const datum& inDate1, const datum& inDate2)
{
	return (inDate1.jour != inDate2.jour) || (inDate1.mois != inDate2.mois) || (inDate1.annee != inDate2.annee);
}

inline bool operator>( const datum& inDate1, const datum& inDate2)
{
	if (inDate1.annee == inDate2.annee)
	{
		if (inDate1.mois == inDate2.mois)
		{
			if (inDate1.jour == inDate2.jour)
				return false;
			else if (inDate1.jour < inDate2.jour)
				return false;
			else
				return true;
		}
		else
		{
			if (inDate1.mois < inDate2.mois)
				return false;
			else
				return true;
		}
	}
	else if (inDate1.annee < inDate2.annee)
	{
		return false;
	}
	else
	{
		return true;
	}
}

inline bool operator>=( const datum& inDate1, const datum& inDate2)	{ return (inDate1 > inDate2) || (inDate1 == inDate2);}
inline bool operator<( const datum& inDate1, const datum& inDate2)	{ return not(inDate1 >= inDate2);}
inline bool operator<=( const datum& inDate1, const datum& inDate2)	{ return not(inDate1 > inDate2);}


struct Value_text
{
	using value_type = XBOX::VInlineString;

	Value_text()
		{
			fCV.tt = d4_enums::kind_unicode;
			fCV.fil = 3;
			fCV.variant.fString.fLength = 0;
			fCV.variant.fString.fString = nullptr;
			fCV.variant.fString.fMaxLength = 0;
		}

	Value_text( uint16_t *inString, int32_t inLength)
		{
			fCV.tt = d4_enums::kind_unicode;
			fCV.fil = 3;
			fCV.variant.fString.fLength = inLength;
			fCV.variant.fString.fString = inString;
			fCV.variant.fString.fMaxLength = inLength;
			fCV.variant.fString.fTag = (uLONG) (intptr_t) inString;
		}

	~Value_text()
		{
			if (fCV.variant.fString.fString != nullptr)
				g->DisposeString(fCV.variant.fString);
		}

	champvar*			cv()			{ return &fCV;}

	const value_type&	get() const	{ return fCV.variant.fString;}
	value_type&			get()		{ return fCV.variant.fString;}
	void				set( const value_type& inValue)	{ g->AssignString( fCV.variant.fString, inValue);}
	void				operator=( const value_type& inValue)	{ g->AssignString( fCV.variant.fString, inValue);}

	void				setNull()	{ g->ClearString( fCV.variant.fString);}

	sLONG				getCharCode() const					{ return (fCV.variant.fString.fLength == 0) ? 0 : fCV.variant.fString.fString[0];}
	sLONG				getCharCode( sLONG inIndex) const	{ return (inIndex > 0 && inIndex <= fCV.variant.fString.fLength) ? fCV.variant.fString.fString[inIndex-1] : 0;}

	bool				truthy() const						{ return fCV.variant.fString.fLength != 0;}

	champvar			fCV;
};
using Txt = Value_text;

struct Value_pointer
{
	using value_type = V4DPointer*;

	Value_pointer()
		{
			fCV.tt = d4_enums::tk_pointer;
			fCV.fil = 3;
			fCV.variant.fPointer = nullptr;
		}

	~Value_pointer() { g->AssignPointer( &fCV.variant.fPointer, nullptr);}

	champvar*			cv()			{ return &fCV;}

	V4DPointer*			get() const	{ return fCV.variant.fPointer;}
	void				set( V4DPointer *inValue)	{ g->AssignPointer( &fCV.variant.fPointer, inValue);}
	void				operator=( V4DPointer *inValue)	{ g->AssignPointer( &fCV.variant.fPointer, inValue);}

	void				setNull()	{ g->AssignPointer( &fCV.variant.fPointer, nullptr);}
	bool				truthy() const				{ return fCV.variant.fPointer != nullptr;}

	void				adopt( V4DPointer *inValue)
		{
			if (fCV.variant.fPointer != nullptr)
				g->AssignPointer( &fCV.variant.fPointer, nullptr);
			fCV.variant.fPointer = inValue;
		}

	champvar			fCV;
};
using Ptr = Value_pointer;


struct Value_picture
{
	using value_type = XBOX::VPicture*;

	Value_picture()
		{
			fCV.tt = d4_enums::graph2;
			fCV.fil = 3;
			fCV.variant.fPicture = nullptr;
		}

	~Value_picture() { g->AssignPicture( &fCV.variant.fPicture, nullptr);}

	champvar*			cv()			{ return &fCV;}

	XBOX::VPicture*		get() const	{ return fCV.variant.fPicture;}
	void				set( XBOX::VPicture *inValue)	{ g->AssignPicture( &fCV.variant.fPicture, inValue);}
	void				operator=( XBOX::VPicture *inValue)	{ g->AssignPicture( &fCV.variant.fPicture, inValue);}

	void				setNull()	{ g->AssignPicture( &fCV.variant.fPicture, nullptr);}
	bool				truthy() const				{ return fCV.variant.fPicture != nullptr;}

	void				adopt( XBOX::VPicture *inValue)
		{
			if (fCV.variant.fPicture != nullptr)
				g->AssignPicture( &fCV.variant.fPicture, nullptr);
			fCV.variant.fPicture = inValue;
		}

	champvar			fCV;
};
using Pic = Value_picture;


struct Value_object
{
	using value_type = XBOX::VJSONObject*;

	Value_object()
		{
			fCV.tt = d4_enums::tk_object;
			fCV.fil = 3;
			fCV.variant.fObject = nullptr;
		}

	~Value_object() { g->AssignObject( &fCV.variant.fObject, nullptr);}

	champvar*			cv()			{ return &fCV;}

	XBOX::VJSONObject*	get() const	{ return fCV.variant.fObject;}
	void				set( XBOX::VJSONObject *inValue)	{ g->AssignObject( &fCV.variant.fObject, inValue);}
	void				operator=( XBOX::VJSONObject *inValue)	{ g->AssignObject( &fCV.variant.fObject, inValue);}

	void				setNull()	{ g->AssignObject( &fCV.variant.fObject, nullptr);}
	bool				isNull() const	{ return fCV.variant.fObject == nullptr;}
	bool				truthy() const	{ return (fCV.variant.fObject != nullptr) && g->IsTruthy(reinterpret_cast<const champvar&>(fCV));}

	void				adopt( XBOX::VJSONObject *inValue)
		{
			if (fCV.variant.fObject != nullptr)
				g->AssignObject( &fCV.variant.fObject, nullptr);
			fCV.variant.fObject = inValue;
		}

	champvar			fCV;
};
using Obj = Value_object;


struct Value_collection
{
	using value_type = XBOX::VJSONArray*;

	Value_collection()
		{
			fCV.tt = d4_enums::tk_array;
			fCV.fil = 3;
			fCV.variant.fArray = nullptr;
		}

	~Value_collection() { g->AssignCollection( &fCV.variant.fArray, nullptr);}

	champvar*			cv()			{ return &fCV;}

	XBOX::VJSONArray*	get() const	{ return fCV.variant.fArray;}
	void				set( XBOX::VJSONArray *inValue)		{ g->AssignCollection( &fCV.variant.fArray, inValue);}
	void				operator=( XBOX::VJSONArray *inValue)	{ g->AssignCollection( &fCV.variant.fArray, inValue);}

	void				setNull()	{ g->AssignCollection( &fCV.variant.fArray, nullptr);}
	bool				isNull() const	{ return fCV.variant.fArray == nullptr;}
	bool				truthy() const	{ return (fCV.variant.fArray != nullptr) && g->IsTruthy(reinterpret_cast<const champvar&>(fCV));}

	void				adopt( XBOX::VJSONArray *inValue)
		{
			if (fCV.variant.fArray != nullptr)
				g->AssignCollection( &fCV.variant.fArray, nullptr);
			fCV.variant.fArray = inValue;
		}

	champvar			fCV;
};
using Col = Value_collection;


struct Value_variant
{
	Value_variant()
		{
			fCV.tt = d4_enums::aucun;
			fCV.fil = 2;
		}

	~Value_variant()
		{
			g->DisposeValue( &fCV);
		}

	champvar*		cv()			{ return &fCV;}

	void			setNull()	{ g->DisposeValue( &fCV); fCV.tt = d4_enums::tk_jsonNull;}

	bool			truthy() const
	{
		switch( fCV.tt)
		{
			case d4_enums::entier:
			case d4_enums::longentier:
			case d4_enums::long8:
			case d4_enums::reel:
			case d4_enums::timex:
			case d4_enums::blob:
										return true;

			case d4_enums::kind_unicode:return fCV.variant.fString.fLength != 0;
			case d4_enums::Bool4D:		return fCV.variant.b != 0;
			case d4_enums::date:		return (fCV.variant.d.jour != 0 || fCV.variant.d.mois != 0 || fCV.variant.d.annee != 0);
			case d4_enums::tk_object:	return (fCV.variant.fObject != nullptr) && g->IsTruthy(reinterpret_cast<const champvar&>(fCV));
			case d4_enums::tk_array:	return (fCV.variant.fArray != nullptr) && g->IsTruthy(reinterpret_cast<const champvar&>(fCV));
			case d4_enums::tk_pointer:	return (fCV.variant.fPointer != nullptr);
			case d4_enums::graph2:		return (fCV.variant.fPicture != nullptr);

			case d4_enums::aucun:
			case d4_enums::tk_jsonNull:
			default:			return false;
		}
	}

	champvar	fCV;
};
using Variant = Value_variant;


struct Value_null
{
	Value_null()
		{
			fCV.tt = d4_enums::tk_jsonNull;
			fCV.fil = 3;
		}

	champvar*		cv()			{ return &fCV;}
	bool			truthy() const	{ return false;}

	champvar		fCV;
};


struct Value_ref
{
	Value_ref()
		{
			fRef.ct = d4_enums::xcritere;
			fRef.fil = 1;	// means it's a champoper and not a champvar
			fRef.variant.v3.numfile = 0;
			fRef.variant.v3.numcrit = 0;
			fRef.variant.v3.numsous = 0;
		}

	Value_ref( tProcessGlobals *inProcessPtr, const champvar *inRef)
		{
			fRef.fil = 1;	// means it's a champoper and not a champvar
			setLocalRef( inProcessPtr, inRef);
		}

	Value_ref( tProcessGlobals *inProcessPtr, int64_t inOffset)
		{
			fRef.fil = 1;	// means it's a champoper and not a champvar
			setGlobalRef( inProcessPtr, inOffset);
		}

	Value_ref( tProcessGlobals *inProcessPtr, int64_t inOffset, bool)
		{
			fRef.fil = 1;	// means it's a champoper and not a champvar
			setInterprocessRef( inProcessPtr, inOffset);
		}

	Value_ref( d4_enums::optyp inOpCode)
		{
			fRef.ct = d4_enums::operation;
			fRef.fil = 1;	// means it's a champoper and not a champvar
			fRef.variant.op = inOpCode;
		}
	
	Value_ref( sWORD inTableNumber, sWORD inFieldNumber)
		{
			fRef.ct = d4_enums::xcritere;
			fRef.fil = 1;	// means it's a champoper and not a champvar
			fRef.variant.v3.numfile = inTableNumber;
			fRef.variant.v3.numcrit = inFieldNumber;
			fRef.variant.v3.numsous = 0;
		}
	
	Value_ref( sWORD inTableNumber, sWORD inFieldNumber, sWORD inNumSous, sWORD inSous0, sWORD inSous1, sWORD inSous2, sWORD inSous3, sWORD inSous4)
		{
			fRef.ct = d4_enums::xcritere;
			fRef.fil = 1;	// means it's a champoper and not a champvar
			fRef.variant.v3.numfile = inTableNumber;
			fRef.variant.v3.numcrit = inFieldNumber;
			fRef.variant.v3.numsous = inNumSous;
			fRef.variant.v3.critsous[0] = inSous0;
			fRef.variant.v3.critsous[1] = inSous1;
			fRef.variant.v3.critsous[2] = inSous2;
			fRef.variant.v3.critsous[3] = inSous3;
			fRef.variant.v3.critsous[4] = inSous4;
		}

	void setLocalRef( tProcessGlobals *inProcessPtr, const champvar *inRef)
		{
			fRef.ct = d4_enums::tokenVariable;
			fRef.variant.v5.fLocalStackStamp = inProcessPtr->fLanguageContextID;
			fRef.variant.v5.islocal = d4_enums::vlocal;
			fRef.variant.v5.indice1 = -1;
			fRef.variant.v5.indice2 = -1;
			fRef.variant.v5.varname[0] = 9;
			fRef.variant.v5.varname[1] = 3;
			memcpy( &fRef.variant.v5.varname[2], &inRef, sizeof( inRef));
		}

	void setGlobalRef( tProcessGlobals *inProcessPtr, int64_t inOffset)
		{
			fRef.ct = d4_enums::tokenVariable;
			fRef.variant.v5.fLocalStackStamp = inProcessPtr->fLanguageContextID;
			fRef.variant.v5.islocal = d4_enums::vGlobal;
			fRef.variant.v5.indice1 = -1;
			fRef.variant.v5.indice2 = -1;
			fRef.variant.v5.varname[0] = 9;
			fRef.variant.v5.varname[1] = 7;
			memcpy( &fRef.variant.v5.varname[2], &inOffset, sizeof( inOffset));
		}

	void setInterprocessRef( tProcessGlobals *inProcessPtr, int64_t inOffset)
		{
			fRef.ct = d4_enums::tokenVariable;
			fRef.variant.v5.fLocalStackStamp = inProcessPtr->fRootContextID;
			fRef.variant.v5.islocal = d4_enums::vglobglob;
			fRef.variant.v5.indice1 = -1;
			fRef.variant.v5.indice2 = -1;
			fRef.variant.v5.varname[0] = 9;
			fRef.variant.v5.varname[1] = 1;
			memcpy( &fRef.variant.v5.varname[2], &inOffset, sizeof( inOffset));
		}
	
	void setIndice1( sLONG inIndex)	{ fRef.variant.v5.indice1 = inIndex;}
	void setIndice2( sLONG inIndex)	{ fRef.variant.v5.indice2 = inIndex;}

	const champoper_runtime*	ref() const	{ return &fRef;}
	champvar*					cv()	{ return reinterpret_cast<champvar*>( &fRef);}

	champoper_runtime	fRef;
};
using Ref = Value_ref;

template<class ACCESSOR>
struct Value_array_elem
{
	void							set( typename ACCESSOR::elem_type_set inValue)	{ ACCESSOR::set( fCtx, fCV, fIndex, inValue);}
	void							operator=( typename ACCESSOR::elem_type_set inValue)	{ ACCESSOR::set( fCtx, fCV, fIndex, inValue);}
	typename ACCESSOR::elem_type	get()										{ return ACCESSOR::get( fCtx, fCV, fIndex);}

	tProcessGlobals*	fCtx;
	champvar*			fCV;
	sLONG				fIndex;
};


template<class ACCESSOR>
struct Value_array_2d_elem
{
	void							set( typename ACCESSOR::elem_type_set inValue)
		{
			if (fCV->tt != d4_enums::aucun && fIndex1 >= 0 && fIndex1 <= fCV->variant.v12.nbelem)
			{
				ACCESSOR::set( fCtx, (champvar *) &(*fCV->variant.v12.tab)[fIndex1], fIndex2, inValue);
			}
			else
			{
				g->Error( fCtx, errOutOfBounds_array);
			}
		}

	void							operator=( typename ACCESSOR::elem_type_set inValue)
		{
			if (fCV->tt != d4_enums::aucun && fIndex1 >= 0 && fIndex1 <= fCV->variant.v12.nbelem)
			{
				ACCESSOR::set( fCtx, (champvar *) &(*fCV->variant.v12.tab)[fIndex1], fIndex2, inValue);
			}
			else
			{
				g->Error( fCtx, errOutOfBounds_array);
			}
		}

	typename ACCESSOR::elem_type	get()
		{
			if (fCV->tt != d4_enums::aucun && fIndex1 >= 0 && fIndex1 <= fCV->variant.v12.nbelem)
				return ACCESSOR::get( fCtx, (champvar *) &(*fCV->variant.v12.tab)[fIndex1], fIndex2);

			g->Error( fCtx, errOutOfBounds_array);
			static typename ACCESSOR::elem_type v = {};
			return v;
		}

	tProcessGlobals*	fCtx;
	champvar*			fCV;
	sLONG				fIndex1;
	sLONG				fIndex2;
};


struct Value_array_sel
{
	void	set( sLONG inSel)	{ fCV->variant.v12.cursel = (sWORD) inSel;}
	void	operator=( sLONG inSel)	{ fCV->variant.v12.cursel = (sWORD) inSel;}
	sLONG	get()				{ return fCV->variant.v12.cursel;}
	
	champvar*		fCV;
};

template<d4_enums::typkind KIND, typename ACCESSOR>
struct Value_array
{
	using elem_type = typename ACCESSOR::elem_type;
	using accessor_type = ACCESSOR;

	Value_array()
	{
		fCV.tt = d4_enums::aucun;
		fCV.fil = 3;
		((tUninitializedArray*)&fCV)->truett = KIND;
	}

	~Value_array()
	{
		g->DisposeValue( &fCV);
	}

	champvar*		cv()			{ return &fCV;}

	Value_array_elem<ACCESSOR>	arrayElem( tProcessGlobals *inCtx, sLONG inIndex)
	{
		return  Value_array_elem<ACCESSOR>{ inCtx, &fCV, inIndex};
	}

	Value_array_sel	arraySel()
	{
		return  Value_array_sel{ &fCV};
	}

	sLONG	size() const
	{
		return fCV.variant.v12.nbelem;
	}

	champvar	fCV;
};


template<d4_enums::typkind KIND, typename ACCESSOR>
struct Value_array_2d
{
	using elem_type = typename ACCESSOR::elem_type;
	using accessor_type = ACCESSOR;

	Value_array_2d()
	{
		fCV.tt = d4_enums::aucun;
		fCV.fil = 3;
		((tUninitializedArray*)&fCV)->truett = 0x80 | (uBYTE) KIND;
	}

	~Value_array_2d()
	{
		g->DisposeValue( &fCV);
	}

	champvar*		cv()			{ return &fCV;}

	Value_array_2d_elem<ACCESSOR>	arrayElem( tProcessGlobals *inCtx, sLONG inIndex1, sLONG inIndex2)
	{
		return  Value_array_2d_elem<ACCESSOR>{ inCtx, &fCV, inIndex1, inIndex2};
	}

	Value_array_sel	arraySel()
	{
		return  Value_array_sel{ &fCV};
	}

	sLONG	size() const
	{
		return fCV.variant.v12.nbelem;
	}

	champvar	fCV;
};


struct access_array_bool
{
	using elem_type = bool;

	static	bool	TestBit( uBYTE *bitTable, uLONG index) { return (bitTable[index / 8] & (1 << (index % 8))) != 0; }
	static	void	SetBit2One( uBYTE *bitTable, uLONG index) { bitTable[index / 8] |= (1 << (index % 8)); }
	static	void	SetBit2Zero( uBYTE *bitTable, uLONG index) { bitTable[index / 8] &= ~(1 << (index % 8)); }

	using elem_type_set = elem_type;

	static	void	set( tProcessGlobals *inProcessPtr, champvar *inCV, sLONG inIndex, elem_type inValue)
		{
			if ( (inCV->tt == d4_enums::tableaub) && (inIndex >= 0) && (inIndex <= inCV->variant.v15.nbelem) )
			{
				if (inValue)
					SetBit2One( (uBYTE *) *inCV->variant.v15.bittab, inIndex);
				else
					SetBit2Zero( (uBYTE *) *inCV->variant.v15.bittab, inIndex);
			}
			else
			{
				g->Error( inProcessPtr, errOutOfBounds_array);
			}
		}

	static	elem_type	get( tProcessGlobals *inProcessPtr, champvar *inCV, sLONG inIndex)
		{
			if ( (inCV->tt == d4_enums::tableaub) && (inIndex >= 0) && (inIndex <= inCV->variant.v15.nbelem) )
				return TestBit( (*inCV->variant.v15.bittab)->data, inIndex);

			g->Error( inProcessPtr, errOutOfBounds_array);
			return false;
		}

};
using Value_array_bool = Value_array<d4_enums::tableaub, access_array_bool>;
using Value_array_2d_bool = Value_array_2d<d4_enums::tableaub, access_array_bool>;


struct access_array_int
{
	using elem_type = sWORD;

	using elem_type_set = elem_type;

	static	void	set( tProcessGlobals *inProcessPtr, champvar *inCV, sLONG inIndex, elem_type inValue)
		{
			if ((inCV->tt == d4_enums::tableaui) && inIndex >= 0 && inIndex <= inCV->variant.v17.nbelem)
				(*inCV->variant.v17.tabi)[inIndex] = inValue;
			else
				g->Error( inProcessPtr, errOutOfBounds_array);
		}

	static	elem_type	get( tProcessGlobals *inProcessPtr, champvar *inCV, sLONG inIndex)
		{
			if ((inCV->tt == d4_enums::tableaui) && inIndex >= 0 && inIndex <= inCV->variant.v17.nbelem)
				return (*inCV->variant.v17.tabi)[inIndex];

			g->Error( inProcessPtr, errOutOfBounds_array);
			return 0;
		}

};
using Value_array_int = Value_array<d4_enums::tableaui, access_array_int>;
using Value_array_2d_int = Value_array_2d<d4_enums::tableaui, access_array_int>;


struct access_array_longint
{
	using elem_type = sLONG;

	using elem_type_set = elem_type;

	static	void	set( tProcessGlobals *inProcessPtr, champvar *inCV, sLONG inIndex, elem_type inValue)
		{
			if ((inCV->tt == d4_enums::tableaul) && inIndex >= 0 && inIndex <= inCV->variant.v18.nbelem)
				(*inCV->variant.v18.tabl)[inIndex] = inValue;
			else
				g->Error( inProcessPtr, errOutOfBounds_array);
		}

	static	elem_type	get( tProcessGlobals *inProcessPtr, champvar *inCV, sLONG inIndex)
		{
			if ((inCV->tt == d4_enums::tableaul) && inIndex >= 0 && inIndex <= inCV->variant.v18.nbelem)
				return (*inCV->variant.v18.tabl)[inIndex];
			g->Error( inProcessPtr, errOutOfBounds_array);
			return 0;
		}
};
using Value_array_longint = Value_array<d4_enums::tableaul, access_array_longint>;
using Value_array_2d_longint = Value_array_2d<d4_enums::tableaul, access_array_longint>;


struct access_array_time
{
	using elem_type = sLONG;

	using elem_type_set = elem_type;

	static	void	set( tProcessGlobals *inProcessPtr, champvar *inCV, sLONG inIndex, elem_type inValue)
		{
			if ((inCV->tt == d4_enums::tableautimex) && inIndex >= 0 && inIndex <= inCV->variant.v18.nbelem)
				(*inCV->variant.v18.tabl)[inIndex] = inValue;
			else
				g->Error( inProcessPtr, errOutOfBounds_array);
		}

	static	elem_type	get( tProcessGlobals *inProcessPtr, champvar *inCV, sLONG inIndex)
		{
			if ((inCV->tt == d4_enums::tableautimex) && inIndex >= 0 && inIndex <= inCV->variant.v18.nbelem)
				return (*inCV->variant.v18.tabl)[inIndex];
			g->Error( inProcessPtr, errOutOfBounds_array);
			return 0;
		}
};
using Value_array_time = Value_array<d4_enums::tableautimex, access_array_time>;
using Value_array_2d_time = Value_array_2d<d4_enums::tableautimex, access_array_time>;


struct access_array_number
{
	using elem_type = double;

	using elem_type_set = elem_type;

	static	void	set( tProcessGlobals *inProcessPtr, champvar *inCV, sLONG inIndex, elem_type inValue)
		{
			if ((inCV->tt == d4_enums::tableaur) && inIndex >= 0 && inIndex <= inCV->variant.v16.nbelem)
				(*inCV->variant.v16.tabr)[inIndex] = inValue;
			else
				g->Error( inProcessPtr, errOutOfBounds_array);
		}

	static	elem_type	get( tProcessGlobals *inProcessPtr, champvar *inCV, sLONG inIndex)
		{
			if ((inCV->tt == d4_enums::tableaur) && inIndex >= 0 && inIndex <= inCV->variant.v16.nbelem)
				return (*inCV->variant.v16.tabr)[inIndex];
			g->Error( inProcessPtr, errOutOfBounds_array);
			return 0;
		}
};
using Value_array_number = Value_array<d4_enums::tableaur, access_array_number>;
using Value_array_2d_number = Value_array_2d<d4_enums::tableaur, access_array_number>;


struct access_array_date
{
	using elem_type = datum;

	using elem_type_set = const elem_type&;

	static	void	set( tProcessGlobals *inProcessPtr, champvar *inCV, sLONG inIndex, elem_type_set inValue)
		{
			if ((inCV->tt == d4_enums::tableaud) && inIndex >= 0 && inIndex <= inCV->variant.v19.nbelem)
				(*inCV->variant.v19.tabd)[inIndex] = inValue;
			else
				g->Error( inProcessPtr, errOutOfBounds_array);
		}

	static	elem_type	get( tProcessGlobals *inProcessPtr, champvar *inCV, sLONG inIndex)
		{
			if ((inCV->tt == d4_enums::tableaud) && inIndex >= 0 && inIndex <= inCV->variant.v19.nbelem)
				return (*inCV->variant.v19.tabd)[inIndex];
			g->Error( inProcessPtr, errOutOfBounds_array);
			return {};
		}
};
using Value_array_date = Value_array<d4_enums::tableaud, access_array_date>;
using Value_array_2d_date = Value_array_2d<d4_enums::tableaud, access_array_date>;


struct access_array_pointer
{
	using elem_type = V4DPointer*;

	using elem_type_set = elem_type;

	static	void	set( tProcessGlobals *inProcessPtr, champvar *inCV, sLONG inIndex, elem_type inValue)
		{
			if ((inCV->tt == d4_enums::tableau_pointer) && inIndex >= 0 && inIndex <= inCV->variant.v27.nbelem)
				g->AssignPointer( &(*inCV->variant.v27.tabpointer)[inIndex], inValue);
			else
				g->Error( inProcessPtr, errOutOfBounds_array);
		}

	static	elem_type	get( tProcessGlobals *inProcessPtr, champvar *inCV, sLONG inIndex)
		{
			if ((inCV->tt == d4_enums::tableau_pointer) && inIndex >= 0 && inIndex <= inCV->variant.v27.nbelem)
				return (*inCV->variant.v27.tabpointer)[inIndex];
			g->Error( inProcessPtr, errOutOfBounds_array);
			return nullptr;
		}
};
using Value_array_pointer = Value_array<d4_enums::tableau_pointer, access_array_pointer>;
using Value_array_2d_pointer = Value_array_2d<d4_enums::tableau_pointer, access_array_pointer>;


struct access_array_picture
{
	using elem_type = XBOX::VPicture*;

	using elem_type_set = elem_type;

	static	void	set( tProcessGlobals *inProcessPtr, champvar *inCV, sLONG inIndex, elem_type inValue)
		{
			if ((inCV->tt == d4_enums::tableaupict) && inIndex >= 0 && inIndex <= inCV->variant.v25.nbelem)
				g->AssignPicture( &(*inCV->variant.v25.tabpicture)[inIndex], inValue);
			else
				g->Error( inProcessPtr, errOutOfBounds_array);
		}

	static	elem_type	get( tProcessGlobals *inProcessPtr, champvar *inCV, sLONG inIndex)
		{
			if ((inCV->tt == d4_enums::tableaupict) && inIndex >= 0 && inIndex <= inCV->variant.v25.nbelem)
				return (*inCV->variant.v25.tabpicture)[inIndex];
			g->Error( inProcessPtr, errOutOfBounds_array);
			return nullptr;
		}
};
using Value_array_picture = Value_array<d4_enums::tableaupict, access_array_picture>;
using Value_array_2d_picture = Value_array_2d<d4_enums::tableaupict, access_array_picture>;


struct access_array_object
{
	using elem_type = XBOX::VJSONObject*;

	using elem_type_set = elem_type;

	static	void	set( tProcessGlobals *inProcessPtr, champvar *inCV, sLONG inIndex, elem_type inValue)
		{
			if ((inCV->tt == d4_enums::tableau_object) && inIndex >= 0 && inIndex <= inCV->variant.v24.nbelem)
				g->AssignObject( &(*inCV->variant.v24.tabobject)[inIndex], inValue);
			else
				g->Error( inProcessPtr, errOutOfBounds_array);
		}

	static	elem_type	get( tProcessGlobals *inProcessPtr, champvar *inCV, sLONG inIndex)
		{
			if ((inCV->tt == d4_enums::tableau_object) && inIndex >= 0 && inIndex <= inCV->variant.v24.nbelem)
				return (*inCV->variant.v24.tabobject)[inIndex];
			g->Error( inProcessPtr, errOutOfBounds_array);
			return nullptr;
		}
};
using Value_array_object = Value_array<d4_enums::tableau_object, access_array_object>;
using Value_array_2d_object = Value_array_2d<d4_enums::tableau_object, access_array_object>;


struct access_array_text
{
	using elem_type = XBOX::VInlineString;
	using elem_type_set = const elem_type&;

	static	void	set( tProcessGlobals *inProcessPtr, champvar *inCV, sLONG inIndex, elem_type_set inValue)
		{
			if ((inCV->tt == d4_enums::tableau_unicode) && inIndex >= 0 && inIndex <= inCV->variant.v23.nbelem)
				g->AssignString( (*inCV->variant.v23.tabuni)[inIndex], inValue);
			else
				g->Error( inProcessPtr, errOutOfBounds_array);
		}

	static	elem_type	get( tProcessGlobals *inProcessPtr, champvar *inCV, sLONG inIndex)
		{
			if ((inCV->tt == d4_enums::tableau_unicode) && inIndex >= 0 && inIndex <= inCV->variant.v23.nbelem)
				return (*inCV->variant.v23.tabuni)[inIndex];
			g->Error( inProcessPtr, errOutOfBounds_array);
			return {0,nullptr,0,0};
		}
};
using Value_array_text = Value_array<d4_enums::tableau_unicode, access_array_text>;
using Value_array_2d_text = Value_array_2d<d4_enums::tableau_unicode, access_array_text>;


struct access_array_blob
{
	using elem_type = STBlob&;	// by ref to access individual blob bytes
	using elem_type_set = const STBlob&;

	static	void	set( tProcessGlobals *inProcessPtr, champvar *inCV, sLONG inIndex, elem_type_set inValue)
		{
			if ((inCV->tt == d4_enums::tableaublob) && inIndex >= 0 && inIndex <= inCV->variant.v14.nbelem)
				g->AssignBlob( (*inCV->variant.v14.tabblob)[inIndex], inValue);
			else
				g->Error( inProcessPtr, errOutOfBounds_array);
		}

	static	STBlob&	get( tProcessGlobals *inProcessPtr, champvar *inCV, sLONG inIndex)
		{
			if ((inCV->tt == d4_enums::tableaublob) && inIndex >= 0 && inIndex <= inCV->variant.v14.nbelem)
				return (*inCV->variant.v14.tabblob)[inIndex];
			g->Error( inProcessPtr, errOutOfBounds_array);
			static STBlob b{0,nullptr};
			return b;
		}
};
using Value_array_blob = Value_array<d4_enums::tableaublob, access_array_blob>;
using Value_array_2d_blob = Value_array_2d<d4_enums::tableaublob, access_array_blob>;


struct CallChain
{
	CallChain( tProcessGlobals *inProcessPtr, const unsigned char *inDescriptor)
		: f{ *inProcessPtr->callChain.fStackFramePtr, inDescriptor, inProcessPtr, 0}
	{
		*inProcessPtr->callChain.fStackFramePtr = &f;
		fNeedEpilog = g->Prolog( f);
	}
	
	
	~CallChain()
	{
		if (fNeedEpilog)
			g->Epilog( f);
		*f.fGlobals->callChain.fStackFramePtr = f.fParent;
	}
	
	CompiledModeStackFrame	f;
	bool					fNeedEpilog;
};


template<class VALUE_TYPE>
VALUE_TYPE& Var( tProcessGlobals *inProcessPtr, int32_t inOffset)
{
	return *(VALUE_TYPE *) ( (char*)inProcessPtr + inOffset);
}

template<class VALUE_TYPE>
VALUE_TYPE& Var( Asm4d_globals *inGlobals, int32_t inOffset)
{
	return *(VALUE_TYPE *) ( (char*)inGlobals->fRtGlobals + inOffset);
}

template<class VALUE_TYPE>
const VALUE_TYPE& Cst( Asm4d_globals *inGlobals, int32_t inOffset)
{
	return *(VALUE_TYPE *) ( (char*)inGlobals->fRtGlobals + inOffset);
}

template<class VALUE_TYPE>
VALUE_TYPE& Parm( tProcessGlobals *inProcessPtr, ptrchampvar inParams[], int32_t inNbParam, int32_t inParamNumber, VALUE_TYPE& inParamOutOfBounds)
{
	if (inParamNumber > 0 && inParamNumber <= inNbParam)
		return *(VALUE_TYPE*) inParams[inParamNumber-1];
	g->Error( inProcessPtr, errOutOfBounds_param);
	return inParamOutOfBounds;
}

template<class VALUE_TYPE>
VALUE_TYPE& Parm( ptrchampvar inParams[], int32_t inParamNumber)
{
	return *(VALUE_TYPE*) inParams[inParamNumber-1];
}

template<class VALUE_TYPE>
VALUE_TYPE& Res( champvar *outResult)
{
	return *(VALUE_TYPE*) outResult;
}


struct Try
{
	Try( tProcessGlobals *inProcessPtr):ctx(inProcessPtr)	{g->BeginTry( ctx);}
	~Try()													{g->EndTry( ctx);}

	tProcessGlobals *ctx;
};


inline void Touch( tProcessGlobals *inProcessPtr, int32_t inOffset)	{ ((AttributedValue *) ((char*)inProcessPtr + inOffset - offsetof( AttributedValue, fValue)))->fModificationStamp += 1;}
inline void Touch( Asm4d_globals *inGlobals, int32_t inOffset)	{ ((AttributedValue *) ((char*)inGlobals->fRtGlobals + inOffset - offsetof( AttributedValue, fValue)))->fModificationStamp += 1;}


inline bool Equal( Asm4d_globals *inGlobals, double r1, double r2)	{return fabs( r1 - r2) <= *inGlobals->fEpsilon;}
inline bool GEqual( Asm4d_globals *inGlobals, double r1, double r2)	{return (r1 > r2) || (fabs( r1 - r2) <= *inGlobals->fEpsilon);}

#endif // ASM4D_HEADER
