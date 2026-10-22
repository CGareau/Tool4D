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

#include "$asm4d.h"

Asm4d_runtime*	g;

void InitConstants();
#if WITH(WIN_COMPILE_BASE_AS_CPP)
void DeInitConstants();
#endif

extern "C"
__attribute__((visibility("default"))) Asm4d_handler *asm4d_init( Asm4d_runtime *inRuntime)
{
	g = inRuntime;
	Asm4d_handler_impl *handler = &Asm4d_handler_impl::Get();
	return handler;
}


sLONG Asm4d_handler_impl::GetVersion()
{
	return 2;
}


bool Asm4d_handler_impl::GetRoutines( Asm4d_ProcPtr *outRoutines, size_t inCount)
{
	if (inCount != sFunctionCount)
		return false;
	memcpy(outRoutines, &sFunctions[0], sFunctionCount * sizeof(Asm4d_ProcPtr));
	return true;
}


bool Asm4d_handler_impl::Init( sLONG in4DVersion)
{
	InitConstants();
	return true;
}


void Asm4d_handler_impl::Deinit()
{
#if WITH(WIN_COMPILE_BASE_AS_CPP)
	DeInitConstants();
	g = nullptr;
#endif
}


#if WITH(WIN_COMPILE_BASE_AS_CPP)
extern "C" {
	int _fltused = 0;
	int _tls_index = 0;
	int _Init_thread_epoch = 0;
	int _Init_thread_header = 0;
	int _Init_thread_footer = 0;
	int atexit = 0;
	int __std_terminate = 0;
	int __CxxFrameHandler = 0;
}

extern "C" void* memcpy(void* dest, const void* src, size_t len)
{
	char* d = (char*)dest;
	const char* s = (const char*)src;
	while (len--)
		*d++ = *s++;
	return dest;
}

extern "C" void* memset(void* dest, int val, size_t len)
{
	unsigned char* ptr = (unsigned char* ) dest;
	while (len-- > 0)
		*ptr++ = (unsigned char) val;
	return dest;
}

#ifdef __x86_64__
// a call to __chkstk() is injected in each function prolog to commit each 4k page of the stack
// rax contains the stack size needed by the function.
// __chkstk() calls are not generated if flag -mno-stack-arg-probe is passed to clang, or if size is less than -mstack-probe-size
extern "C" void __chkstk()
{
	__asm__(".att_syntax\n"
		"push %rcx \n"
		"push %rax \n"
		"cmp $0x1000,%rax \n"
		"lea 24(%rsp), %rcx \n"
		"jb done \n"
		"loop:"
		"sub $0x1000,%rcx \n"
		"test %rcx,(%rcx) \n"
		"sub $0x1000,%rax \n"
		"cmp $0x1000,%rax \n"
		"ja loop \n"
		"done: \n"
		"sub %rax,%rcx\n"
		"test %rcx,(%rcx)\n"
		"pop %rax \n"
		"pop %rcx \n"

	);;
}
#endif

#endif
