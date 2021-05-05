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

delay:	mov r3, #0FFH
dwa:		mov r4, #0FFH
trzy:		djnz r4, trzy
			djnz r3, dwa
			ret

keyascii:	mov dptr, #80EBH
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

INPUT:
FirstDigit:
			LCDcntrlWR #CLEAR    ; wywolanie macra LCDcntrlWR – czyszczenie LCD i przesuniecie kursora na poczatek
			LCDcntrlWR #HOME
			mov r1, #0        ;zerujemy bufor na testowana wartosc
			
			Line1for1Digit:
			mov r0, #LINE_1
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz Line2for1Digit           ;jezeli nic nie zostalo wcisniete
			mov a, r2
			clr c
			subb a, #7Eh        ;jezeli zostal nacisniety klawisz A, skocz
			jz Line2for1Digit
			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a,@dptr        ;teraz w akumulatorze jest kod ascii danej cyfry
			acall putcharLCD
			clr c
			subb a, #30h        ;konwertujemy kod ascii na cyfre
			mov r1, a           ;dodajemy cyfre do bufora
			czekaj11:           ; nie wypuszczaj, dopoki klawisz nie zostanie "odcisniety"
			mov a, P7
			anl a, r0
			clr c
			subb a, r0
			jnz czekaj11
			acall delay
			jmp SecondDigit
			
			Line2for1Digit:
			mov r0, #LINE_2
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz Line3for1Digit           ;jezeli nic nie zostalo wcisniete
			mov a, r2
			clr c
			subb a, #0BEh        ;jezeli zostal nacisniety klawisz B, skocz
			jz Line3for1Digit
			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a,@dptr        ;teraz w akumulatorze jest kod ascii danej cyfry
			acall putcharLCD
			clr c
			subb a, #30h        ;konwertujemy kod ascii na cyfre
			mov r1, a           ;dodajemy cyfre do bufora
			czekaj21:           ; nie wypuszczaj, dopoki klawisz nie zostanie "odcisniety"
			mov a, P7
			anl a, r0
			clr c
			subb a, r0
			jnz czekaj21
			acall delay
			jmp SecondDigit
			
			Line3for1Digit:
			mov r0, #LINE_3
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz Line4for1Digit           ;jezeli nic nie zostalo wcisniete
			mov a, r2
			clr c
			subb a, #0DEh        ;jezeli zostal nacisniety klawisz C, skocz
			jz Line4for1Digit
			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a,@dptr        ;teraz w akumulatorze jest kod ascii danej cyfry
			acall putcharLCD
			clr c
			subb a, #30h        ;konwertujemy kod ascii na cyfre
			mov r1, a           ;dodajemy cyfre do bufora
			czekaj31:           ; nie wypuszczaj, dopoki klawisz nie zostanie "odcisniety"
			mov a, P7
			anl a, r0
			clr c
			subb a, r0
			jnz czekaj31
			acall delay
			jmp SecondDigit
			
			Line4for1Digit:        ;TU BEDZIE TROCHE INACZEJ!!!!!!
			mov r0, #LINE_4
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz goback1Digit          ;jezeli nic nie zostalo wcisniete
			mov a, r2
			clr c
			subb a, #0EBh        ;jezeli nie zostal nacisniety klawisz 0, skocz
			jnz goback1Digit
			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a,@dptr        ;teraz w akumulatorze jest kod ascii danej cyfry
			acall putcharLCD
			clr c
			subb a, #30h        ;konwertujemy kod ascii na cyfre
			mov r1, a           ;dodajemy cyfre do bufora
			czekaj41:           ; nie wypuszczaj, dopoki klawisz nie zostanie "odcisniety"
			mov a, P7
			anl a, r0
			clr c
			subb a, r0
			jnz czekaj41
			acall delay
			jmp SecondDigit

goback1Digit:
ljmp Line1for1Digit
	
