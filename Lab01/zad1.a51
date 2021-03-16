ljmp start;

org 0100h;
	start:  
	; fffe - feff = 00ff
	; wczytanie pierwszej liczby w dwoch segmentach r1 | r0
	mov r0, #0feh; wczytanie pirwszych 8 bitow (0-7)
	mov r1, #0ffh; wczytanie pozostalych bitow (8-15)
	
	; wczytanie drugiej liczby w dwoch segmentach r3 | r2
	mov r2, #0ffh; wczytanie pierwszych 8 bitow (0-7)
	mov r3, #0feh; wczytanie kolejnych 8 bitow (8-15)
	
	clr c; wyczyszczenie dodatkowego odjemnika
	mov a, r0;
	subb a, r2;
	mov r4, a;
	
	mov a, r1;
	subb a, r3;
	mov r5, a;
	
nop;
nop;
nop;
jmp $;
end start;