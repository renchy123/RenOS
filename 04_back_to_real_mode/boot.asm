org 0x7c00

jmp short start
nop

define:
	BaseOfStack 	equ 0x7c00
	BaseOfLoader 	equ 0x9000
	RootEntryOffset equ 19
	RootEntryLength equ 14
	EntryItemLength equ 32
	FatEntryOffset	equ 1
	FatEntryLength	equ 9

header:
    BS_OEMName     db "REN Soft"
    BPB_BytsPerSec dw 512
    BPB_SecPerClus db 1
    BPB_RsvdSecCnt dw 1
    BPB_NumFATs    db 2
    BPB_RootEntCnt dw 224
    BPB_TotSec16   dw 2880
    BPB_Media      db 0xF0
    BPB_FATSz16    dw 9
    BPB_SecPerTrk  dw 18
    BPB_NumHeads   dw 2
    BPB_HiddSec    dd 0
    BPB_TotSec32   dd 0
    BS_DrvNum      db 0
    BS_Reserved1   db 0
    BS_BootSig     db 0x29
    BS_VolID       dd 0
    BS_VolLab      db "REN-OS-0.01"
    BS_FileSysType db "FAT12   "

start:
	mov ax, cs
	mov ss, ax
	mov ds, ax
	mov es, ax
	mov sp, BaseOfStack

	mov ax, RootEntryOffset
	mov cx, RootEntryLength
	mov bx, Buf
	call ReadSector

	mov si, Target
	mov cx, TarLen
	mov dx, 0
	call FindEntry

	cmp dx, 0
	jz output

	;bx save the directory entry address
	mov si, bx
	mov di, EntryItem
	mov cx, EntryItemLength

	call MemCpy
	
	mov ax, FatEntryLength
	mov cx, [BPB_BytsPerSec]
	mul cx
	mov bx, BaseOfLoader
	sub bx, ax

	mov ax, FatEntryOffset
	mov cx, FatEntryLength

	call ReadSector
	
	mov dx, [EntryItem + 0x1A]
	mov si, BaseOfLoader
	
loading:
	mov ax, dx
	add ax, 31
	mov cx, 1
	push dx
	push bx
	mov bx, si
	call ReadSector
	pop bx
	pop cx
	call FatVec
	cmp dx, 0xFF7
	;jnb output
	jnb BaseOfLoader
	add si, 512
	jmp loading

output:
	;mov bp, MsgStr
	;mov cx, MsgLen 
	mov bp, BaseOfLoader
	mov cx, [EntryItem + 0x1c]
	call Print

last:
	hlt
	jmp last

;cx       --> index
;bx       --> fat table address
;
;return:
;      dx --> fat[index]
FatVec:
	mov ax,cx
	mov cl, 2
	div cl

	push ax
	
	mov ah, 0
	mov cx, 3
	mul cx
	mov cx, ax

	pop ax

	cmp ah, 0
	jz even
	jmp odd

even:	;FatVec[j] = ((Fat[i+1] & 0x0F) << 8) | Fat[i];
	mov dx, cx
	add dx, 1
	add dx, bx
	mov bp, dx
	mov dl, byte [bp]	
	and dl, 0x0F
	shl dx, 8
	add cx, bx
	mov bp, cx
	or dl, byte [bp]
	jmp return
odd:    ;FatVec[j+1] = (Fat[i+2] << 4) | ((Fat[i+1] >> 4) & 0x0F)
	mov dx, cx
	add dx, 2
	add dx, bx
	mov bp, dx
	mov dl, byte [bp]
	mov dh, 0
	shl dx, 4
	add cx, 1
	add cx, bx
	mov bp, cx
	mov cl, byte [bp]
	shr cl, 4
	and cl, 0x0F
	mov ch, 0
	or  dx, cx

return:
	ret

;ds:si    --> source
;es:di    --> destination
;cx       --> length
MemCpy:
	push si
	push di
	push cx
	push ax

	cmp si, di
	
	;if (si > di)
	ja btoe 
	
	add si, cx
	add di, cx
	dec si
	dec di

	jmp etob

btoe:
	cmp cx, 0
	jz done
	mov al, [si]
	mov byte [di], al
	inc si
	inc di
	dec cx
	jmp btoe

etob:
	cmp cx, 0
	jz done
	mov al, [si]
	mov byte [di],al
	dec si
	dec di
	dec cx
	jmp etob

done:
	pop ax
	pop cx
	pop di
	pop si

	ret

;dx       --> root entry item count
;es:bx    --> root entry offset address
;ds:si    --> target string
;cx       --> target length
;
;return:
;       (dx != 0) ? exist : noexist
;       exist   --> bx is the target entry
FindEntry:
	push di
	push bp
	push cx
	
	mov dx, [BPB_RootEntCnt]
	;can not use sp to directly access the top data of the stack
	mov bp, sp

find:
	cmp dx, 0
	jz noexist
	mov di, bx
	mov cx, [bp]
	call MemCmp
	cmp cx, 0
	jz exist
	add bx, 32
	dec dx
	jmp find

exist:
noexist:
	pop cx
	pop bp
	pop di

	ret

;ds:si    --> source
;es:di    --> destination
;cx       --> length
;
;return:
;	(cx == 0) ? equal : noequal
MemCmp:
	push si
	push di
	push ax
compare:
	cmp cx, 0
	jz equal
	mov al, [si]
	cmp al, byte [di]
	jz goon
	jmp noequal
goon:
	inc si
	inc di
	dec cx
	jmp compare
equal:
noequal:
	pop ax
	pop di
	pop si
	ret

;es:bp --> string address
;cx    --> string length
Print:
	;here are the print parameters of the BIOS
	mov dx, 0 ;upper left corner
	mov ax, 0x1301
	mov bx, 0x0007
	int 0x10
	ret

;no parameters
ResetFloppy:
	push ax
	push dx

	mov ah, 0x00
	mov dl, [BS_DrvNum]
	int 0x13

	pop dx
	pop ax

	ret
	
;ax      --> logic sector number
;cx      --> number of sector
;es:bx   --> target address
ReadSector:
	call ResetFloppy

	push bx
	push cx

	mov bl, [BPB_SecPerTrk]
	div bl
	mov cl, ah
	add cl, 1
	mov ch, al
	shr ch, 1
	mov dh, al
	and dh, 1
	mov dl, [BS_DrvNum]

	pop ax
	pop bx

	;BIOS parameter	
	mov ah, 0x02
read:
	int 0x13
	jc read

	ret

MsgStr db "No LOADER ..." 
MsgLen equ ($-MsgStr)
Target db "LOADER     "
TarLen equ ($-Target)

EntryItem times EntryItemLength db 0x00
Buf:
	times 510-($-$$) db 0x00
	db 0x55, 0xaa

