ljmp start
	
LCDstatus  equ 0FF2EH	   ; adres do odczytu gotowosci LCD
LCDcontrol equ 0FF2CH	   ; adres do podania bajtu sterujacego LCD
LCDdataWR  equ 0FF2DH	   ; adres do podania kodu ASCII na LCD

RTCxs equ 0FF00H	; seconds
RTCsx equ 0FF01H
RTCxm equ 0FF02H	; minutes
RTCmx equ 0FF03H
RTCxh equ 0FF04H	; hours
RTChx equ 0FF05H
RTCxd equ 0FF06H	; day
RTCdx equ 0FF07H
RTCxn equ 0FF08H	; month
RTCnx equ 0FF09H
RTCxy equ 0FF0AH	; year
RTCyx equ 0FF0BH
RTCdw equ 0FF0CH	; day of week
RTCpf equ 0FF0FH

// bajty sterujace LCD, inne dostepne w opisie LCD na stronie WWW
#define  HOME	 0x80	 // put cursor to second line  
#define  INITDISP 0x38	 // LCD init (8-bit mode)  
#define  HOM2	 0xc0	 // put cursor to second line  
#define  LCDON	0x0e	 // LCD nn, cursor off, blinking off
#define  CLEAR	0x01	 // LCD display clear

org 0100H
	Czas: db "13:70:70"
	Dzien: db "07:02:2021*4"
	Month: db "JanFebMarAprMayJunJulAugSepOctNovDec"
	Week: db "SunMonTueWedThuFriSat"
	TwentyH: db 02
	TwentyL: db 00
		
// macro do wprowadzenia bajtu sterujacego na LCD
LCDcntrlWR MACRO x		  ; x – parametr wywolania macra – bajt sterujacy
		   LOCAL loop	   ; LOCAL oznacza ze etykieta loop moze sie powtórzyc w programie
loop: MOV  DPTR,#LCDstatus  ; DPTR zaladowany adresem statusu
	  MOVX A,@DPTR		  ; pobranie bajtu z biezacym statusem LCD
	  JB   ACC.7,loop	   ; testowanie najstarszego bitu akumulatora
							; – wskazuje gotowosc LCD
	  MOV  DPTR,#LCDcontrol ; DPTR zaladowany adresem do podania bajtu sterujacego
	  MOV  A, x			 ; do akumulatora trafia argument wywolania macrabajt sterujacy
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

// macro do wypisywania polowki wskazania pozycji czasu lub daty
disp_nibble MACRO
	movx A,@DPTR
	anl A,#0Fh	; select 4-bits
	orl A,#30H	; change to ASCII
	call putcharLCD
	ENDM

// funkcja wypisywania znaku na LCD
putcharLCD:	LCDcharWR
			ret
		 
// wypisywanie czasu
disp_time:
		LCDcntrlWR #HOME
		mov DPTR,#RTChx	; get hours from RTC (higher nibble)
		disp_nibble
		mov DPTR,#RTCxh	; get hours from RTC (lower nibble)
		disp_nibble
		mov A,#':'
		call putcharLCD
		mov DPTR,#RTCmx	; get minutes from RTC (higher nibble)
		disp_nibble
		mov DPTR,#RTCxm	; get minutes from RTC (lower nibble)
		disp_nibble
		mov A,#':'
		call putcharLCD;
		mov DPTR,#RTCsx	; get seconds from RTC (higher nibble)
		disp_nibble
		mov DPTR,#RTCxs	; get seconds from RTC (lower nibble)
		disp_nibble
		RET

// wypisywanie dnia tygodnia slownie
week_word:
		mov DPTR,#RTCdw	; get day of week from RTC
		movx a, @DPTR
		anl a, #0FH
		mov b, #03
		mul ab
		mov r7,a
		mov DPTR,#Week
		movc a,@a+dptr
		push dph
		push dpl
		acall putcharLCD
		pop dpl
		pop dph
		inc dptr
		mov a,r7
		movc a,@a+dptr
		push dph
		push dpl
		acall putcharLCD
		pop dpl
		pop dph
		inc dptr
		mov a,r7
		movc a,@a+dptr
		acall putcharLCD
		ret
		
