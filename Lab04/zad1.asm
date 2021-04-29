ljmp start

P5 equ 0F8H
P7 equ 0DBH
	
LCDstatus  equ 0FF2EH       ; adres do odczytu gotowosci LCD
LCDcontrol equ 0FF2CH       ; adres do podania bajtu sterujacego LCD
LCDdataWR  equ 0FF2DH       ; adres do podania kodu ASCII na LCD

// bajty sterujace LCD, inne dostepne w opisie LCD na stronie WWW
#define  HOME     0x80     // put cursor to second line  
#define  INITDISP 0x38     // LCD init (8-bit mode)  
#define  HOM2     0xc0     // put cursor to second line  
#define  LCDON    0x0e     // LCD nn, cursor off, blinking off
#define  CLEAR    0x01     // LCD display clear

// linie klawiatury - sterowanie na port P5
#define LINE_1		0x7f	// 0111 1111
#define LINE_2		0xbf	// 1011 1111
#define	LINE_3		0xdf	// 1101 1111
#define LINE_4		0xef	// 1110 1111
#define ALL_LINES	0x0f	// 0000 1111

ORG 000BH     				; obsluga przerwania
	MOV TH0, #3CH 			; przeladowanie
	MOV TL0, #0B0H 			; stalej timera na 50ms
	DEC R0        			; korekta licznika
	RETI          			; powrót z przerwania

org 0100H
		
// macro do wprowadzenia bajtu sterujacego na LCD
LCDcntrlWR MACRO x          ; x – parametr wywolania macra – bajt sterujacy
           LOCAL loop       ; LOCAL oznacza ze etykieta loop moze sie powtórzyc w programie
loop: MOV  DPTR,#LCDstatus  ; DPTR zaladowany adresem statusu
      MOVX A,@DPTR          ; pobranie bajtu z biezacym statusem LCD
      JB   ACC.7,loop       ; testowanie najstarszego bitu akumulatora
                            ; – wskazuje gotowosc LCD
      MOV  DPTR,#LCDcontrol ; DPTR zaladowany adresem do podania bajtu sterujacego
      MOV  A, x             ; do akumulatora trafia argument wywolania macra–bajt sterujacy
      MOVX @DPTR,A          ; bajt sterujacy podany do LCD – zadana akcja widoczna na LCD
      ENDM
	  
// macro do wypisania znaku ASCII na LCD, znak ASCII przed wywolaniem macra ma byc w A
LCDcharWR MACRO
      LOCAL tutu            ; LOCAL oznacza ze etykieta tutu moze sie powtórzyc w programie
      PUSH ACC              ; odlozenie biezacej zawartosci akumulatora na stos
tutu: MOV  DPTR,#LCDstatus  ; DPTR zaladowany adresem statusu
      MOVX A,@DPTR          ; pobranie bajtu z biezacym statusem LCD
      JB   ACC.7,tutu       ; testowanie najstarszego bitu akumulatora
                            ; – wskazuje gotowosc LCD
      MOV  DPTR,#LCDdataWR  ; DPTR zaladowany adresem do podania bajtu sterujacego
      POP  ACC              ; w akumulatorze ponownie kod ASCII znaku na LCD
      MOVX @DPTR,A          ; kod ASCII podany do LCD – znak widoczny na LCD
      ENDM
	  
// macro do inicjalizacji wyswietlacza – bez parametrów
init_LCD MACRO
         LCDcntrlWR #INITDISP ; wywolanie macra LCDcntrlWR – inicjalizacja LCD
         LCDcntrlWR #CLEAR    ; wywolanie macra LCDcntrlWR – czyszczenie LCD
         LCDcntrlWR #LCDON    ; wywolanie macra LCDcntrlWR – konfiguracja kursora
         ENDM
		 
// funkcja wypisania liczby dla potrzeb zegara
putdigitLCD:	mov b, #10
				div ab				; uzyskanie cyfry dziesiatek
				add a, #30H			; konwersja cyfry na kod ASCII
				acall putcharLCD
				mov a, b			; ladowanie cyfry jednosci
				add a, #30H			; konwersja na LCD
				acall putcharLCD
				ret

// funkcaj wypisywania znaku na LCD
putcharLCD:	LCDcharWR
			ret
		 

// wyznaczanie biezacej wartosci zegara i jego wyswietlanie na LCD
ZEGAR:		INC R7				; licznik sekund
			MOV A, R7			; obsluga sekund
			CLR C
			SUBB A, #60			; przepelnienie sekund
			JZ MINUTY
			LCDcntrlWR #HOME	; wyswietlenie calego zegara
			MOV A, R5			; godziny
			ACALL putdigitLCD
			MOV A, #":"			; separator
			ACALL putcharLCD
			MOV A, R6			; minuty
			ACALL putdigitLCD
			MOV A, #":"			; separator
			ACALL putcharLCD
			MOV A, R7			; sekundy
			ACALL putdigitLCD
			JMP FINAL
