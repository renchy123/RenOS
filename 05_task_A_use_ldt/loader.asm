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
DATA32_DESC	:	Descriptor	    0,		Data32SegLen - 1,       DA_DR + DA_32
STACK32_DESC	:	Descriptor	    0,		 TopOfStack32,	        DA_DRW + DA_32
CODE16_DESC	:	Descriptor	    0,	          0xffff,               DA_C
UPDATE_DESC	:	Descriptor	    0,		  0xffff,	        DA_DRW
TASK_A_LDT_DESC	:	Descriptor	    0,           TaskALdtLen - 1,	DA_LDT

;------------------------------------------GDT end--------------------------------------------

GdtLen	equ	$ - GDT_ENTRY
GdtPtr:
	dw GdtLen - 1
	dd 0

;-------------------------GDT Selector---------------------

Code32Selector		equ	(0x0001 << 3) + SA_TIG + SA_RPL0
VideoSelector		equ	(0x0002 << 3) + SA_TIG + SA_RPL0 
Data32Selector		equ	(0x0003 << 3) + SA_TIG + SA_RPL0 
Stack32Selector		equ	(0x0004 << 3) + SA_TIG + SA_RPL0 
Code16Selector		equ	(0x0005 << 3) + SA_TIG + SA_RPL0 
UpdateSelector		equ	(0x0006 << 3) + SA_TIG + SA_RPL0 
TaskALdtSelector	equ	(0x0007 << 3) + SA_TIG + SA_RPL0 

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

	;此标签处偏移3字节是段间跳转的段基址
	mov [BACK_TO_REAL_MODE + 3], ax

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

	mov esi, STACK32_SEGMENT
	mov edi, STACK32_DESC
	call InitDescItem

	mov esi, CODE16_SEGMENT
	mov edi, CODE16_DESC
	call InitDescItem

	mov esi, TASK_A_LDT_ENTRY
	mov edi, TASK_A_LDT_DESC
	call InitDescItem

	mov esi, TASK_A_CODE32_SEGMENT
	mov edi, TASK_A_CODE32_DESC
	call InitDescItem

	mov esi, TASK_A_DATA32_SEGMENT
	mov edi, TASK_A_DATA32_DESC
	call InitDescItem

	mov esi, TASK_A_STACK32_SEGMENT
	mov edi, TASK_A_STACK32_DESC
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

BACK_ENTRY_SEGMENT:
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, TopOfStack16

	in al, 0x92
	and al, 11111101b
	out 0x92, al
	sti
	
	mov bp, HELLO_WORLD
	mov cx, 12
	mov dx, 0
	mov ax, 0x1301
	mov bx, 0x0007
	int 0x10

	jmp $

[section .s16]
[bits 16]
CODE16_SEGMENT:
	;刷新每个段寄存器所对应cache
	;在32位保护模式的时候，cpu会将gdt表中数据放到各个段寄存器对应cache
	mov ax, UpdateSelector
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax

	mov eax, cr0
	and al, 11111110b
	mov cr0, eax

BACK_TO_REAL_MODE:	
	jmp 0 : BACK_ENTRY_SEGMENT

Code16SegLen	equ	$ - CODE16_SEGMENT

[section .s32]
[bits 32]
CODE32_SEGMENT:
	mov ax, VideoSelector
	mov gs, ax	;显示段的选择子

	mov ax, Data32Selector
	mov ds, ax	;数据段的选择子

	mov ax, Stack32Selector
	mov ss, ax	;栈空间的选择子

	mov eax, TopOfStack32
	mov esp, eax	;栈顶给esp寄存器,实际上是相对于栈段的偏移

	mov ebp, WELCOME_OFFSET
	mov bx, 0x0c 	;黑底红字
	mov dh, 12	;12行
	mov dl, 28	;28列
	call PrintString

	mov ax, TaskALdtSelector
	lldt ax
	;根据该段选择子的属性，跳转会从LDT表中来找基址
	jmp TaskACode32Selector : 0

	;jmp Code16Selector : 0

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

[section .gs]
[bits 32]
STACK32_SEGMENT:
	times 1024 * 4 db 0

Stack32SegLen	equ $ - STACK32_SEGMENT
TopOfStack32  	equ Stack32SegLen - 1


;==================================================================
;                             
;                        Task A Code
;
;==================================================================

[section .task-a-ldt]
;---------------------------------------LDT definition---------------------------------------

;                                        	 段基址          段界限      		  段属性
TASK_A_LDT_ENTRY	:
TASK_A_CODE32_DESC	:	Descriptor	   0,      TaskACode32SegLen-1,       DA_C + DA_32
TASK_A_DATA32_DESC	:	Descriptor	   0,      TaskAData32SegLen-1,       DA_DR + DA_32
TASK_A_STACK32_DESC	:	Descriptor	   0,	   TaskAStack32SegLen-1,      DA_DRW + DA_32

;------------------------------------------LDT end--------------------------------------------

TaskALdtLen	equ	$ - TASK_A_LDT_ENTRY

;-------------------------LDT Selector---------------------

TaskACode32Selector	equ	(0x0000 << 3) + SA_TIL + SA_RPL0
TaskAData32Selector	equ	(0x0001 << 3) + SA_TIL + SA_RPL0
TaskAStack32Selector	equ	(0x0002 << 3) + SA_TIL + SA_RPL0

;-----------------------------------------------------------

[section .task-a-dat]
[bits 32]
TASK_A_DATA32_SEGMENT:
	TASK_A_STRING	db "This is Task A !!!", 0
	TASK_A_STRING_OFFSET	equ	TASK_A_STRING - $$

TaskAData32SegLen 	equ 	$ - TASK_A_DATA32_SEGMENT

[section .task-a-gs]
[bits 32]
TASK_A_STACK32_SEGMENT:
	times 1024 db 0

TaskAStack32SegLen	equ	$ - TASK_A_STACK32_SEGMENT
TaskATopOfStack32	equ	TaskAStack32SegLen - 1

[section .task-a-s32]
[bits 32]
TASK_A_CODE32_SEGMENT:
	mov ax, VideoSelector
	mov gs, ax

	mov ax, TaskAStack32Selector
	mov ss, ax

	mov eax, TaskATopOfStack32
	mov esp, eax

	mov ax, TaskAData32Selector
	mov ds, ax

	mov ebp, TASK_A_STRING_OFFSET
	mov bx, 0x0c
	mov dh, 14
	mov dl, 29

	call TaskA_PrintString

	jmp Code16Selector : 0
	

;=========================================================================
;
;           以下打印函数从上面复制而来，不同段之间的函数不能互相调用
;
;=========================================================================
; ds:ebp--> string address
;在32位保护模式下，使用段基址+段内偏移，硬件自动读取GDT表
; bx	--> atttribute
; dx	--> dh : row,  dl : column
TaskA_PrintString:
	push ebp
	push eax
	push edi
	push cx
	push dx
	
TaskA_print:
	mov cl, [ds:ebp]
	cmp cl, 0
	je TaskA_end
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
	jmp TaskA_print

TaskA_end:
	pop dx
	pop cx
	pop edi
	pop eax
	pop ebp

	ret
;===================================================================
;===================================================================

TaskACode32SegLen 	equ 	$ - TASK_A_CODE32_SEGMENT
