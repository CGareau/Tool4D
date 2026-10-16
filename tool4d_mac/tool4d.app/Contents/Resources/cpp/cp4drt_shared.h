/*
* This file is part of Wakanda software, licensed by 4D under
*  (i) the GNU General Public License version 3 (GNU GPL v3), or
*  (ii) the Affero General Public License version 3 (AGPL v3) or
*  (iii) a commercial license.
* This file remains the exclusive property of 4D and/or its licensors
* and is protected by national and international legislations.
* In any event, Licensee's compliance with the terms and conditions
* of the applicable license constitutes a prerequisite to any use of this file.
* Except as otherwise expressly stated in the applicable license,
* such license does not include any other license or rights on this file,
* 4D's and/or its licensors' trademarks and/or other proprietary rights.
* Consequently, no title, copyright or other proprietary rights
* other than those specified in the applicable license is granted.
*/
#ifndef __cp4drt_shared__
#define __cp4drt_shared__

#if VERSIONWIN
#undef Yield
#endif

// L.E. 20/04/09 35 -> 36 pour la v12
// L.E. 23/04/09 36 -> 37 chgt VART et CRCM -> IX86 juste avant la beta de la v12
// L.E. 17/04/13 37 -> 38 added 5 runtime routines
// L.E. 15/11/20 41 -> 42 formulas passed by APPLY TO SELECTION, APPLY TO SUBSELECTION, and ORDER BY are formula objects
// L.E. 16/11/21 43 added rt_DoTruthy runtime routine
#define k4DCompilerRuntimeVersion_12	37
#define k4DCompilerRuntimeVersion_13	38	/* same for v14 */
#define k4DCompilerRuntimeVersion_14With4DPOINTER	39
#define k4DCompilerRuntimeVersion_16WithCollection	40
#define k4DCompilerRuntimeVersion_WithCallStack		41
#define k4DCompilerRuntimeVersion_UseFormulaObjectsInOrderByAndApply	42

#define k4DCompilerRuntimeVersion_Truthy	43
#define k4DCompilerRuntimeVersion_CopyParameters	44
#define k4DCompilerRuntimeVersion_SplitLanguageContextID	45
#define k4DCompilerRuntimeVersion_ASM4D_TextAllocation	46
#define k4DCompilerRuntimeVersion_ForEach2	47
#define k4DCompilerRuntimeVersion_TryExpression	48
#define k4DCompilerRuntimeVersion		k4DCompilerRuntimeVersion_TryExpression

#define k4DCompilerRuntimeVersion_WithThrowError	k4DCompilerRuntimeVersion_16WithCollection

//========================================================================

#pragma pack( push, 2 )


// definitions liees au runtime cp4drt

struct varrefstr
{
    sWORD                   dummy;
    sLONG                    off;
};

struct tLinkEntry
{
	sLONG	fComponentID;
	sLONG	fIndexInJumpTable;
	sLONG	fNameOffset;
	sLONG	fArgsListOffset;
};


struct tComponentEntry
{
	sLONG	fComponentID;
	sLONG	fNameOffset;
};

struct tVarInfoOld
{
	uBYTE	name[32];	// stvar varlimit
	sLONG	offset;
	union
	{
		struct
		{
			uBYTE	theType;					//Bit fort a un si tableau a 2 dims
			uBYTE	VarForm;
			sWORD	Divers;
		} v0;
		uCHAR		TabDeux;
	} variant;
};


struct tVarInfo
{
	sLONG	nameOffset;
	sLONG	offset;
	union
	{
		struct
		{
			uBYTE	theType;					//Bit fort a un si tableau a 2 dims
			uBYTE	VarForm;
			sWORD	Divers;
		} v0;
		uCHAR		TabDeux;
	} variant;
};

// champvar des tableaux non initialises
struct tUninitializedArray
{
    uBYTE		tt;	// typkind
    uBYTE		fil;
    uBYTE		truett;
    uBYTE		fil2;
    sWORD		lenfix;
};


