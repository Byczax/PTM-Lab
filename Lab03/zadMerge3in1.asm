ljmp start

P5 equ 0F8H
P7 equ 0DBH
	
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

	delay:	mov r1, #0FFH
	dwa:	mov r2, #0FFH
	trzy:	djnz r2, trzy
			djnz r1, dwa
			ret
			
// funkcja wypisania znaku
putcharLCD:	LCDcharWR
			ret

//------------------------------------------------------------------
// znak do wyswietlenia w akumulatorze, 
//ktory jest uzywany - koniecznosc uzycia stosu lub innego rejestru
putkbdCharsin2Lines:
;sprawdzenie, czy r5 == #20H, wtedy przenosimy kursor do pierwszej linii
		mov r4, a
		mov a, r5
		clr c
		subb a, #20H
		jnz nieUstawiajPoczatku1Linii ;
		
		LCDcntrlWR #HOME
		
		nieUstawiajPoczatku1Linii:
		mov a, r5
		clr c
		subb a, #10H
		jnz nieUstawiajPoczatku2Linii
		
		LCDcntrlWR #HOM2
		
		nieUstawiajPoczatku2Linii:
		mov a, r5
		clr c
		subb a, #00H
		jnz nieClear
		
		LCDcntrlWR #CLEAR
		LCDcntrlWR #HOME
		mov r5, #20H
		
		nieClear:
		mov a, r4 ; a - wartosc znaku do wpisania na wyswietlacz
		acall putCharLCD
		dec r5
		
koniec: ret

//------------------------------------------------------------------
// tablica przekodowania klawisze - ASCII w XRAM

keyascii:	
			; znaki dla nacisniecia *
			; Uklad klawiatury:
			/*
					a b c d
					e f g h
					i j k l
					  m			
			*/
			mov dptr, #80EBH
			mov a, #"m"
			movx @dptr, a
			
			mov dptr, #8077H
			mov a, #"a"
			movx @dptr, a
			
			mov dptr, #807BH
			mov a, #"b"
			movx @dptr, a
			
			mov dptr, #807DH
			mov a, #"c"
			movx @dptr, a
			
			mov dptr, #80B7H
			mov a, #"e"
			movx @dptr, a
			
			mov dptr, #80BBH
			mov a, #"f"
			movx @dptr, a
			
			mov dptr, #80BDH
			mov a, #"g"
			movx @dptr, a
			
			mov dptr, #80D7H
			mov a, #"i"
			movx @dptr, a
			
			mov dptr, #80DBH
			mov a, #"j"
			movx @dptr, a
			
			mov dptr, #80DDH
			mov a, #"k"
			movx @dptr, a
			
			mov dptr, #807EH
			mov a, #"d"
			movx @dptr, a
			
			mov dptr, #80BEH
			mov a, #"h"
			movx @dptr, a
			
			mov dptr, #80DEH
			mov a, #"l"
			movx @dptr, a
			
			; znaki dla nacisniecia #
			; Uklad klawiatury:
			/*
					A B C D
					E F G H
					I J K L
					  M
			*/
			mov dptr, #81EBH
			mov a, #"M"
			movx @dptr, a
			
			mov dptr, #8177H
			mov a, #"A"
			movx @dptr, a
			
			mov dptr, #817BH
			mov a, #"B"
			movx @dptr, a
			
			mov dptr, #817DH
			mov a, #"C"
			movx @dptr, a
			
			mov dptr, #81B7H
			mov a, #"E"
			movx @dptr, a
			
			mov dptr, #81BBH
			mov a, #"F"
			movx @dptr, a
			
			mov dptr, #81BDH
			mov a, #"G"
			movx @dptr, a
			
			mov dptr, #81D7H
			mov a, #"I"
			movx @dptr, a
			
			mov dptr, #81DBH
			mov a, #"J"
			movx @dptr, a
			
			mov dptr, #81DDH
			mov a, #"K"
			movx @dptr, a
			
			mov dptr, #817EH
			mov a, #"D"
			movx @dptr, a
			
			mov dptr, #81BEH
			mov a, #"H"
			movx @dptr, a
			
			mov dptr, #81DEH
			mov a, #"L"
			movx @dptr, a
			
			; znaki dla nacisniecia D
			; Uklad klawiatury:
			/*
					1 2 3 A
					4 5 6 B
					7 8 9 C
					  0
			*/
			mov dptr, #82EBH
			mov a, #"0"
			movx @dptr, a
			
			mov dptr, #8277H
			mov a, #"1"
			movx @dptr, a
			
			mov dptr, #827BH
			mov a, #"2"
			movx @dptr, a
			
			mov dptr, #827DH
			mov a, #"3"
			movx @dptr, a
			
			mov dptr, #82B7H
			mov a, #"4"
			movx @dptr, a
			
			mov dptr, #82BBH
			mov a, #"5"
			movx @dptr, a
			
			mov dptr, #82BDH
			mov a, #"6"
			movx @dptr, a
			
			mov dptr, #82D7H
			mov a, #"7"
			movx @dptr, a
			
			mov dptr, #82DBH
			mov a, #"8"
			movx @dptr, a
			
			mov dptr, #82DDH
			mov a, #"9"
			movx @dptr, a
			
			mov dptr, #827EH
			mov a, #";"
			movx @dptr, a
			
			mov dptr, #82BEH
			mov a, #"-"
			movx @dptr, a
			
			mov dptr, #82DEH
			mov a, #")"
			movx @dptr, a
			ret
//------------------------------------------------------------------
// program glówny
start:
		init_LCD
		acall keyascii

		mov r3, #80h; zakladamy, ze na poczatku dzialamy w trybie *

