ljmp start

org 0100h
start:	
		mov a, #0ffh
		mov r1, #02h
		clr c
		subb a, r1
nop
nop
nop
jmp $
end start