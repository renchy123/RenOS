00009000  E91900            jmp 0x901c
00009003  0000              add [bx+si],al
00009005  0000              add [bx+si],al
00009007  0000              add [bx+si],al
00009009  0000              add [bx+si],al
0000900B  00060000          add [0x0],al
0000900F  0000              add [bx+si],al
00009011  98                cbw
00009012  40                inc ax
00009013  000F              add [bx],cl
00009015  0000              add [bx+si],al
00009017  0000              add [bx+si],al
00009019  0000              add [bx+si],al
0000901B  008CC88E          add [si-0x7138],cl
0000901F  D88EC08E          fmul dword [bp-0x7140]
00009023  D0BC007C          sar byte [si+0x7c00],1
00009027  66B800000000      mov eax,0x0
0000902D  8CC8              mov ax,cs
0000902F  66C1E004          shl eax,byte 0x4
00009033  66057C900000      add eax,0x907c
00009039  A30E90            mov [0x900e],ax
0000903C  66C1E810          shr eax,byte 0x10
00009040  A21090            mov [0x9010],al
00009043  88261390          mov [0x9013],ah
00009047  66B800000000      mov eax,0x0
0000904D  8CD8              mov ax,ds
0000904F  66C1E004          shl eax,byte 0x4
00009053  660504900000      add eax,0x9004
00009059  66A31690          mov [0x9016],eax
0000905D  0F01161490        lgdt [0x9014]
00009062  FA                cli
00009063  E492              in al,0x92
00009065  0C02              or al,0x2
00009067  E692              out 0x92,al
00009069  0F20C0            mov eax,cr0
0000906C  6683C801          or eax,byte +0x1
00009070  0F22C0            mov cr0,eax
00009073  66EA000000000800  jmp dword 0x8:0x0
0000907B  00B80000          add [bx+si+0x0],bh
0000907F  0000              add [bx+si],al
00009081  EBF9              jmp short 0x907c