key_1:	
		mov r0, #LINE_1
		mov	a, r0
		mov	P5, a
		mov a, P7
		anl a, r0
		mov r2, a
		clr c
		subb a, r0
		jz key_2
		mov a, r2
		mov dph, r3
		mov dpl, a
		movx a,@dptr
		mov P1, a
		acall putcharLCD
		//zatrzymanie repetycji klawisza
pushed_1:
	//nawiasy z lewej=wcisniete to samo, z prawej=klawisz puszczony
	mov a, P7; wczytanie informacji o wcisnietej kolumnie 
	//[P7=1111 0111 -> a=1111 0111][P7=1111 1111 -> a=1111 1111]
	anl a, r0
	//[a = 0111 0111] [a = 0111 1111]
	clr c; wyczyszczenie aby nie przeszkadzal
	subb a, r0; odejmij, jezeli jest to samo to beda wszystkie bity=0 
	//[0111 0111-0111 1111=~0000 1000][0111 1111-0111 1111=0000 0000]
	jnz pushed_1; to nie przechodz dalej
	acall delay; poczekaj chwile zanim kontynuujesz
			
key_2:	
		mov r0, #LINE_2
		mov	a, r0
		mov	P5, a
		mov a, P7
		anl a, r0
		mov r2, a
		clr c
		subb a, r0
		jz key_3
		mov a, r2
		mov dph, r3
		mov dpl, a
		movx a,@dptr
		mov P1, a
		acall putcharLCD
		//zatrzymanie repetycji klawisza
pushed_2:
	//nawiasy z lewej=wcisniete to samo, z prawej=klawisz puszczony
	mov a, P7; wczytanie informacji o wcisnietej kolumnie 
	//[P7=1111 0111 -> a=1111 0111][P7=1111 1111 -> a=1111 1111]
	anl a, r0
	//[a = 0111 0111] [a = 0111 1111]
	clr c; wyczyszczenie aby nie przeszkadzal
	subb a, r0; odejmij, jezeli jest to samo to beda wszystkie bity=0 
	//[0111 0111-0111 1111=~0000 1000][0111 1111-0111 1111=0000 0000]
	jnz pushed_2; to nie przechodz dalej
	acall delay; poczekaj chwile zanim kontynuujesz
			
key_3:	
		mov r0, #LINE_3
		mov	a, r0
		mov	P5, a
		mov a, P7
		anl a, r0
		mov r2, a
		clr c
		subb a, r0
		jz key_4
		mov a, r2
		mov dph, r3
		mov dpl, a
		movx a,@dptr
		mov P1, a
		acall putcharLCD
		//zatrzymanie repetycji klawisza
pushed_3:
	//nawiasy z lewej=wcisniete to samo, z prawej=klawisz puszczony
	mov a, P7; wczytanie informacji o wcisnietej kolumnie 
	//[P7=1111 0111 -> a=1111 0111][P7=1111 1111 -> a=1111 1111]
	anl a, r0
	//[a = 0111 0111] [a = 0111 1111]
	clr c; wyczyszczenie aby nie przeszkadzal
	subb a, r0; odejmij, jezeli jest to samo to beda wszystkie bity=0 
	//[0111 0111-0111 1111=~0000 1000][0111 1111-0111 1111=0000 0000]

	jnz pushed_3; to nie przechodz dalej
	acall delay; poczekaj chwile zanim kontynuujesz
			
key_4:	
		mov r0, #LINE_4
		mov	a, r0
		mov	P5, a
		mov a, P7
		anl a, r0
		mov r2, a
		clr c
		subb a, r0
		jz key_1
		//Analiza czy uzytkownik chce zmienic tryb dzialania 
		//+ sprawdzanie wcisniecia znaku 0
		mov a, r2
		;mamy teraz backup w r2
		;sprawdzenie *
		clr c
		subb a, #0E7H ;kod skaningowy *
		jz modeStar
		;jesli nie, to odtworz a i sprawdz #
		mov a, r2
		clr c
		subb a, #0EDH ;kod skaningowy #
		jz modeHash
		;jesli nie, to odtworz i sprawdz D
		mov a, r2
		clr c
		subb a, #0EEH ;kod skaningowy D
		jz modeD
		//jesli nic sie nie spelnilo, to znaczy ze mamy naciniety klawisz "0", 
		//i mozemy bezpiecznie nawiazac do zainicjowanej wczesniej komorki pamieci
		mov a, r2
		mov dph, r3
		mov dpl, a
		movx a,@dptr
		mov P1, a
		acall putcharLCD
		//zatrzymanie repetycji klawisza

pushed_4:
	//nawiasy z lewej=wcisniete to samo, z prawej=klawisz puszczony
	mov a, P7; wczytanie informacji o wcisnietej kolumnie 
	//[P7=1111 0111 -> a=1111 0111][P7=1111 1111 -> a=1111 1111]
	anl a, r0
	//[a = 0111 0111] [a = 0111 1111]
	clr c; wyczyszczenie aby nie przeszkadzal
	subb a, r0; odejmij, jezeli jest to samo to beda wszystkie bity=0 
	//[0111 0111-0111 1111=~0000 1000][0111 1111-0111 1111=0000 0000]
	jnz pushed_4; to nie przechodz dalej
	acall delay; poczekaj chwile zanim kontynuujesz
			
	zapetl:	
		jmp key_1
		;minifunkcje ustawiajace odpowiedni uklad klawiatury
		modeStar:
			mov r3, #080h
			sjmp zapetl
			
		modeHash:
			mov r3, #081h
			sjmp zapetl
			
		modeD:
			mov r3, #082h
			sjmp zapetl
	nop
	nop
	nop
	jmp $
	end start