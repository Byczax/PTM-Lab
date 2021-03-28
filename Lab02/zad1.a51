ljmp start

LCDstatus  equ 0FF2EH	   ; adres do odczytu gotowosci LCD
LCDcontrol equ 0FF2CH	   ; adres do podania bajtu sterujacego LCD
LCDdataWR  equ 0FF3DH	   ; adres do podania kodu ASCII na LCD

// bajty sterujace LCD, inne dostepne w opisie LCD na stronie WWW
#define  HOME	 0x80	 // put cursor to second line  
#define  INITDISP 0x38	 // LCD init (8-bit mode)  
#define  HOM2	 0xc0	 // put cursor to second line  
#define  LCDON	0x0e	 // LCD nn, cursor off, blinking off
#define  CLEAR	0x01	 // LCD display clear

org 0100h
	
	// deklaracja tekstów
	text_przycisk: db "przycisk", 00
	text_button:  db "Wcisnieto", 00
	text_button1: db "Przycisk 1", 00
	text_button2: db "Przycisk 2", 00
	text_button3: db "Przycisk 3", 00
	text_button4: db "Przycisk 4", 00
	text_exit: db "1+4 aby wyjsc", 00
	text_end: db "Do widzenia ;)", 00
	text_test: db "wypisz 16 znaków", 00

	// macro do wprowadzenia bajtu sterujacego na LCD
LCDcntrlWR MACRO x		  ; x – parametr wywolania macra – bajt sterujacy
		   LOCAL loop	   ; LOCAL oznacza ze etykieta loop moze sie powtórzyc w programie
loop: MOV  DPTR,#LCDstatus  ; DPTR zaladowany adresem statusu
	  MOVX A,@DPTR		  ; pobranie bajtu z biezacym statusem LCD
	  JB   ACC.7,loop	   ; testowanie najstarszego bitu akumulatora
							; – wskazuje gotowosc LCD
	  MOV  DPTR,#LCDcontrol ; DPTR zaladowany adresem do podania bajtu sterujacego
	  MOV  A, x			 ; do akumulatora trafia argument wywolania macra, bajt sterujacy
	  MOVX @DPTR,A		  ; bajt sterujacy podany do LCD – zadana akcja widoczna na LCD
	  ENDM
	
	// macro do wypisania znaku ASCII na LCD, znak ASCII przed wywolaniem macra ma byc w A
LCDcharWR MACRO
	  LOCAL tutu			; LOCAL oznacza ze etykieta tutu moze sie powtórzyc w programie
	  PUSH ACC			  ; odlozenie biezacej zawartosci akumulatora na stos
tutu: MOV  DPTR,#LCDstatus  ; DPTR zaladowany adresem statusu
	  MOVX A,@DPTR		  ; pobranie bajtu z biezacym statusem LCD
	  JB   ACC.7,tutu	   ; testowanie najstarszego bitu akumulatora
							; – wskazuje gotowosc LCD
	  mov  83h, 06h			; DPH - 83h, r6 - 06h czyli MOV DPH, R6
	  mov  82h, 07h			; DPL - 82h, r7 - 07h czyli MOV DPL, R7
	  ;MOV  DPTR,#LCDdataWR  ; DPTR zaladowany adresem do podania bajtu sterujacego
	  POP  ACC			  ; w akumulatorze ponownie kod ASCII znaku na LCD
	  MOVX @DPTR,A		  ; kod ASCII podany do LCD – znak widoczny na LCD
	  ENDM
	
	// macro do inicjalizacji wyswietlacza – bez parametrów
init_LCD MACRO
		 LCDcntrlWR #INITDISP ; wywolanie macra LCDcntrlWR – inicjalizacja LCD
		 LCDcntrlWR #CLEAR	; wywolanie macra LCDcntrlWR – czyszczenie LCD
		 LCDcntrlWR #LCDON	; wywolanie macra LCDcntrlWR – konfiguracja kursora
		 ENDM
		 
write_str	 MACRO x
		mov dptr, x
		acall putstrLCD
		ENDM
		 
		 

// funkcja wypisania znaku
putcharLCD:	LCDcharWR
			ret
		
	//funkcja wypisania lancucha znaków		
putstrLCD:  mov r7, #30h	; DPL ustawiony tak by byl w DPRT adres FF30H
nextchar:	clr a
			movc a, @a+dptr
			jz koniec
			push dph
			push dpl
			acall putcharLCD
			pop dpl
			pop dph
			inc r7			; dzieki temu mozliwa inkrementacja DPTR
			inc dptr
			sjmp nextchar
	koniec: ret
					
	// funkcja opóznienia
	delay:	mov r0, #15H
	one:	mov r1, #0FFH
	dwa:	mov r2, #0FFH
	trzy:	djnz r2, trzy
			djnz r1, dwa
			djnz r0, one
			ret
	
			
		 
start: init_LCD

			mov r6, #0FFH	; adres LCDdataWR  equ 0FF3DH jest w parze R6-R7
			mov r7, #30H	
			
			LCDcntrlWR #CLEAR
			write_str #text_test
			LCDcntrlWR #HOM2
			write_str #text_exit
			
			
			select:
			
			clr c
			orl c, p3.3
			orl c, p3.4
			jnc exit
			
			mov a, p3
			jnb acc.2, push_button1
			jnb acc.3, push_button2
			jnb acc.4, push_button3
			jnb acc.5, push_button4
			jmp select
			
			push_button1:
				LCDcntrlWR #CLEAR
				write_str #text_button
				LCDcntrlWR #HOM2
				write_str #text_button1
				jmp select
			push_button2:
				LCDcntrlWR #CLEAR
				write_str #text_button
				LCDcntrlWR #HOM2
				write_str #text_button2
				jmp select
			push_button3:
				LCDcntrlWR #CLEAR
				write_str #text_button
				LCDcntrlWR #HOM2
				write_str #text_button3
				jmp select
			push_button4:
				LCDcntrlWR #CLEAR
				write_str #text_button
				LCDcntrlWR #HOM2
				write_str #text_button4
				jmp select
			exit:
			LCDcntrlWR #CLEAR
			write_str #text_end
	
	nop
	nop
	nop
	jmp $
	end start