SecondDigit:
			mov b, #10			;mnozymy wartosc pierwszej cyfry przez 10
			mov a, r1
			mul ab              ;teraz w akumulatorze powinna byc dziesieciokrotnosc cyfry dziesiatek
			mov r1, a
			Line1for2Digit:
			mov r0, #LINE_1
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz Line2for2Digit           ;jezeli nic nie zostalo wcisniete
			mov a, r2
			clr c
			subb a, #7Eh        ;jezeli zostal nacisniety klawisz A, skocz
			jz Line2for2Digit
			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a,@dptr        ;teraz w akumulatorze jest kod ascii danej cyfry
			acall putcharLCD
			clr c
			subb a, #30h        ;konwertujemy kod ascii na cyfre
			add a, r1
			mov r1, a           ;dodajemy bufor do cyfry jednosci, a nastepnie kopiujemy z powrotem do bufora
			czekaj12:           ; nie wypuszczaj, dopoki klawisz nie zostanie "odcisniety"
			mov a, P7
			anl a, r0
			clr c
			subb a, r0
			jnz czekaj12
			acall delay
			jmp Hashtag
			
			Line2for2Digit:
			mov r0, #LINE_2
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz Line3for2Digit           ;jezeli nic nie zostalo wcisniete
			mov a, r2
			clr c
			subb a, #0BEh        ;jezeli zostal nacisniety klawisz B, skocz
			jz Line3for2Digit
			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a,@dptr        ;teraz w akumulatorze jest kod ascii danej cyfry
			acall putcharLCD
			clr c
			subb a, #30h        ;konwertujemy kod ascii na cyfre
			add a, r1
			mov r1, a           ;dodajemy bufor do cyfry jednosci, a nastepnie kopiujemy z powrotem do bufora
			czekaj22:           ; nie wypuszczaj, dopoki klawisz nie zostanie "odcisniety"
			mov a, P7
			anl a, r0
			clr c
			subb a, r0
			jnz czekaj22
			acall delay
			jmp Hashtag
			
			Line3for2Digit:
			mov r0, #LINE_3
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz Line4for2Digit           ;jezeli nic nie zostalo wcisniete
			mov a, r2
			clr c
			subb a, #0DEh        ;jezeli zostal nacisniety klawisz C, skocz
			jz Line4for2Digit
			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a,@dptr        ;teraz w akumulatorze jest kod ascii danej cyfry
			acall putcharLCD
			clr c
			subb a, #30h        ;konwertujemy kod ascii na cyfre
			add a, r1
			mov r1, a           ;dodajemy bufor do cyfry jednosci, a nastepnie kopiujemy z powrotem do bufora
			czekaj32:           ; nie wypuszczaj, dopoki klawisz nie zostanie "odcisniety"
			mov a, P7
			anl a, r0
			clr c
			subb a, r0
			jnz czekaj32
			acall delay
			jmp Hashtag
			
			Line4for2Digit:        
			mov r0, #LINE_4
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz goback2Digit           ;jezeli nic nie zostalo wcisniete
			mov a, r2
			clr c
			subb a, #0EBh        ;jezeli nie zostal nacisniety klawisz 0, skocz
			jnz goback2Digit
			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a,@dptr        ;teraz w akumulatorze jest kod ascii danej cyfry
			acall putcharLCD
			clr c
			subb a, #30h        ;konwertujemy kod ascii na cyfre
			add a, r1
			mov r1, a           ;dodajemy bufor do cyfry jednosci, a nastepnie kopiujemy z powrotem do bufora
			czekaj42:           ; nie wypuszczaj, dopoki klawisz nie zostanie "odcisniety"
			mov a, P7
			anl a, r0
			clr c
			subb a, r0
			jnz czekaj42
			acall delay
			jmp Hashtag
			
goback2Digit:
ljmp Line1for2Digit
			
			
Hashtag:
;dwie petle, czekajace na wpisanie znaku hash
			mov r0, #LINE_4
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz Hashtag   ;jezeli nic sie nie wpisalo
			mov a, r2
			clr c
			subb a, #0EDh       ;wpisane znaku #
			jnz Hashtag
			;jesli wcisnelo sie #, czekaj na jego "odcisniecie"
			czekajHash:           ; nie wypuszczaj, dopoki klawisz nie zostanie "odcisniety"
			mov a, P7
			anl a, r0
			clr c
			subb a, r0
			jnz czekajHash
			acall delay
			;walidacja godziny
			mov a, r1
			clr c
			subb a, #24
			jnc hourValidationIncorrect
			mov a, r1
			mov r5, a
			mov a, #':'
			acall putcharLCD
			
			jmp ThirdDigit
			
hourValidationIncorrect:
ljmp FirstDigit