MINUTY:		MOV R7, #00H		; zerowanie sekund
			INC R6				; licznik minut
			MOV A, R6			; obsluga minut
			CLR C
			SUBB A, #60			; przepelnienie minut
			JZ GODZINY
			LCDcntrlWR #HOME	; wyswietlenie calego zegara
			MOV A, R5			; godziny
			ACALL putdigitLCD
			MOV A, #":"			; separator
			ACALL putcharLCD
			MOV A, R6			; minuty
			ACALL putdigitLCD
			MOV A, #":"			; separator
			ACALL putcharLCD
			MOV A, R7			; sekundy
			ACALL putdigitLCD
			JMP FINAL
GODZINY:	MOV R6, #00H		; zerowanie minut
			INC R5				; licznik godzin
			MOV A, R5
			CLR C
			SUBB A, #24			; przepelenienie godzin - doba
			JNZ EKRAN
			MOV R5, #00H		; zerowanie godzin
EKRAN:		LCDcntrlWR #HOME	; wyswietlenie calego zegara
			MOV A, R5			; godziny
			ACALL putdigitLCD
			MOV A, #":"			; separator
			ACALL putcharLCD
			MOV A, R6			; minuty
			ACALL putdigitLCD
			MOV A, #":"			; separator
			ACALL putcharLCD
			MOV A, R7			; sekundy
			ACALL putdigitLCD
FINAL:		RET

        ; program glówny
START:	init_LCD
		MOV TMOD, #01H 			; konfiguracja timera
		MOV TH0, #3CH 			; ladowanie
		MOV TL0, #0B0H 			; stalej timera na 50ms
		SETB TR0      			; timer start
		MOV IE, #82H  			; przerwania wlacz
		MOV R5, #00H			; inicjacja zegara
		MOV R6, #00H
		MOV R7, #0FFH
		MOV R0, #20 			; licznik odmierzen 20 x 50ms
		MOV R3, #20             ; backup licznika odmierzen
		ACALL ZEGAR				; wyswietlenie zainicjowanego zegara
		
KEY_A:
		mov r1, #LINE_1
		mov	a, r1
		mov	P5, a
		mov a, P7
		anl a, r1
		mov r2, a
		clr c
		subb a, r1  ;WYKRYCIE jakiegokolwiek klawisza
		jz KEY_B    ;jezli NIE zostal nacisniety zaden klawisz
		mov a, r2   ;przywrocenie backupu kodu skaningowego
		clr c
		subb a, #7Eh ;WYKRYCIE A
		jnz KEY_B   ;Jezeli NIE zostal nacisniety klawisz A
		;reakcja na A:
		mov a, r3
		mov r0, a  ;przywrocenie r0 z backupa
		mov IE, #82H;wlaczenie obslugi przerwan
		;mozliwe, ze trzeba dorobic petle, ktora nie wypusci, dopoki A zostanie "odcisniete"
		nieWypuszczajA:
		mov a, P7
		anl a, r1
		clr c
		subb a, r1
		jnz nieWypuszczajA
		
		
KEY_B:
		mov r1, #LINE_2
		mov	a, r1
		mov	P5, a
		mov a, P7
		anl a, r1
		mov r2, a
		clr c
		subb a, r1  ;WYKRYCIE jakiegokolwiek klawisza
		jz CZEKAM   ;jezli NIE zostal nacisniety zaden klawisz
		mov a, r2   ;przywrocenie backupu kodu skaningowego
		clr c
		subb a, #0BEh ;WYKRYCIE B
		jnz CZEKAM  ;Jezeli NIE zostal nacisniety klawisz B 
		;reakcja na B:
		mov IE, #00H ;wylaczenie obslugi przerwan
		mov a, r0
		mov r3, a ;odlozenie r0 do r3 (backup)
		
		;mozliwe, ze trzeba dorobic petle, ktora nie wypusci, dopoki B zostanie "odcisniete"
		nieWypuszczajB:
		mov a, P7
		anl a, r1
		clr c
		subb a, r1
		jnz nieWypuszczajB
		
		jmp KEY_A


		MOV A, #0FH
		MOV P1, A    			; zapalenie diód
		
		
CZEKAM: MOV A, R0   			; czekam, a timer
								;nie jestem pewien, ale tu chyba moze zajsc dekrementacja zera w r0 "nie w pore", tj. gdy jest sprawdzane wcisniecie klawisza
								;, co sprawi, ze program zapetli sie tam, gdzie nie powinien
								;aby to rozwiazac, przebuduje to:
		JZ WYPISZ
		clr c
		add a, #20h 			; daje zegarowi zapas, zwiazany z opisana powyzej sytuacja
		jc WYPISZ
		jmp KEY_A
		
		;JNZ KEY_A   			; mierzy laczny czas 1s (chociaz po dodaniu obslugi klawiatury, pewnie troche wiecej)
		;add a, #20h             ; daje zegarowi zapas, zwiazany z opisana powyzej sytuacja
		;jnc KEY_A

WYPISZ:

		MOV R0, #20				; po zgloszeniu przerwania - ustawiam na nowo licznik odmierzen 20 x 50ms
		ACALL ZEGAR				; uruchomienie procedury oblugi i wyswietlenia zegara
		
		MOV A, P1  				; zmiana
		CPL A       			; swiecenia
		MOV P1, A    			; diód
		
		JMP KEY_A    			; powrot do sprawdzania klawiszy
		
		NOP
		NOP
		NOP
		JMP $
END START