// attention _CallAsmPart2 assume the sizeof( tRtGlobals), penser aussi au swap dans BuildNewJumpTable
struct tRtGlobals
{
	sLONG					nbRuntimeRoutine;
	sLONG					nbUserRoutine;
	sLONG					nbGlobUserRoutine;
	sLONG					nbVarProcess;
	sLONG					sizeVarProcess;	// size of memory block containing the process variables followed by a tProcessGlobals struct
	sLONG					offsetPtrInVarProcess;	// size of process variables alone
	tVarInfo*				tabVarProcess;	// ressource 'IX86' -2. variables process
	sLONG					nbVarGlobal;	// nb de variables inter-process
	sLONG					sizeVarGlobal;	// size of memory block containing the inter process variables followed by a tRtGlobals struct
	sLONG					offsetPtrInVarGlobal;	// size of inter process variables alone
	tVarInfo*				tabVarGlobal;	// ressource 'IX86' -1. variables inter-process
	void**					procArrayPtr;	// jump table	( attention offset hard-code dans CallAsmPart2/ppc)
	sWORD*					procCountPtr;	// compteur d'utilisation pour chaque methode	( attention offset hard-code dans CallAsmPart2/ppc)
	struct tRtGlobals**		fLinkedGlobals;	// tableau des tRtGlobals* des composants
	sLONG					fVersion;	// L.E. 22/02/00 added version info. if high bit is on, we need RangeChecking. Should be k4DCompilerRuntimeVersion
	sLONG					fFlags;		// bit 1: unicode, bit 2: extra runtime info, bit 3: codeIsCompatibleOSX64bit, bit 4: bit5is_x86, bit 5: x86_code_generated
	sLONG*					fLinkedMethods;	// table de correspondance donnant les index dans les jump tables des composants utilises
};

struct tRtGlobals_32
{
	sLONG					nbRuntimeRoutine;
	sLONG					nbUserRoutine;
	sLONG					nbGlobUserRoutine;
	sLONG					nbVarProcess;
	sLONG					sizeVarProcess;
	sLONG					offsetPtrInVarProcess;
	sLONG					tabVarProcess;	// ressource 'IX86' -2. variables process
	sLONG					nbVarGlobal;	// nb de variables inter-process
	sLONG					sizeVarGlobal;
	sLONG					offsetPtrInVarGlobal;
	sLONG					tabVarGlobal;	// ressource 'IX86' -1. variables inter-process
	sLONG					procArrayPtr;	// jump table	( attention offset hard-code dans CallAsmPart2/ppc)
	sLONG					procCountPtr;	// compteur d'utilisation pour chaque methode	( attention offset hard-code dans CallAsmPart2/ppc)
	sLONG					fLinkedGlobals;	// tableau des tRtGlobals* des composants
	sLONG					fVersion;	// L.E. 22/02/00 added version info. if high bit is on, we need RangeChecking. Should be k4DCompilerRuntimeVersion
	sLONG					fFlags;		// bit 1: unicode, bit 2: extra runtime info
	sLONG					fLinkedMethods;	// table de correspondance donnant les index dans les jump tables des composants utilises
};

struct tRtGlobals_64
{
	sLONG					nbRuntimeRoutine;
	sLONG					nbUserRoutine;
	sLONG					nbGlobUserRoutine;
	sLONG					nbVarProcess;
	sLONG					sizeVarProcess;
	sLONG					offsetPtrInVarProcess;
	sLONG8					tabVarProcess;	// ressource 'IX86' -2. variables process
	sLONG					nbVarGlobal;	// nb de variables inter-process
	sLONG					sizeVarGlobal;
	sLONG					offsetPtrInVarGlobal;
	sLONG8					tabVarGlobal;	// ressource 'IX86' -1. variables inter-process
	sLONG8					procArrayPtr;	// jump table	( attention offset hard-code dans CallAsmPart2/ppc)
	sLONG8					procCountPtr;	// compteur d'utilisation pour chaque methode	( attention offset hard-code dans CallAsmPart2/ppc)
	sLONG8					fLinkedGlobals;	// tableau des tRtGlobals* des composants
	sLONG					fVersion;	// L.E. 22/02/00 added version info. if high bit is on, we need RangeChecking. Should be k4DCompilerRuntimeVersion
	sLONG					fFlags;		// bit 1: unicode, bit 2: extra runtime info
	sLONG8					fLinkedMethods;	// table de correspondance donnant les index dans les jump tables des composants utilises
};