ThirdDigit:
			LCDcntrlWR #CLEAR    ; wywolanie macra LCDcntrlWR – czyszczenie LCD i przesuniecie kursora na poczatek
			LCDcntrlWR #HOME
			mov a, r5            ;przywroc godzine na wyswietlacz
			acall putdigitLCD
			mov a, #':'
			acall putcharLCD
			mov r1, #0        ;zerujemy bufor na testowana wartosc
			
			Line1for3Digit:
			mov r0, #LINE_1
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz Line2for3Digit           ;jezeli nic nie zostalo wcisniete
			mov a, r2
			clr c
			subb a, #7Eh        ;jezeli zostal nacisniety klawisz A, skocz
			jz Line2for3Digit
			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a,@dptr        ;teraz w akumulatorze jest kod ascii danej cyfry
			acall putcharLCD
			clr c
			subb a, #30h        ;konwertujemy kod ascii na cyfre
			mov r1, a           ;dodajemy cyfre do bufora
			czekaj13:           ; nie wypuszczaj, dopoki klawisz nie zostanie "odcisniety"
			mov a, P7
			anl a, r0
			clr c
			subb a, r0
			jnz czekaj13
			acall delay
			jmp FourthDigit
			
			Line2for3Digit:
			mov r0, #LINE_2
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz Line3for3Digit           ;jezeli nic nie zostalo wcisniete
			mov a, r2
			clr c
			subb a, #0BEh        ;jezeli zostal nacisniety klawisz B, skocz
			jz Line3for3Digit
			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a,@dptr        ;teraz w akumulatorze jest kod ascii danej cyfry
			acall putcharLCD
			clr c
			subb a, #30h        ;konwertujemy kod ascii na cyfre
			mov r1, a           ;dodajemy cyfre do bufora
			czekaj23:           ; nie wypuszczaj, dopoki klawisz nie zostanie "odcisniety"
			mov a, P7
			anl a, r0
			clr c
			subb a, r0
			jnz czekaj23
			acall delay
			jmp FourthDigit
			
			Line3for3Digit:
			mov r0, #LINE_3
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz Line4for3Digit           ;jezeli nic nie zostalo wcisniete
			mov a, r2
			clr c
			subb a, #0DEh        ;jezeli zostal nacisniety klawisz C, skocz
			jz Line4for3Digit
			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a,@dptr        ;teraz w akumulatorze jest kod ascii danej cyfry
			acall putcharLCD
			clr c
			subb a, #30h        ;konwertujemy kod ascii na cyfre
			mov r1, a           ;dodajemy cyfre do bufora
			czekaj33:           ; nie wypuszczaj, dopoki klawisz nie zostanie "odcisniety"
			mov a, P7
			anl a, r0
			clr c
			subb a, r0
			jnz czekaj33
			acall delay
			jmp FourthDigit
			
			Line4for3Digit:        ;TU BEDZIE TROCHE INACZEJ!!!!!!
			mov r0, #LINE_4
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz goback3Digit          ;jezeli nic nie zostalo wcisniete
			mov a, r2
			clr c
			subb a, #0EBh        ;jezeli nie zostal nacisniety klawisz 0, skocz
			jnz goback3Digit
			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a,@dptr        ;teraz w akumulatorze jest kod ascii danej cyfry
			acall putcharLCD
			clr c
			subb a, #30h        ;konwertujemy kod ascii na cyfre
			mov r1, a           ;dodajemy cyfre do bufora
			czekaj43:           ; nie wypuszczaj, dopoki klawisz nie zostanie "odcisniety"
			mov a, P7
			anl a, r0
			clr c
			subb a, r0
			jnz czekaj43
			acall delay
			jmp FourthDigit
	
goback3Digit:	
ljmp Line1for3Digit

