ljmp start
	
LCDstatus  equ 0FF2EH       ; adres do odczytu gotowosci LCD
LCDcontrol equ 0FF2CH       ; adres do podania bajtu sterujacego LCD
LCDdataWR  equ 0FF2DH       ; adres do podania kodu ASCII na LCD

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
#define  HOME     0x80     // put cursor to second line  
#define  INITDISP 0x38     // LCD init (8-bit mode)  
#define  HOM2     0xc0     // put cursor to second line  
#define  LCDON    0x0e     // LCD nn, cursor off, blinking off
#define  CLEAR    0x01     // LCD display clear

org 0100H
	Czas: db "13:40:00"
	Dzien: db "20:05:2021*4"
	Month: db "JanFebMarAprMayJunJulAugSepOctNovDec"
	Week: db "SunMonTueWedThuFriSat"
	TwentyH: db 02
	TwentyL: db 00
		
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

hourValidationIncorrect:
	mov dptr, #RTChx
	movx @dptr, #0
	mov dptr, #RTCxh
	movx @dptr, #0
ret

minuteValidationIncorrect:
	mov dptr, #RTCmx
	movx @dptr, #0
	mov dptr, #RTCxm
	movx @dptr, #0
ret

secondsValidationIncorrect:
	mov dptr, #RTCsx
	movx @dptr, #0
	mov dptr, #RTCxs
	movx @dptr, #0
ret

saveValue1:
	mov r0, a ; zapamietanie wartości a
	clr a ;  wyczyszczenie rejestru r1 za pomoca a
	mov r1, a
	mov a, r0; przywrocenie wartosci a
	add a, r1 ; suma z rejestrem r1
	mov r1, a; zapisanie sumy
ret

saveValue2:
	mov r0, a ; zapamietanie wartości a
	add a, r1 ; suma z rejestrem r1
	mov r1, a; zapisanie sumy
	mov a, r0; przywrocenie wartosci a
ret


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
		subb a, #30h
		
		acall saveValue1

		push dph
		push dpl
		mov dptr, #RTChx
		movx @dptr, a
		pop dpl
		pop dph
		inc dptr
		clr a
		movc a, @a+dptr	; jednosci godzin
		subb a, #30h

		acall saveValue2

		push dph
		push dpl
		mov dptr, #RTCxh
		movx @dptr, a

		mov a, r1
		clr c
		subb a, #24
		jc hourValidationCorrect
		acall hourValidationIncorrect
	hourValidationCorrect:
		pop dpl
		pop dph
		inc dptr
		clr a
		movc a, @a+dptr ; separator
		inc dptr
		clr a
		movc a, @a+dptr	; dziesiatki minut
		subb a, #30h

		acall saveValue1

		push dph
		push dpl
		mov dptr, #RTCmx
		movx @dptr, a
		pop dpl
		pop dph
		inc dptr
		clr a
		movc a, @a+dptr	; jednosci minut
		subb a, #30h

		acall saveValue2
		
		push dph
		push dpl
		mov dptr, #RTCxm
		movx @dptr, a

		mov a, r1
		clr c
		subb a, #60
		jc minuteValidationCorrect
		acall minuteValidationIncorrect
minuteValidationCorrect:
		pop dpl
		pop dph		
		inc dptr
		clr a
		movc a, @a+dptr ; separator
		inc dptr
		clr a
		movc a, @a+dptr	; dziesiatki sekund
		subb a, #30h

		acall saveValue1

		push dph
		push dpl
		mov dptr, #RTCsx
		movx @dptr, a
		pop dpl
		pop dph
		inc dptr
		clr a
		movc a, @a+dptr	; jednosci sekund
		subb a, #30h

		acall saveValue2

		push dph
		push dpl
		mov dptr, #RTCxs
		movx @dptr, a

		mov a, r1
		clr c
		subb a, #60
		jc secondsValidationCorrect
		acall secondsValidationIncorrect
	secondsValidationCorrect:
		pop dpl
		pop dph
		ret
daysValidationIncorrect:
	mov dptr, #RTCdx
	movx @dptr, #0
	mov dptr, #RTCxd
	movx @dptr, #1
	// jezeli poprawiamy miesiac to zapiszmy jego nowo wersje czyli styczen
	mov r0, a
	mov a, #01
	mov r2, a
	mov a, r0
ret

monthsValidationIncorrect:
	mov dptr, #RTCnx
	movx @dptr, #0
	mov dptr, #RTCxn
	movx @dptr, #1
	mov r0, a
	mov a, r1
	mov r3, a
	mov a, r0
ret

dayMonthValidation:
	; pod r2 kryje sie zapis dni
	; pod r3 kryje sie zapis miesiaca
	
ret

saveDays:
	mov r0, a
	mov a, r1
	mov r2, a
	mov a, r0
ret

saveMonth:
	mov r0, a
	mov a, r1
	mov r3, a
	mov a, r0
ret

// inicjalizacja daty
data_start:	clr c
		clr a
		mov dptr, #Dzien
		movc a, @a+dptr	; dziesiatki dni
		subb a, #30h

		acall saveValue1

		push dph
		push dpl
		mov dptr, #RTCdx
		movx @dptr, a
		pop dpl
		pop dph
		inc dptr
		clr a
		movc a, @a+dptr	; jednosci dni
		subb a, #30h

		acall saveValue2

		acall saveDays

		push dph
		push dpl
		mov dptr, #RTCxd
		movx @dptr, a

		mov a, r1
		clr c
		subb a, #32
		jc daysValidationCorrect
		acall daysValidationIncorrect
	daysValidationCorrect:

		pop dpl
		pop dph
		inc dptr
		clr a
		movc a, @a+dptr ; separator
		inc dptr
		clr a
		movc a, @a+dptr	; dziesiatki miesiaca
		subb a, #30h

		acall saveValue1

		push dph
		push dpl
		mov dptr, #RTCnx
		movx @dptr, a
		pop dpl
		pop dph
		inc dptr
		clr a
		movc a, @a+dptr	; jednosci miesiaca
		subb a, #30h

		acall saveValue2

		acall saveMonth

		push dph
		push dpl
		mov dptr, #RTCxn
		movx @dptr, a

		mov a, r1
		clr c
		subb a, #13
		jc monthsValidationCorrect
		acall monthsValidationIncorrect
		jmp noCheck
	monthsValidationCorrect:
	acall dayMonthValidation
noCheck:
		pop dpl
		pop dph
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