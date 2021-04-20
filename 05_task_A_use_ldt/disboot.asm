00007C00  EB3C              jmp short 0x7c3e
00007C02  90                nop
00007C03  52                push dx
00007C04  45                inc bp
00007C05  4E                dec si
00007C06  20536F            and [bp+di+0x6f],dl
00007C09  667400            o32 jz 0x7c0c
00007C0C  0201              add al,[bx+di]
00007C0E  0100              add [bx+si],ax
00007C10  02E0              add ah,al
00007C12  00400B            add [bx+si+0xb],al
00007C15  F00900            lock or [bx+si],ax
00007C18  1200              adc al,[bx+si]
00007C1A  0200              add al,[bx+si]
00007C1C  0000              add [bx+si],al
00007C1E  0000              add [bx+si],al
00007C20  0000              add [bx+si],al
00007C22  0000              add [bx+si],al
00007C24  0000              add [bx+si],al
00007C26  2900              sub [bx+si],ax
00007C28  0000              add [bx+si],al
00007C2A  005245            add [bp+si+0x45],dl
00007C2D  4E                dec si
00007C2E  2D4F53            sub ax,0x534f
00007C31  2D302E            sub ax,0x2e30
00007C34  3031              xor [bx+di],dh
00007C36  46                inc si
00007C37  41                inc cx
00007C38  54                push sp
00007C39  3132              xor [bp+si],si
00007C3B  2020              and [bx+si],ah
00007C3D  208CC88E          and [si-0x7138],cl
00007C41  D08ED88E          ror byte [bp-0x7128],1
00007C45  C0BC007CB8        sar byte [si+0x7c00],byte 0xb8
00007C4A  1300              adc ax,[bx+si]
00007C4C  B90E00            mov cx,0xe
00007C4F  BBFD7D            mov bx,0x7dfd
00007C52  E84A01            call 0x7d9f
00007C55  BED27D            mov si,0x7dd2
00007C58  B90B00            mov cx,0xb
00007C5B  BA0000            mov dx,0x0
00007C5E  E8E700            call 0x7d48
00007C61  83FA00            cmp dx,byte +0x0
00007C64  744B              jz 0x7cb1
00007C66  89DE              mov si,bx
00007C68  BFDD7D            mov di,0x7ddd
00007C6B  B92000            mov cx,0x20
00007C6E  E8A600            call 0x7d17
00007C71  B80900            mov ax,0x9
00007C74  8B0E0B7C          mov cx,[0x7c0b]
00007C78  F7E1              mul cx
00007C7A  BB0090            mov bx,0x9000
00007C7D  29C3              sub bx,ax
00007C7F  B80100            mov ax,0x1
00007C82  B90900            mov cx,0x9
00007C85  E81701            call 0x7d9f
00007C88  8B16F77D          mov dx,[0x7df7]
00007C8C  BE0090            mov si,0x9000
00007C8F  89D0              mov ax,dx
00007C91  83C01F            add ax,byte +0x1f
00007C94  B90100            mov cx,0x1
00007C97  52                push dx
00007C98  53                push bx
00007C99  89F3              mov bx,si
00007C9B  E80101            call 0x7d9f
00007C9E  5B                pop bx
00007C9F  59                pop cx
00007CA0  E81B00            call 0x7cbe
00007CA3  81FAF70F          cmp dx,0xff7
00007CA7  0F835513          jnc near 0x9000
00007CAB  81C60002          add si,0x200
00007CAF  EBDE              jmp short 0x7c8f
00007CB1  BD0090            mov bp,0x9000
00007CB4  8B0EF97D          mov cx,[0x7df9]
00007CB8  E8CB00            call 0x7d86
00007CBB  F4                hlt
00007CBC  EBFD              jmp short 0x7cbb
00007CBE  89C8              mov ax,cx
00007CC0  B102              mov cl,0x2
00007CC2  F6F1              div cl
00007CC4  50                push ax
00007CC5  B400              mov ah,0x0
00007CC7  B90300            mov cx,0x3
00007CCA  F7E1              mul cx
00007CCC  89C1              mov cx,ax
00007CCE  58                pop ax
00007CCF  80FC00            cmp ah,0x0
00007CD2  7402              jz 0x7cd6
00007CD4  EB1B              jmp short 0x7cf1
00007CD6  89CA              mov dx,cx
00007CD8  83C201            add dx,byte +0x1
00007CDB  01DA              add dx,bx
00007CDD  89D5              mov bp,dx
00007CDF  8A5600            mov dl,[bp+0x0]
00007CE2  80E20F            and dl,0xf
00007CE5  C1E208            shl dx,byte 0x8
00007CE8  01D9              add cx,bx
00007CEA  89CD              mov bp,cx
00007CEC  0A5600            or dl,[bp+0x0]
00007CEF  EB25              jmp short 0x7d16
00007CF1  89CA              mov dx,cx
00007CF3  83C202            add dx,byte +0x2
00007CF6  01DA              add dx,bx
00007CF8  89D5              mov bp,dx
00007CFA  8A5600            mov dl,[bp+0x0]
00007CFD  B600              mov dh,0x0
00007CFF  C1E204            shl dx,byte 0x4
00007D02  83C101            add cx,byte +0x1
00007D05  01D9              add cx,bx
00007D07  89CD              mov bp,cx
00007D09  8A4E00            mov cl,[bp+0x0]
00007D0C  C0E904            shr cl,byte 0x4
00007D0F  80E10F            and cl,0xf
00007D12  B500              mov ch,0x0
00007D14  09CA              or dx,cx
00007D16  C3                ret
00007D17  56                push si
00007D18  57                push di
00007D19  51                push cx
00007D1A  50                push ax
00007D1B  39FE              cmp si,di
00007D1D  7708              ja 0x7d27
00007D1F  01CE              add si,cx
00007D21  01CF              add di,cx
00007D23  4E                dec si
00007D24  4F                dec di
00007D25  EB0E              jmp short 0x7d35
00007D27  83F900            cmp cx,byte +0x0
00007D2A  7417              jz 0x7d43
00007D2C  8A04              mov al,[si]
00007D2E  8805              mov [di],al
00007D30  46                inc si
00007D31  47                inc di
00007D32  49                dec cx
00007D33  EBF2              jmp short 0x7d27
00007D35  83F900            cmp cx,byte +0x0
00007D38  7409              jz 0x7d43
00007D3A  8A04              mov al,[si]
00007D3C  8805              mov [di],al
00007D3E  4E                dec si
00007D3F  4F                dec di
00007D40  49                dec cx
00007D41  EBF2              jmp short 0x7d35
00007D43  58                pop ax
00007D44  59                pop cx
00007D45  5F                pop di
00007D46  5E                pop si
00007D47  C3                ret
00007D48  57                push di
00007D49  55                push bp
00007D4A  51                push cx
00007D4B  8B16117C          mov dx,[0x7c11]
00007D4F  89E5              mov bp,sp
00007D51  83FA00            cmp dx,byte +0x0
00007D54  7413              jz 0x7d69
00007D56  89DF              mov di,bx
00007D58  8B4E00            mov cx,[bp+0x0]
00007D5B  E80F00            call 0x7d6d
00007D5E  83F900            cmp cx,byte +0x0
00007D61  7406              jz 0x7d69
00007D63  83C320            add bx,byte +0x20
00007D66  4A                dec dx
00007D67  EBE8              jmp short 0x7d51
00007D69  59                pop cx
00007D6A  5D                pop bp
00007D6B  5F                pop di
00007D6C  C3                ret
00007D6D  56                push si
00007D6E  57                push di
00007D6F  50                push ax
00007D70  83F900            cmp cx,byte +0x0
00007D73  740D              jz 0x7d82
00007D75  8A04              mov al,[si]
00007D77  3A05              cmp al,[di]
00007D79  7402              jz 0x7d7d
00007D7B  EB05              jmp short 0x7d82
00007D7D  46                inc si
00007D7E  47                inc di
00007D7F  49                dec cx
00007D80  EBEE              jmp short 0x7d70
00007D82  58                pop ax
00007D83  5F                pop di
00007D84  5E                pop si
00007D85  C3                ret
00007D86  BA0000            mov dx,0x0
00007D89  B80113            mov ax,0x1301
00007D8C  BB0700            mov bx,0x7
00007D8F  CD10              int 0x10
00007D91  C3                ret
00007D92  50                push ax
00007D93  52                push dx
00007D94  B400              mov ah,0x0
00007D96  8A16247C          mov dl,[0x7c24]
00007D9A  CD13              int 0x13
00007D9C  5A                pop dx
00007D9D  58                pop ax
00007D9E  C3                ret
00007D9F  E8F0FF            call 0x7d92
00007DA2  53                push bx
00007DA3  51                push cx
00007DA4  8A1E187C          mov bl,[0x7c18]
00007DA8  F6F3              div bl
00007DAA  88E1              mov cl,ah
00007DAC  80C101            add cl,0x1
00007DAF  88C5              mov ch,al
00007DB1  D0ED              shr ch,1
00007DB3  88C6              mov dh,al
00007DB5  80E601            and dh,0x1
00007DB8  8A16247C          mov dl,[0x7c24]
00007DBC  58                pop ax
00007DBD  5B                pop bx
00007DBE  B402              mov ah,0x2
00007DC0  CD13              int 0x13
00007DC2  72FC              jc 0x7dc0
00007DC4  C3                ret
00007DC5  4E                dec si
00007DC6  6F                outsw
00007DC7  204C4F            and [si+0x4f],cl
00007DCA  41                inc cx
00007DCB  44                inc sp
00007DCC  45                inc bp
00007DCD  52                push dx
00007DCE  202E2E2E          and [0x2e2e],ch
00007DD2  4C                dec sp
00007DD3  4F                dec di
00007DD4  41                inc cx
00007DD5  44                inc sp
00007DD6  45                inc bp
00007DD7  52                push dx
00007DD8  2020              and [bx+si],ah
00007DDA  2020              and [bx+si],ah
00007DDC  2000              and [bx+si],al
00007DDE  0000              add [bx+si],al
00007DE0  0000              add [bx+si],al
00007DE2  0000              add [bx+si],al
00007DE4  0000              add [bx+si],al
00007DE6  0000              add [bx+si],al
00007DE8  0000              add [bx+si],al
00007DEA  0000              add [bx+si],al
00007DEC  0000              add [bx+si],al
00007DEE  0000              add [bx+si],al
00007DF0  0000              add [bx+si],al
00007DF2  0000              add [bx+si],al
00007DF4  0000              add [bx+si],al
00007DF6  0000              add [bx+si],al
00007DF8  0000              add [bx+si],al
00007DFA  0000              add [bx+si],al
00007DFC  0000              add [bx+si],al
00007DFE  55                push bp
00007DFF  AA                stosb
