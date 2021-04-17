;Segment Attribute
;data read write access
DA_32	equ	0x4000
DA_DR	equ	0x90
DA_DRW	equ	0x92
DA_DRWA	equ	0x93
;code read consistent
DA_C	equ	0x98
DA_CR	equ 	0x9a
DA_CCO	equ	0x9c
DA_CCOR	equ	0x9e

;Selector Attribute
;selector attribute request priority level
SA_RPL0	equ	0
SA_RPL1	equ	1
SA_RPL2	equ	2
SA_RPL3	equ	3

;table indictor gdt ldt
SA_TIG	equ	0
SA_TIL	equ	4

;Descriptor
;Usage: Descriptor Base, Limit, Attribute
;	Base:	32 bits
;	Limit:	32 bits (low 20 bits available)
;	Attr:	16 bits (lower 4 bits of high byte always 0)
%macro Descriptor 3			;段基址， 段界限， 段属性
	dw %2 & 0xffff			;段界限1
	dw %1 & 0xffff			;段基址1
	db (%1 >> 16) & 0xff		;段基址2
	dw ((%2 >> 8) & 0xf00 ) | (%3 & 0xf0ff)	;属性1 + 段界限2 + 属性2
	db (%1 >> 24) & 0xff		;段基址3
%endmacro				;一共8 bytes
	