// wypisywanie nazwy miesiaca slownie
month_word:
		mov DPTR,#RTCnx	; get month from RTC (higher nibble)
		movx a, @DPTR
		anl a, #0FH
		mov b, #10
		mul ab
		mov r7,a
		mov DPTR,#RTCxn	; get month from RTC (lower nibble)
		movx a, @DPTR
		anl a, #0FH
		add a,r7
		clr c
		subb a, #01
		mov b, #03
		mul ab
		mov r7,a
		mov DPTR,#Month
		movc a,@a+dptr
		push dph
		push dpl
		acall putcharLCD
		pop dpl
		pop dph
		inc dptr
		mov a,r7
		movc a,@a+dptr
		push dph
		push dpl
		acall putcharLCD
		pop dpl
		pop dph
		inc dptr
		mov a,r7
		movc a,@a+dptr
		acall putcharLCD
		ret

// wypisywanie daty
disp_date:
	LCDcntrlWR #HOM2
	mov DPTR,#RTCdx	; get day from RTC (higher nibble)
	disp_nibble
	mov DPTR,#RTCxd	; get day from RTC (lower nibble)
	disp_nibble
	mov A,#'-'
	call putcharLCD
	acall month_word
	mov A,#'-'
	call putcharLCD;
	mov DPTR,#TwentyH
	disp_nibble
	mov DPTR,#TwentyL
	disp_nibble
	mov DPTR,#RTCyx	; get year from RTC (higher nibble)
	disp_nibble
	mov DPTR,#RTCxy	; get year from RTC (lower nibble)
	disp_nibble
	mov A,#" "
	call putcharLCD;
	acall week_word
	RET

// inicjalizacja czasu
czas_start:
		mov DPTR, #RTCpf ; 24h zegar
		movx a, @DPTR
		orl a, #04H
		movx @DPTR, a
		clr c
		clr a
		mov dptr, #Czas
		movc a, @a+dptr	; dziesiatki godzin
		clr c
		subb a, #30h	; konwersja ascii->liczba
		
		mov r2, a	   ;zapisz cyfre dziesiatek w r2
		mov b, #10
		mul ab		  ;pomnoz cyfre dziesiatek przez 10...
		mov r1, a	   ;...i odloz wynik do r1
		
		inc dptr		;przesun dptr na kolejny adres w stringu "Czas"
		clr a
		movc a, @a+dptr	; jednosci godzin
		clr c
		subb a, #30h	 ; konwersja ascii->liczba
		
		mov r3, a	   ;zapisz cyfre jednosci w r3
		
		clr c
		addc a, r1	  ;w akumulatorze jest teraz "cala" liczba godzin
		
		clr c
		subb a, #24
		jnc godzinyPozaZakresem
		
				
		mov a, r2
		push dph		;zapisanie dptr  (wskazuje teraz na jednostki godzin!) na stosie
		push dpl
		mov dptr, #RTChx ;dptr=adres na rejestr
		movx @dptr, a	;zaladuj rejestr zawartoscia wyjeta ze stringu "Czas"
		
		mov a, r3
		mov dptr, #RTCxh
		movx @dptr, a
		pop dpl
		pop dph
		
		jmp koniecGodzinyPozaZakresem
		godzinyPozaZakresem:
		
		mov a, #00h	 ;ladujemy minimalna godzine
		push dph		;zapisanie dptr  (wskazuje teraz na jednostki godzin!) na stosie
		push dpl
		mov dptr, #RTChx ;dptr=adres na rejestr
		movx @dptr, a	;zaladuj rejestr zawartoscia wyjeta ze stringu "Czas"
		
		mov a, #00h	;ladujemy minimalna godzine
		mov dptr, #RTCxh
		movx @dptr, a
		pop dpl
		pop dph
		
		koniecGodzinyPozaZakresem:
		inc dptr
		clr a
		movc a, @a+dptr ; separator
		inc dptr   ;teraz dptr pokazuje na dziesiatki minut
		
		clr a
		movc a, @a+dptr	; dziesiatki minut
		clr c
		subb a, #30h
		
		mov r2, a	   ;zapisz cyfre dziesiatek w r2
		mov b, #10
		mul ab		  ;pomnoz cyfre dziesiatek przez 10...
		mov r1, a	   ;...i odloz wynik do r1
		
		inc dptr		;przesun dptr na kolejny adres w stringu "Czas"
		clr a
		movc a, @a+dptr	; jednosci minut
		clr c
		subb a, #30h	 ; konwersja ascii->liczba
		
		mov r3, a	   ;zapisz cyfre jednosci w r3
		
		clr c
		addc a, r1	  ;w akumulatorze jest teraz "cala" liczba minut
		
		clr c
		subb a, #60
		jnc minutyPozaZakresem
		
		mov a, r2
		push dph	;zapisanie dptr  (wskazuje teraz na jednostki minut!) na stosie
		push dpl
		mov dptr, #RTCmx
		movx @dptr, a
		
		mov a, r3
		mov dptr, #RTCxm
		movx @dptr, a
		pop dpl
		pop dph
		
		jmp koniecMinutyPozaZakresem
		minutyPozaZakresem:
		mov a, #00h
		push dph	;zapisanie dptr  (wskazuje teraz na jednostki minut!) na stosie
		push dpl
		mov dptr, #RTCmx
		movx @dptr, a
		
		mov a, #00h
		mov dptr, #RTCxm
		movx @dptr, a
		pop dpl
		pop dph

		koniecMinutyPozaZakresem:
		inc dptr
		clr a
		movc a, @a+dptr ; separator
		inc dptr		; dptr pokazuje teraz na dziesiatki sekund
		
		clr a
		movc a, @a+dptr	; dziesiatki sekund
		clr c
		subb a, #30h
		
		mov r2, a	   ;zapisz cyfre dziesiatek w r2
		mov b, #10
		mul ab		  ;pomnoz cyfre dziesiatek przez 10...
		mov r1, a	   ;...i odloz wynik do r1
		
		inc dptr		;przesun dptr na kolejny adres w stringu "Czas"
		clr a
		movc a, @a+dptr	; jednosci godzin
		clr c
		subb a, #30h	 ; konwersja ascii->liczba
		
		mov r3, a	   ;zapisz cyfre jednosci w r3
		
		clr c
		addc a, r1	  ;w akumulatorze jest teraz "cala" liczba sekund
		
		clr c
		subb a, #60
		jnc sekundyPozaZakresem
		
		mov a, r2
		push dph
		push dpl
		mov dptr, #RTCsx
		movx @dptr, a
		
		mov a, r3
		mov dptr, #RTCxs
		movx @dptr, a
		pop dpl
		pop dph
		
		jmp koniecSekundyPozaZakresem
		sekundyPozaZakresem:
		
		mov a, #00h	 ;ladujemy minimalna godzine
		push dph		;zapisanie dptr  (wskazuje teraz na jednostki godzin!) na stosie
		push dpl
		mov dptr, #RTChx ;dptr=adres na rejestr
		movx @dptr, a	;zaladuj rejestr zawartoscia wyjeta ze stringu "Czas"
		
		mov a, #00h	;ladujemy minimalna godzine
		mov dptr, #RTCxh
		movx @dptr, a
		pop dpl
		pop dph
		
		koniecSekundyPozaZakresem:
		ret

