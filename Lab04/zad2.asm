ljmp start

P5 equ 0F8H
P7 equ 0DBH

SECONDS equ 00H
MINUTES equ 00H
HOURS equ 00H

LOOP_ONE equ 00H
LOOP_TWO equ 00H

LCDstatus  equ 0FF2EH	; adres do odczytu gotowosci LCD
LCDcontrol equ 0FF2CH	; adres do podania bajtu sterujacego LCD
LCDdataWR  equ 0FF2DH	; adres do podania kodu ASCII na LCD

// bajty sterujace LCD, inne dostepne w opisie LCD na stronie WWW
#define  HOME		0x80	// put cursor to second line  
#define  INITDISP	0x38	// LCD init (8-bit mode)  
#define  HOM2		0xc0	// put cursor to second line  
#define  LCDON		0x0e	// LCD nn, cursor off, blinking off
#define  CLEAR		0x01	// LCD display clear

// linie klawiatury - sterowanie na port P5
#define LINE_1		0x7f	// 0111 1111
#define LINE_2		0xbf	// 1011 1111
#define	LINE_3		0xdf	// 1101 1111
#define LINE_4		0xef	// 1110 1111
#define ALL_LINES	0x0f	// 0000 1111

// przerywanie timera
ORG 000BH     				; obsluga przerwania
	MOV TH0, #3CH 			; przeladowanie
	MOV TL0, #0B0H 			; stalej timera na 50ms
	DEC R0        			; korekta licznika
	RETI          			; powrót z przerwania

org 0100H
		
// macro do wprowadzenia bajtu sterujacego na LCD
LCDcntrlWR MACRO x		; x – parametr wywolania macra – bajt sterujacy
		   LOCAL loop	; LOCAL oznacza ze etykieta loop moze sie powtórzyc w programie
loop: MOV  DPTR,#LCDstatus; DPTR zaladowany adresem statusu
	  MOVX A,@DPTR		; pobranie bajtu z biezacym statusem LCD
	  JB   ACC.7,loop	; testowanie najstarszego bitu akumulatora
							; – wskazuje gotowosc LCD
	  MOV  DPTR,#LCDcontrol ; DPTR zaladowany adresem do podania bajtu sterujacego
	  MOV  A, x			; do akumulatora trafia argument wywolania macrabajt sterujacy
	  MOVX @DPTR,A		; bajt sterujacy podany do LCD – zadana akcja widoczna na LCD
	  ENDM

// macro do wypisania znaku ASCII na LCD, 
//znak ASCII przed wywolaniem macra ma byc w A
LCDcharWR MACRO
	  LOCAL tutu			; LOCAL oznacza ze etykieta tutu moze sie powtórzyc w programie
	  PUSH ACC			  ; odlozenie biezacej zawartosci akumulatora na stos
tutu: MOV  DPTR,#LCDstatus  ; DPTR zaladowany adresem statusu
	  MOVX A,@DPTR		  ; pobranie bajtu z biezacym statusem LCD
	  JB   ACC.7,tutu	   ; testowanie najstarszego bitu akumulatora
							; – wskazuje gotowosc LCD
	  MOV  DPTR,#LCDdataWR  ; DPTR zaladowany adresem do podania bajtu sterujacego
	  POP  ACC			  ; w akumulatorze ponownie kod ASCII znaku na LCD
	  MOVX @DPTR,A		  ; kod ASCII podany do LCD – znak widoczny na LCD
	  ENDM
// macro do inicjalizacji wyswietlacza – bez parametrów
init_LCD MACRO
		LCDcntrlWR #INITDISP ; wywolanie macra LCDcntrlWR – inicjalizacja LCD
		LCDcntrlWR #CLEAR	; wywolanie macra LCDcntrlWR – czyszczenie LCD
		LCDcntrlWR #LCDON	; wywolanie macra LCDcntrlWR – konfiguracja kursora
		ENDM

// funkcja opóznienia

	delay:	mov LOOP_ONE, #0FFH
	dwa:	mov LOOP_TWO, #0FFH
	trzy:	djnz LOOP_TWO, trzy
			djnz LOOP_ONE, dwa
			ret
			
// funkcja wypisania znaku
putcharLCD:	LCDcharWR
			ret

keyascii:
; Uklad klawiatury:
			/*
					1 2 3 A
					4 5 6 B
					7 8 9 C
					# 0 * D
			*/
        	mov dptr, #80EBH
			mov a, #"0"
			movx @dptr, a
			
			mov dptr, #8077H
			mov a, #"1"
			movx @dptr, a
			
			mov dptr, #807BH
			mov a, #"2"
			movx @dptr, a
			
			mov dptr, #807DH
			mov a, #"3"
			movx @dptr, a
			
			mov dptr, #80B7H
			mov a, #"4"
			movx @dptr, a
			
			mov dptr, #80BBH
			mov a, #"5"
			movx @dptr, a
			
			mov dptr, #80BDH
			mov a, #"6"
			movx @dptr, a
			
			mov dptr, #80D7H
			mov a, #"7"
			movx @dptr, a
			
			mov dptr, #80DBH
			mov a, #"8"
			movx @dptr, a
			
			mov dptr, #80DDH
			mov a, #"9"
			movx @dptr, a
			
			mov dptr, #807EH
			mov a, #"A"
			movx @dptr, a
			
			mov dptr, #80BEH
			mov a, #"B"
			movx @dptr, a
			
			mov dptr, #80DEH
			mov a, #"C"
			movx @dptr, a
			
			mov dptr, #80EEH
			mov a, #"D"
			movx @dptr, a
			
			mov dptr, #80E7H
			mov a, #"*"
			movx @dptr, a
			
			mov dptr, #80EDH
			mov a, #"#"
			movx @dptr, a
			
			ret

