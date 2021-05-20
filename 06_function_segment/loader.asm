%include "inc.asm"

org 0x9000

jmp ENTRY_SEGMENT

;section关键字用来定义源码级别的逻辑关系
[section .gdt]

;---------------------------------------GDT definition---------------------------------------

;                                         段基址          段界限      		    段属性
GDT_ENTRY	:	Descriptor	    0,		     0,			      0
CODE32_DESC	:	Descriptor	    0,		Code32SegLen - 1,	DA_C + DA_32 
VIDEO_DESC	:	Descriptor    	 0xb8000,	  0x7fff,               DA_DRWA + DA_32
STACK32_DESC	:	Descriptor	    0,		TopOfStack32,		DA_DRW + DA_32
FUNCTION_DESC	:	Descriptor	    0,	       FunctionSegLen - 1,	DA_C + DA_32
; Gate Descriptor
; 和上面的GDT描述符一样都是占用8字节，但是两者的数据结构不同
; Call Gate			     选择子		 偏移	    参数个数	    属性
FUNC_CG_ADD_DESC	Gate	FunctionSelector,	CG_Add,		0,   	DA_386CGate
FUNC_CG_SUB_DESC	Gate	FunctionSelector,	CG_Sub,		0,   	DA_386CGate

;------------------------------------------GDT end--------------------------------------------

GdtLen	equ	$ - GDT_ENTRY
GdtPtr:
	dw GdtLen - 1
	dd 0

;-------------------------GDT Selector---------------------

Code32Selector		equ	(0x0001 << 3) + SA_TIG + SA_RPL0
VideoSelector		equ	(0x0002 << 3) + SA_TIG + SA_RPL0 
Stack32Selector		equ	(0x0003 << 3) + SA_TIG + SA_RPL0 
FunctionSelector	equ	(0x0004 << 3) + SA_TIG + SA_RPL0 
FunctionAddSelector	equ	(0x0005 << 3) + SA_TIG + SA_RPL0 
FunctionSubSelector	equ	(0x0006 << 3) + SA_TIG + SA_RPL0 

;-----------------------------------------------------------

;end of [section .gdt]

TopOfStack16	equ 0x7c00

[section .data]
[bits 32]
DATA32_SEGMENT:
	WELCOME	db "Welcome To RenOS !!!", 0
	WELCOME_OFFSET	equ	WELCOME - $$ ; $$ 是代码节内的偏移地址
	HELLO_WORLD	db "Hello World !", 0
	HELLO_WORLD_OFFSET	equ	HELLO_WORLD - $$

Data32SegLen	equ	$ - DATA32_SEGMENT

[section .s16]
[bits 16]
ENTRY_SEGMENT:
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, TopOfStack16

	;initialize GDT for 32 bits code segment
;	mov eax, 0
;	mov ax, cs
;	shl eax, 4
;	add eax, CODE32_SEGMENT
;	mov word [CODE32_DESC + 2], ax
;	shr eax, 16
;	mov byte [CODE32_DESC + 4], al
;	mov byte [CODE32_DESC + 7], ah

	mov esi, CODE32_SEGMENT
	mov edi, CODE32_DESC
	call InitDescItem

	mov esi, STACK32_SEGMENT
	mov edi, STACK32_DESC
	call InitDescItem

	mov esi, FUNCTION_SEGMENT
	mov edi, FUNCTION_DESC
	call InitDescItem

	;initialize GDT pointer struct
	mov eax, 0
	mov ax, ds
	shl eax, 4
	add eax, GDT_ENTRY
	mov dword [GdtPtr + 2], eax

	;1. load GDT
	lgdt [GdtPtr]

	;2. close interrupt
	cli

	;3. open A20
	in al, 0x92
	or al, 00000010b
	out 0x92, al

	;4. enter protect mode
	mov eax, cr0
	or eax, 0x01
	mov cr0, eax

	;5. jump to 32 bits code
	jmp dword Code32Selector : 0

; esi	--> code segment label
; edi	--> descriptor	label
InitDescItem:
	push eax

	mov eax, 0
	mov ax, cs
	shl eax, 4
	add eax, esi
	mov word [edi + 2], ax
	shr eax, 16
	mov byte [edi + 4], al
	mov byte [edi + 7], ah

	pop eax
	ret

[section .s32]
[bits 32]
CODE32_SEGMENT:
	mov ax, VideoSelector
	mov gs, ax	;显示段的选择子

	mov ax, Stack32Selector
	mov ss, ax	;栈空间的选择子

	mov eax, TopOfStack32
	mov esp, eax	;栈顶给esp寄存器,实际上是相对于栈段的偏移

	mov ax, 2
	mov bx, 1
;	call FunctionAddSelector:0	
;	call FunctionSubSelector:0	

	call FunctionSelector : CG_Add
	call FunctionSelector : CG_Sub
	jmp $

Code32SegLen	equ	$ - CODE32_SEGMENT

[section .func]
[bits 32]
FUNCTION_SEGMENT:

; ax --> a
; bx --> b
; 
; return:
;	cx --> a + b
AddFunc:
	mov cx, ax
	add cx, bx
	retf	;return far 使用的是长跳转
CG_Add	equ	AddFunc - $$

; ax --> a
; bx --> b
; 
; return:
;	cx --> a - b
SubFunc:
	mov cx, ax
	sub cx, bx
	retf	;return far 使用的是长跳转
CG_Sub	equ	SubFunc - $$

FunctionSegLen	equ	$ - FUNCTION_SEGMENT

;--------------------开辟一个4k的栈空间--------------------
[section .gs]
[bits 32]
STACK32_SEGMENT:
    times 1024 * 4 db 0

Stack32SegLen equ $ - STACK32_SEGMENT
TopOfStack32  equ Stack32SegLen - 1
;-----------------------------------------------------------