// inicjalizacja daty
data_start:	
		clr c
		clr a
		mov dptr, #Dzien
		movc a, @a+dptr	; dziesiatki dni
		clr c
		subb a, #30h
		
		mov r2, a	   ;zapisz cyfre dziesiatek w r2
		mov b, #10
		mul ab		  ;pomnoz cyfre dziesiatek przez 10...
		mov r1, a	   ;...i odloz wynik do r1
		
		inc dptr		;przesun dptr na kolejny adres w stringu "Dzien"
		clr a
		movc a, @a+dptr	; jednosci dni
		clr c
		subb a, #30h	 ; konwersja ascii->liczba
		
		mov r3, a	   ;zapisz cyfre jednosci w r3
		
		clr c
		addc a, r1	  ;w akumulatorze jest teraz "cala" liczba dni
		
		mov r0, a	   ;zapisujemy dodatkowo liczbe dni, na potrzeby dodatkowych testow z numerem miesiaca
		
		clr c
		subb a, #01		; zmiejszamy liczbe dni o 1, by uzyskac zakres <0;30> zamiast <1;31>		
		jc dniPozaZakresem
		
		clr c
		subb a, #31
		jnc dniPozaZakresem
		
		jmp koniecDniPozaZakresem
		dniPozaZakresem:
		
		mov a, #00h
		push dph
		push dpl
		mov dptr, #RTCdx
		movx @dptr, a
		
		mov a, #01h
		mov dptr, #RTCxd
		movx @dptr, a
		pop dpl
		pop dph