struct CompiledModeStackFrame
{
	struct CompiledModeStackFrame*	fParent;
	const unsigned char*		fDescriptor;
	struct tProcessGlobals*		fGlobals;
	sLONG						fLine;
};


struct tProcessGlobals
{
	class VDBLanguageContext_compiled		*fLanguageContext;		// owner context
	union
	{
		struct {
			struct CompiledModeStackFrame**	fStackFramePtr;
			sLONG							unused;
		} callChain;			// runtime version >= 41: adress of stackframe pointer holder
		struct {
			unsigned char*					RoutNamePtr;
			sLONG							NumLine;
		} noCallChain;			// runtime version < 41: Adresse du nom de la routine courante si RangeCheck
	};
	Stack4DFrameID				fLanguageContextID;	// for easy access by runtime to fLanguageContext->GetFrameID()
	char*						abortReturnAddress;
	uBYTE						doingAbort;
	uBYTE						withRangeChecking;	// reproduit le flag rangechecking de tRtGlobals for faster access
	uBYTE						withAssert;
	uBYTE						checkPendingErrors;
	Stack4DFrameID				fRootContextID;		// for easy access by runtime to fLanguageContext->GetRoot()->GetFrameID()
	sLONG						scratch2;			// used on PPC for double to longint

	struct tProcessGlobals**	fLinkedGlobals;	// tableau des tProcessGlobals* des composants
	const char*					fTaskStackAddress;	// top of thread stack
	size_t						fMaxStackUse;	// max stack consumption before alert
};


struct tProcessGlobals_32
{
	sLONG						fLanguageContext;		// owner context
	union
	{
		struct {
			sLONG				fStackFramePtr;
			sLONG				unused;
		} callChain;			// new runtime (bit 4 in tRtGlobals::fFlags): adress of stackframe pointer holder
		struct {
			sLONG				RoutNamePtr;
			sLONG				NumLine;
		} noCallChain;			// old runtime: Adresse du nom de la routine courante si RangeCheck
	};
	uLONG						fLanguageContextID;
	sLONG						abortReturnAddress;
	uBYTE						doingAbort;
	uBYTE						withRangeChecking;	// reproduit le flag rangechecking de tRtGlobals for faster access
	uBYTE						withAssert;
	uBYTE						checkPendingErrors;
	uLONG						fRootContextID;		// for easy access by runtime to fLanguageContext->GetRoot()->GetFrameID()
	sLONG						scratch2;			// used on PPC for double to longint
	sLONG						fLinkedGlobals;	// tableau des tProcessGlobals* des composants
};

struct tProcessGlobals_64
{
	sLONG8						fLanguageContext;		// owner context
	union
	{
		struct {
			sLONG8				fStackFramePtr;
			sLONG				unused;
		} callChain;			// new runtime (bit 4 in tRtGlobals::fFlags): adress of stackframe pointer holder
		struct {
			sLONG8				RoutNamePtr;
			sLONG				NumLine;
		} noCallChain;			// old runtime: Adresse du nom de la routine courante si RangeCheck
	};
	uLONG						fLanguageContextID;
	sLONG8						abortReturnAddress;
	uBYTE						doingAbort;
	uBYTE						withRangeChecking;	// reproduit le flag rangechecking de tRtGlobals for faster access
	uBYTE						withAssert;
	uBYTE						checkPendingErrors;
	uLONG						fRootContextID;		// for easy access by runtime to fLanguageContext->GetRoot()->GetFrameID()
	sLONG						scratch2;			// used on PPC for double to longint
	sLONG8						fLinkedGlobals;	// tableau des tProcessGlobals* des composants
};

