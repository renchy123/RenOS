%include "inc.asm"

org 0x9000

jmp CODE16_SEGMENT

;section关键字用来定义源码级别的逻辑关系
[section .gdt]

;GDT definition

;                                         段基址          段界限      		    段属性
GDT_ENTRY	:	Descriptor	    0,		     0,			      0
CODE32_DESC	:	Descriptor	    0,		Code32SegLen - 1,	DA_C + DA_32
VIDEO_DESC	:	Descriptor    	 0xb8000,	  0x7fff,               DA_DRWA + DA_32
DATA32_DESC	:	Descriptor	    0,		Data32SegLen - 1,       DA_DR + DA_32
STACK_DESC	:	Descriptor	    0,		 TopOfStackInit,	        DA_DRW + DA_32

;GDT end

GdtLen	equ	$ - GDT_ENTRY
GdtPtr:
	dw GdtLen - 1
	dd 0

;GDT Selector

Code32Selector	equ	(0x0001 << 3) + SA_TIG + SA_RPL0
VideoSelector	equ	(0x0002 << 3) + SA_TIG + SA_RPL0 
Data32Selector	equ	(0x0003 << 3) + SA_TIG + SA_RPL0 
StackSelector	equ	(0x0004 << 3) + SA_TIG + SA_RPL0 

;end of [section .gdt]

TopOfStackInit equ 0x7c00

[section .data]
[bits 32]
DATA32_SEGMENT:
	WELCOME	db "Welcome To RenOS !!!", 0
	WELCOME_OFFSET	equ WELCOME - $$ ; $$ 是代码节内的偏移地址

Data32SegLen	equ	$ - DATA32_SEGMENT

[section .s16]
[bits 16]
CODE16_SEGMENT:
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, TopOfStackInit

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

	mov esi, DATA32_SEGMENT
	mov edi, DATA32_DESC
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

	mov ax, Data32Selector
	mov ds, ax	;数据段的选择子

	mov ax, StackSelector
	mov ss, ax	;栈空间的选择子

	mov ebp, WELCOME_OFFSET
	mov bx, 0x0c 	;黑底红字
	mov dh, 12	;12行
	mov dl, 28	;28列
	call PrintString

	jmp $

; ds:ebp--> string address
;在32位保护模式下，使用段基址+段内偏移，硬件自动读取GDT表
; bx	--> atttribute
; dx	--> dh : row,  dl : column
PrintString:
	push ebp
	push eax
	push edi
	push cx
	push dx
	
print:
	mov cl, [ds:ebp]
	cmp cl, 0
	je end
	mov eax, 80     ;文本模式下的屏幕可以显示25行，每行80列
	mul dh 		;x86 32位模式下乘法，结果会在eax中
	add al, dl
	shl ax, 1	;左移1位就是x2
	mov edi, eax
	mov ah, bl	;ah 字符属性
	mov al, cl	;al 字符内容
	mov [gs:edi], ax
	inc ebp
	inc dl
	jmp print

end:
	pop dx
	pop cx
	pop edi
	pop eax
	pop ebp

	ret


Code32SegLen	equ	$ - CODE32_SEGMENT