//------------------------------------------------------------------


		//ANALIZA MIESIECY, GDY dzien okazal sie poza zakresem
		inc dptr
		clr a
		movc a, @a+dptr ; separator
		inc dptr
		
		clr a
		movc a, @a+dptr	; dziesiatki miesiaca
		clr c
		subb a, #30h
		
		mov r2, a	   ;zapisz cyfre dziesiatek w r2
		mov b, #10
		mul ab		  ;pomnoz cyfre dziesiatek przez 10...
		mov r1, a	   ;...i odloz wynik do r1
		
		inc dptr		;przesun dptr na kolejny adres w stringu "Dzien"
		clr a
		movc a, @a+dptr	; jednosci miesiaca
		clr c
		subb a, #30h	 ; konwersja ascii->liczba
		
		mov r3, a	   ;zapisz cyfre jednosci w r3
		
		clr c
		addc a, r1	  ;w akumulatorze jest teraz "cala" liczba miesiecy
		
		clr c
		subb a, #01		; zmiejszamy liczbe dni o 1, by uzyskac zakres <0;11> zamiast <1;12>
		jc miesiacePozaZakresemPrzyDniuPozaZakresem
		
		clr c
		subb a, #12
		jnc miesiacePozaZakresemPrzyDniuPozaZakresem
		
		mov a, r2
		push dph
		push dpl
		mov dptr, #RTCnx
		movx @dptr, a
		
		mov a, r3
		mov dptr, #RTCxn
		movx @dptr, a
		pop dpl
		pop dph
		
		jmp koniecMiesiacePozaZakresem
		miesiacePozaZakresemPrzyDniuPozaZakresem:
		
		mov a, #00h
		push dph
		push dpl
		mov dptr, #RTCnx
		movx @dptr, a
		
		mov a, #01h
		mov dptr, #RTCxn
		movx @dptr, a
		pop dpl
		pop dph
		
		jmp koniecMiesiacePozaZakresem
		