#pragma pack( pop )

//========================================================================

struct Asm4d_globals
{
	tRtGlobals*	fRtGlobals;
	char*		fConstants;
	double*		fEpsilon;
};

// range check errors
enum Asm4d_error : sLONG
{
	errOutOfBounds_array,
	errOutOfBounds_param,
	errOutOfBounds_string,
	errOutOfBounds_blob,
	errStringAssignedEmpty
};


using Asm4d_Proc = void ( Asm4d_globals *inGlobPtr, tProcessGlobals *inProcessPtr, sLONG inNbExplicitParam, sLONG inNbParam, ptrchampvar inParams[], champvar *outResult);
using Asm4d_ProcPtr = Asm4d_Proc*;

class Asm4d_handler
{
public:
	virtual	int32_t			GetVersion() = 0;
	virtual	bool			GetRoutines( Asm4d_ProcPtr *outRoutines, size_t inCount) = 0;
};

class Asm4d_handler_v2 : public Asm4d_handler
{
public:
	virtual	bool			Init( sLONG in4DVersion) = 0;
	virtual	void			Deinit() = 0;
};

struct champoper_runtime;

class Asm4d_runtime
{
public:
	virtual double			GetEpsilon() const = 0;
	virtual	bool			Call( tProcessGlobals *inProcessPtr, ptrchampvar inParams[], sLONG inNbParams, sLONG inCommandNumber) = 0;
	virtual	bool			CallPlugin( tProcessGlobals *inProcessPtr, ptrchampvar inParams[], sLONG inNbParams) = 0;
	virtual	bool			CallComponent( Asm4d_globals *inGlobals, tProcessGlobals *inProcessPtr, sLONG inComponentID, sLONG inNumSeg, sLONG inNbExplicitParam, sLONG inNbParam, ptrchampvar inParams[]) = 0;
	virtual	bool			CallRemote( Asm4d_globals *inGlobals, tProcessGlobals *inProcessPtr, sLONG inComponentID, sLONG inNumSeg, sLONG inNbExplicitParam, sLONG inNbParam, ptrchampvar inParams[]) = 0;
	virtual	void			Check( tProcessGlobals *inProcessPtr) = 0;
	virtual	void			AssignPointer( V4DPointer **ioPointer, V4DPointer *inPointer) = 0;
	virtual	void			AssignString( XBOX::VInlineString& outDestination, const XBOX::VInlineString& inSource) = 0;
	virtual	void			AssignPicture( XBOX::VPicture **ioPicture, XBOX::VPicture *inPicture) = 0;
	virtual	void			AssignObject( XBOX::VJSONObject **ioObject, XBOX::VJSONObject *inObject) = 0;
	virtual	void			AssignCollection( XBOX::VJSONArray **ioCollection, XBOX::VJSONArray *inCollection) = 0;
	virtual	void			AssignBlob( STBlob& ioDestination, const STBlob& inSource) = 0;
	virtual	void			AddString( const XBOX::VInlineString& inText1, const XBOX::VInlineString& inText2, XBOX::VInlineString& outDestination) = 0;
	virtual	void			MultiplyString( const XBOX::VInlineString& inText, sLONG inValue, XBOX::VInlineString& outDestination) = 0;
	virtual	void			GetStringChar( tProcessGlobals *inProcessPtr, const XBOX::VInlineString& inText, sLONG inIndex, XBOX::VInlineString& outDestination) = 0;
	virtual	void			SetStringChar( tProcessGlobals *inProcessPtr, const XBOX::VInlineString& inText, sLONG inIndex, XBOX::VInlineString& outDestination) = 0;
	virtual	sLONG			CompareString( tProcessGlobals *inProcessPtr, const XBOX::VInlineString& inText1, const XBOX::VInlineString& inText2) = 0;
	virtual	bool			ContainsKeyword( tProcessGlobals *inProcessPtr, const champvar *inSource, const champvar *inKeyword) = 0;
	virtual	void			ClearString( XBOX::VInlineString& ioString) = 0;
	virtual	void			DisposeString( XBOX::VInlineString& ioString) = 0;
	virtual	datum			AddToDate( const datum& inDate, double inDays) = 0;
	virtual	sLONG			SubstractDate( const datum& inDate1, const datum& inDate2) = 0;
	virtual	V4DPointer*		CreatePointerLocal( tProcessGlobals *inProcessPtr, const champvar *inSource, sLONG inIndex1, sLONG inIndex2) = 0;
	virtual	V4DPointer*		CreatePointerGlobal( tProcessGlobals *inProcessPtr, const champvar *inSource, sLONG inIndex1, sLONG inIndex2) = 0;
	virtual	V4DPointer*		CreatePointerInterprocess( tProcessGlobals *inProcessPtr, const champvar *inSource, sLONG inIndex1, sLONG inIndex2) = 0;
	virtual	V4DPointer*		CreatePointerField( tProcessGlobals *inProcessPtr, const champoper_runtime *inSource) = 0;
	virtual	bool			GetValue( tProcessGlobals *inProcessPtr, ptrchampvar inParams[]) = 0;
	virtual	bool			SetValue( tProcessGlobals *inProcessPtr, ptrchampvar inParams[]) = 0;
	virtual	bool			CastPointerToRef( tProcessGlobals *inProcessPtr, uLONG inCheckMask, ptrchampvar inParams[]) = 0;
	virtual	bool			OperationOnAny( tProcessGlobals *inProcessPtr, sLONG inOperation, const champvar *inValue1, const champvar *inValue2, champvar *outResult) = 0;
	virtual	void			Clear( tProcessGlobals *inProcessPtr, const champoper_runtime *inSource) = 0;
	virtual	void			ClearBlob( STBlob& ioBlob) = 0;
	virtual	void			DisposeValue( champvar *ioValue) = 0;
	virtual	bool			EqualPointers( tProcessGlobals *inProcessPtr, const champvar *inPointer1, const champvar *inPointer2) = 0;
	virtual	bool			GetMember( tProcessGlobals *inProcessPtr, const champvar *inThis, const champvar *inProperty, champvar *outResult) = 0;
	virtual	bool			SetMember( tProcessGlobals *inProcessPtr, const champvar *inThis, const champvar *inProperty, const champvar *inValue) = 0;
	virtual	bool			GetField( tProcessGlobals *inProcessPtr, const champoper_runtime *inFieldRef, champvar *outValue) = 0;
	virtual	bool			SetField( tProcessGlobals *inProcessPtr, const champoper_runtime *inFieldRef, const champvar *inValue) = 0;
	virtual	bool			SetBlobField( tProcessGlobals *inProcessPtr, const champoper_runtime *inFieldRef, const champvar *inValue, const champvar *inIndex) = 0;
	virtual	void			Abort( tProcessGlobals *inProcessPtr) = 0;
	virtual	void			Error( tProcessGlobals *inProcessPtr, Asm4d_error inRuntimeError) = 0;
	virtual	bool			Prolog( CompiledModeStackFrame& inStackFrame) = 0;
	virtual	void			Epilog( CompiledModeStackFrame& inStackFrame) = 0;
	virtual	void			CheckErr( tProcessGlobals *inProcessPtr, sLONG inAfterCallingComponentID) = 0;
	virtual	bool			IsTruthy( const champvar& inValue) = 0;
	virtual	XBOX::VJSONArray*	CopyParameters( tProcessGlobals *inProcessPtr, sLONG inNbParam, sLONG inFirst, ptrchampvar inParams[]) = 0;
	virtual	void			AssignUniChars( champvar *outDestination, const char16_t *inString, size_t inLength) = 0;
	virtual double			Pow(double x, double y) = 0;
	virtual double			Floor(double x) = 0;
	virtual void			BeginTry( tProcessGlobals *inProcessPtr) = 0;
	virtual void			EndTry( tProcessGlobals *inProcessPtr) = 0;
};

//========================================================================



#endif
