ljmp start;

org 0100h;
	start:
	
	mov dptr, #8000h;przejscie na adres 8000 oraz wpisanie liczb do pierwszych 16 komorek
	mov a, #13;
	movx @dptr, a;
	inc dptr;
	mov a, #5;
	movx @dptr, a;
	inc dptr;
	mov a, #2;
	movx @dptr, a;
	inc dptr;
	mov a, #6;
	movx @dptr, a;
	inc dptr;
	mov a, #7;
	movx @dptr, a;
	inc dptr;
	mov a, #9;
	movx @dptr, a;
	inc dptr;
	mov a, #8;
	movx @dptr, a;
	inc dptr;
	mov a, #6;
	movx @dptr, a;
	inc dptr;
	mov a, #2;
	movx @dptr, a;
	inc dptr;
	mov a, #78;
	movx @dptr, a;
	inc dptr;
	mov a, #80;
	movx @dptr, a;
	inc dptr;
	mov a, #7;
	movx @dptr, a;
	inc dptr;
	mov a, #9;
	movx @dptr, a;
	inc dptr;
	mov a, #1;
	movx @dptr, a;
	

	nop;
	nop;
	nop;
	jmp $;
	end start;