//------------------------------------------------------------------

		
		koniecDniPozaZakresem:
		inc dptr
		clr a
		movc a, @a+dptr ; separator
		inc dptr
		
		clr a
		movc a, @a+dptr	; dziesiatki miesiaca
		clr c
		subb a, #30h
		
		mov r4, a	   ;zapisz cyfre dziesiatek w r4
		mov b, #10
		mul ab		  ;pomnoz cyfre dziesiatek przez 10...
		mov r1, a	   ;...i odloz wynik do r1
		
		inc dptr		;przesun dptr na kolejny adres w stringu "Dzien"
		clr a
		movc a, @a+dptr	; jednosci miesiaca
		clr c
		subb a, #30h	 ; konwersja ascii->liczba
		
		mov r5, a	   ;zapisz cyfre jednosci w r5
		
		clr c
		addc a, r1	  ;w akumulatorze jest teraz "cala" liczba miesiecy
		mov r1, a	   ;odloz cala liczbe miesiecy do akumulatora (dodatkowy backup)
		
		clr c
		subb a, #01		; zmiejszamy liczbe dni o 1, by uzyskac zakres <0;11> zamiast <1;12>
		jc misc
		
		clr c
		subb a, #12
		jnc misc
		jc omit
		
		misc:
		ljmp miesiacePozaZakresem
		
		omit:
		
		mov a, r1  ;przywrocenie wartosci miesiecy
		
		clr c
		subb a, #02
		jz przypadekLuty
		
		mov a, r1  ;przywrocenie wartosci miesiecy
		
		clr c
		subb a, #04
		jz przypadek30DniowyMiesiac
		
		mov a, r1  ;przywrocenie wartosci miesiecy
		
		clr c
		subb a, #06
		jz przypadek30DniowyMiesiac
		
		mov a, r1  ;przywrocenie wartosci miesiecy
		
		clr c
		subb a, #09
		jz przypadek30DniowyMiesiac
		
		mov a, r1  ;przywrocenie wartosci miesiecy
		
		clr c
		subb a, #11
		jz przypadek30DniowyMiesiac
		
		//przypadek 31dniowego miesiaca
		mov a, r4
		push dph
		push dpl
		mov dptr, #RTCnx
		movx @dptr, a
		
		mov a, r5
		mov dptr, #RTCxn
		movx @dptr, a
		
		mov a, r2
		mov dptr, #RTCdx
		movx @dptr, a
		
		mov a, r3
		mov dptr, #RTCxd
		movx @dptr, a
		pop dpl
		pop dph
		
		jmp koniecMiesiacePozaZakresem
				
		przypadek30DniowyMiesiac:
		mov a, r0	  ;przywracamy wartosc dni
		clr c
		subb a, #31
		jnc miesiacOKAleDzienNiedobry
		
		mov a, r4
		push dph
		push dpl
		mov dptr, #RTCnx
		movx @dptr, a
		
		mov a, r5
		mov dptr, #RTCxn
		movx @dptr, a
		
		mov a, r2
		mov dptr, #RTCdx
		movx @dptr, a
		
		mov a, r3
		mov dptr, #RTCxd
		movx @dptr, a
		pop dpl
		pop dph
		
		jmp koniecMiesiacePozaZakresem
		
		miesiacOKAleDzienNiedobry:
		
		mov a, r4
		push dph
		push dpl
		mov dptr, #RTCnx
		movx @dptr, a
		
		mov a, r5
		mov dptr, #RTCxn
		movx @dptr, a
		
		mov a, #00h
		mov dptr, #RTCdx
		movx @dptr, a
		
		mov a, #01h
		mov dptr, #RTCxd
		movx @dptr, a
		pop dpl
		pop dph
		
		jmp koniecMiesiacePozaZakresem
		
		przypadekLuty:
		mov a, r0	  ;przywracamy wartosc dni
		clr c
		subb a, #29
		jnc lutyOKAleDzienNiedobry
		
		mov a, #00h
		push dph
		push dpl
		mov dptr, #RTCnx
		movx @dptr, a
		
		mov a, #02h
		mov dptr, #RTCxn
		movx @dptr, a
		
		mov a, r2
		mov dptr, #RTCdx
		movx @dptr, a
		
		mov a, r3
		mov dptr, #RTCxd
		movx @dptr, a
		pop dpl
		pop dph
		
		jmp koniecMiesiacePozaZakresem
		
		lutyOKAleDzienNiedobry:
		
		mov a, #00h
		push dph
		push dpl
		mov dptr, #RTCnx
		movx @dptr, a
		
		mov a, #02h
		mov dptr, #RTCxn
		movx @dptr, a
		
		mov a, #00h
		mov dptr, #RTCdx
		movx @dptr, a
		
		mov a, #01h
		mov dptr, #RTCxd
		movx @dptr, a
		pop dpl
		pop dph
		
		jmp koniecMiesiacePozaZakresem
		
		miesiacePozaZakresem:
		
		mov a, #00h
		push dph
		push dpl
		mov dptr, #RTCnx
		movx @dptr, a
		
		mov a, #01h
		mov dptr, #RTCxn
		movx @dptr, a
		
		mov a, r2
		mov dptr, #RTCdx
		movx @dptr, a
		
		mov a, r3
		mov dptr, #RTCxd
		movx @dptr, a
		pop dpl
		pop dph
		
		koniecMiesiacePozaZakresem:
		inc dptr
		clr a
		movc a, @a+dptr ; separator
		inc dptr
		clr a
		movc a, @a+dptr ; cyfra tysiecy roku
		inc dptr
		clr a
		movc a, @a+dptr ; cyfra setek roku
		inc dptr
		clr a
		movc a, @a+dptr	; dziesiatki roku
		clr c
		subb a, #30h
		push dph
		push dpl
		mov dptr, #RTCyx
		movx @dptr, a
		pop dpl
		pop dph		
		inc dptr
		clr a
		movc a, @a+dptr	; jednosci roku
		clr c
		subb a, #30h
		push dph
		push dpl
		mov dptr, #RTCxy
		movx @dptr, a
		pop dpl
		pop dph
		inc dptr
		clr a
		movc a, @a+dptr ; separator
		inc dptr
		clr a
		movc a, @a+dptr	; dzien tygodnia
		clr c
		subb a, #30h
		push dph
		push dpl
		mov dptr, #RTCdw
		movx @dptr, a
		pop dpl
		pop dph	
		ret

		; program glówny
start:	init_LCD

		acall czas_start
		acall data_start
		
czas_plynie:	acall disp_time
				acall disp_date
				sjmp czas_plynie
		NOP
		NOP
		NOP
		JMP $
END START