// funkcja wypisania liczby dla potrzeb zegara
putdigitLCD:	mov b, #10
				div ab				; uzyskanie cyfry dziesiatek
				add a, #30H			; konwersja cyfry na kod ASCII
				acall putcharLCD
				mov a, b			; ladowanie cyfry jednosci
				add a, #30H			; konwersja na LCD
				acall putcharLCD
				ret

// wyznaczanie biezacej wartosci zegara i jego wyswietlanie na LCD
ZEGAR:		INC SECONDS				; licznik sekund
			MOV A, SECONDS			; obsluga sekund
			CLR C
			SUBB A, #60			; przepelnienie sekund
			JZ MINUTY
			LCDcntrlWR #HOME	; wyswietlenie calego zegara
			MOV A, HOURS			; godziny
			ACALL putdigitLCD
			MOV A, #":"			; separator
			ACALL putcharLCD
			MOV A, MINUTES			; minuty
			ACALL putdigitLCD
			MOV A, #":"			; separator
			ACALL putcharLCD
			MOV A, SECONDS			; sekundy
			ACALL putdigitLCD
			JMP FINAL
MINUTY:		MOV SECONDS, #00H		; zerowanie sekund
			INC MINUTES				; licznik minut
			MOV A, MINUTES			; obsluga minut
			CLR C
			SUBB A, #60			; przepelnienie minut
			JZ GODZINY
			LCDcntrlWR #HOME	; wyswietlenie calego zegara
			MOV A, HOURS			; godziny
			ACALL putdigitLCD
			MOV A, #":"			; separator
			ACALL putcharLCD
			MOV A, MINUTES			; minuty
			ACALL putdigitLCD
			MOV A, #":"			; separator
			ACALL putcharLCD
			MOV A, SECONDS			; sekundy
			ACALL putdigitLCD
			JMP FINAL
GODZINY:	MOV MINUTES, #00H		; zerowanie minut
			INC HOURS				; licznik godzin
			MOV A, HOURS
			CLR C
			SUBB A, #24			; przepelenienie godzin - doba
			JNZ EKRAN
			MOV HOURS, #00H		; zerowanie godzin
EKRAN:		LCDcntrlWR #HOME	; wyswietlenie calego zegara
			MOV A, HOURS			; godziny
			ACALL putdigitLCD
			MOV A, #":"			; separator
			ACALL putcharLCD
			MOV A, MINUTES			; minuty
			ACALL putdigitLCD
			MOV A, #":"			; separator
			ACALL putcharLCD
			MOV A, SECONDS			; sekundy
			ACALL putdigitLCD
FINAL:		RET


Check_key MACRO x
    mov r1, x
    mov	a, r1
    mov	P5, a
    mov a, P7
    anl a, r1
    mov r2, a
    clr c
    subb a, r1
ENDM

Display_key:
	mov a, r2
    mov dph, #80h
    mov dpl, a
    movx a,@dptr
    mov P1, a
    acall putcharLCD
    acall hover
	ret

Accept_wait:
    mov a, r3
    clr c
    subb a, #02H
    jz key_1
    mov a, r3
    clr c
    subb a, #05H
    jz key_1
    clr c
    subb a, #06H
    jz ON
ret

//==================================================================
// Program glówny
START:	
        init_LCD
		MOV TMOD, #01H 			; konfiguracja timera
		MOV TH0, #3CH 			; ladowanie
		MOV TL0, #0B0H 			; stalej timera na 50ms
		SETB TR0      			; timer start
		MOV IE, #82H  			; przerwania wlacz

        mov r3, #00H; tester
        ; 01H - Wpisana wartość dziesiętna godziny
        ; 02H - wpisana wartość jedności godziny
        ; 03H - Godziny została zaakceptowane
        ; 04H - Wpisana wartość dziesiętna minuty
        ; 05H - Wpisana wartość jedności minuty
        ; 06# - Minuty zostały zaakcepotwane
key_1:
        Check_key #LINE_1
        jz key_2
        acall Accept_wait


        acall Display_key
key_2:
        Check_key #LINE_2
        jz key_3
        acall Accept_wait


        acall Display_key
key_3:
        Check_key #LINE_3
        jz key_4
        acall Accept_wait


        acall Display_key
key_4:
        Check_key #LINE_4
        jz key_1
        acall Accept_wait


        acall Display_key
        jmp key_1



ON:
		MOV HOURS, #00H			; inicjacja zegara
		MOV MINUTES, #00H
		MOV SECONDS, #0FFH
		ACALL ZEGAR				; wyswietlenie zainicjowanego zegara
		MOV A, #0FH
		MOV P1, A    			; zapalenie diód
		MOV R0, #20 			; licznik odmierzen 20 x 50ms


CZEKAM: MOV A, R0   			; czekam, a timer
		JNZ CZEKAM   			; mierzy laczny czas 1s
		MOV R0, #20				; po zgloszeniu przerwania - ustawiam na nowo licznik odmierzen 20 x 50ms
		ACALL ZEGAR				; uruchomienie procedury oblugi i wyswietlenia zegara
		MOV A, P1  				; zmiana
		CPL A       			; swiecenia
		MOV P1, A    			; diód
		JMP CZEKAM    			; czekam na kolejna sekunde
		
		
		NOP
		NOP
		NOP
		JMP $
END START