FourthDigit:
			mov b, #10			;mnozymy wartosc pierwszej cyfry przez 10
			mov a, r1
			mul ab              ;teraz w akumulatorze powinna byc dziesieciokrotnosc cyfry dziesiatek
			mov r1, a
			Line1for4Digit:
			mov r0, #LINE_1
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz Line2for4Digit           ;jezeli nic nie zostalo wcisniete
			mov a, r2
			clr c
			subb a, #7Eh        ;jezeli zostal nacisniety klawisz A, skocz
			jz Line2for4Digit
			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a,@dptr        ;teraz w akumulatorze jest kod ascii danej cyfry
			acall putcharLCD
			clr c
			subb a, #30h        ;konwertujemy kod ascii na cyfre
			add a, r1
			mov r1, a           ;dodajemy bufor do cyfry jednosci, a nastepnie kopiujemy z powrotem do bufora
			czekaj14:           ; nie wypuszczaj, dopoki klawisz nie zostanie "odcisniety"
			mov a, P7
			anl a, r0
			clr c
			subb a, r0
			jnz czekaj14
			acall delay
			jmp Star
			
			Line2for4Digit:
			mov r0, #LINE_2
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz Line3for4Digit           ;jezeli nic nie zostalo wcisniete
			mov a, r2
			clr c
			subb a, #0BEh        ;jezeli zostal nacisniety klawisz B, skocz
			jz Line3for4Digit
			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a,@dptr        ;teraz w akumulatorze jest kod ascii danej cyfry
			acall putcharLCD
			clr c
			subb a, #30h        ;konwertujemy kod ascii na cyfre
			add a, r1
			mov r1, a           ;dodajemy bufor do cyfry jednosci, a nastepnie kopiujemy z powrotem do bufora
			czekaj24:           ; nie wypuszczaj, dopoki klawisz nie zostanie "odcisniety"
			mov a, P7
			anl a, r0
			clr c
			subb a, r0
			jnz czekaj24
			acall delay
			jmp Star
			
			Line3for4Digit:
			mov r0, #LINE_3
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz Line4for4Digit           ;jezeli nic nie zostalo wcisniete
			mov a, r2
			clr c
			subb a, #0DEh        ;jezeli zostal nacisniety klawisz C, skocz
			jz Line4for4Digit
			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a,@dptr        ;teraz w akumulatorze jest kod ascii danej cyfry
			acall putcharLCD
			clr c
			subb a, #30h        ;konwertujemy kod ascii na cyfre
			add a, r1
			mov r1, a           ;dodajemy bufor do cyfry jednosci, a nastepnie kopiujemy z powrotem do bufora
			czekaj34:           ; nie wypuszczaj, dopoki klawisz nie zostanie "odcisniety"
			mov a, P7
			anl a, r0
			clr c
			subb a, r0
			jnz czekaj34
			acall delay
			jmp Star
			
			Line4for4Digit:        ;TU BEDZIE TROCHE INACZEJ!!!!!!
			mov r0, #LINE_4
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz goback4Digit          ;jezeli nic nie zostalo wcisniete
			mov a, r2
			clr c
			subb a, #0EBh        ;jezeli nie zostal nacisniety klawisz 0, skocz
			jnz goback4Digit
			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a,@dptr        ;teraz w akumulatorze jest kod ascii danej cyfry
			acall putcharLCD
			clr c
			subb a, #30h        ;konwertujemy kod ascii na cyfre
			add a, r1
			mov r1, a           ;dodajemy bufor do cyfry jednosci, a nastepnie kopiujemy z powrotem do bufora
			czekaj44:           ; nie wypuszczaj, dopoki klawisz nie zostanie "odcisniety"
			mov a, P7
			anl a, r0
			clr c
			subb a, r0
			jnz czekaj44
			acall delay
			jmp Star
	
goback4Digit:	
ljmp Line1for4Digit

Star:			
;dwie petle, czekajace na wpisanie znaku star
			mov r0, #LINE_4
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz Star   ;jezeli nic sie nie wpisalo
			mov a, r2
			clr c
			subb a, #0E7h       ;wpisane znaku *
			jnz Star
			;jesli wcisnelo sie *, czekaj na jego "odcisniecie"
			czekajStar:           ; nie wypuszczaj, dopoki klawisz nie zostanie "odcisniety"
			mov a, P7
			anl a, r0
			clr c
			subb a, r0
			jnz czekajStar
			acall delay
			;walidacja minuty
			mov a, r1
			clr c
			subb a, #60
			jnc minuteValidationIncorrect
			mov a, r1
			mov r6, a        ;przechowanie wartosci minuty
			LCDcntrlWR #CLEAR    ; wywolanie macra LCDcntrlWR – czyszczenie LCD i przesuniecie kursora na poczatek
			LCDcntrlWR #HOME
			jmp FINALLY
			
minuteValidationIncorrect:
ljmp ThirdDigit	
FINALLY:    RET
			
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
		acall keyascii
		acall INPUT             ; inicjacja zegara
		MOV TMOD, #01H 			; konfiguracja timera
		MOV TH0, #3CH 			; ladowanie
		MOV TL0, #0B0H 			; stalej timera na 50ms
		SETB TR0      			; timer start
		MOV IE, #82H  			; przerwania wlacz
		MOV R7, #0FFH
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
