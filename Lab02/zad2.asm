ljmp start

LCDstatus  equ 0FF2EH       ; adres do odczytu gotowosci LCD
LCDcontrol equ 0FF2CH       ; adres do podania bajtu sterujacego LCD
LCDdataWR  equ 0FF2DH       ; adres do podania kodu ASCII na LCD

// bajty sterujace LCD, inne dostepne w opisie LCD na stronie WWW
#define  HOME     0x80     // put cursor to first line  
#define  INITDISP 0x38     // LCD init (8-bit mode)  
#define  HOM2     0xc0     // put cursor to second line  
#define  LCDON    0x0e     // LCD nn, cursor off, blinking off
#define  CLEAR    0x01     // LCD display clear

org 0100H
	
// deklaracje tekstów
	text:  db "Orka oceaniczna - gatunek ssaka z rodziny delfinowatych (Delphinidae). Najwiekszy przedstawiciel delfinowatych, jedyny przedstawiciel rodzaju Orcinus.",00
		
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

// funkcja opóznienia
	delay:	mov r0, #15H
	one:	mov r1, #0FFH
	dwa:	mov r2, #0FFH
    trzy:	djnz r2, trzy
		djnz r1, dwa
		djnz r0, one
		ret
			
// funkcja wypisania znaku
putcharLCD:	LCDcharWR
		ret
			
//funkcja wypisania lancucha znaków		
putstrLCDin2Lines: 	
		mov r7, #10H     ;licznik pomocniczy
		push dph         ;makro LCDcntrlWR modyfikuje wartosc dptr, dlatego trzeba ja odlozyc na stos...
		push dpl
		LCDcntrlWR #HOME ;ustaw kursor na poczatku pierwszej linii
		pop dpl			 ;... i nastepnie przywrocic
		pop dph
nextcharinFirstLine:	 ;petla wypisujaca znaki w pierwszej linii
		clr a            
		movc a, @a+dptr
		jz koniec		 ;Dopoki sa jakies znaki do wypisania...
		push dph
		push dpl
		acall putcharLCD ;...wypisuj je...
		pop dpl
		pop dph
		inc dptr         ;... i skacz na poczatek petli
		djnz r7, nextcharinFirstLine
						 ; Jesli pierwsza linia wyswietlacza sie skonczyla...
		mov r7, #10H     ;...ustaw znow licznik pomocniczy...
		push dph
		push dpl
		LCDcntrlWR #HOM2 ;... i przejdz do drugiej linii...
		pop dpl
		pop dph
nextcharinSecondLine:    ;...by w analogiczny sposob wypisac znaki wlasnie tam
		clr a
		movc a, @a+dptr
		jz koniec
		push dph
		push dpl
		acall putcharLCD
		pop dpl
		pop dph
		inc dptr
		djnz r7, nextcharinSecondLine
						 ;po wyjsciu z drugiej petli odczekaj pewien rozsadny czas
		acall delay
		push dph
		push dpl
		LCDcntrlWR #CLEAR;wyczysc ekran przed przystapieniem do powtornego cyklu wypisywania
		pop dpl
		pop dph
		sjmp putstrLCDin2Lines ;skocz na poczatek duzej petli
	koniec: ret

// program glówny
	start:	init_LCD
	
		mov dptr, #text
		acall putstrLCDin2Lines
		acall delay
			
	nop
	nop
	nop
	jmp $
	end start
