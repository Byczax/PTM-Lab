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
			
			 ; znak do wyswietlenia w akumulatorze, ktory jest uzywany - koniecznosc uzycia stosu lub innego rejestru
 putkbdCharsin2Lines:
		;sprawdzenie, czy r3==#20H, wtedy przenosimy kursor do pierwszej linii
		mov r4, a
		mov a, r3
		clr c
		subb a, #20H
		jnz nieUstawiajPoczatku1Linii ;
		
		LCDcntrlWR #HOME
		
		nieUstawiajPoczatku1Linii:
		mov a, r3
		clr c
		subb a, #10H
		jnz nieUstawiajPoczatku2Linii
		
		LCDcntrlWR #HOM2
		
		nieUstawiajPoczatku2Linii:
		mov a, r3
		clr c
		subb a, #00H
		jnz nieClear
		
		LCDcntrlWR #CLEAR
		LCDcntrlWR #HOME
		mov r3, #20H
		
		nieClear:
		mov a, r4 ; a - wartosc znaku do wpisania na wyswietlacz
		acall putCharLCD
		dec r3
		
 koniec: ret

// tablica przekodowania klawisze - ASCII w XRAM

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
 
// program glówny
    start:  init_LCD
	
			mov r3, #20H ;licznik pomocniczy
	
			acall keyascii
			; w nawiasach co sie dzieje gdy przycisk spelniajacy warunek jest wcisniety
	key_1:	mov r0, #LINE_1; wczytanie linii pierwszej [r0 = 0111 1111]
			mov	a, r0; wpisanie r0 do akumulatora [ a = 0111 1111]
			mov	P5, a; aktywacja portu P5 [ P5 = 0111 1111]
			mov a, P7; wczytanie informacji o wcisnietym przycisku [P7 = 1111 0111 -> a = 1111 0111]
			anl a, r0; AND - utworzenie maski wiersza [a = 0111 0111]
			mov r2, a; zapisanie akumulatora na potem [r2 = 0111 0111]
			clr c; wyczyszczenie c aby nie kolidowal w subb
			subb a, r0; sprawdzenie czy jest wcisniety przycisk [0111 0111 - 0111 1111 =~ 0000 1000] (=~ niprawdziwy wynik ale pokazane ze rozne od zera) 
			jz key_2; jezeli nie wcisniety skocz do nastepnego
			; jezeli przycisk jest wcisniety to wykonaj wyswietlenie:
			mov a, r2; wczytaj co jest wcisniete [a = 0111 0111]
			mov dph, #80h ; wpisz wartosc 80 do starszej czesci dptr
			mov dpl, a; wpisz akumulator do mlodszej czesci dptr
			movx a,@dptr; ladowanie znaku ascii do akumulatora
			mov P1, a; podaj znak na port P1 - Diody
			acall putcharLCD; wypisz znak
			
			
wcisniety_1:
			; nawiasy z lewej = wcisniete to samo, z prawej = klawisz puszczony
			mov a, P7; wczytanie informacji o wcisetej kolumnie [P7 = 1111 0111 -> a = 1111 0111] [P7 = 1111 1111 -> a = 1111 1111]
			anl a, r0; [a = 0111 0111] [a = 0111 1111]
			clr c; wyczyszczenie aby nie przeszkadzal
			subb a, r0; odejmij, jezeli jest to samo co wyzej to beda wszystkie 0 [ 0111 0111 - 0111 1111 =~ 0000 1000] [ 0111 1111 - 0111 1111 = 0000 0000]
			jnz wcisniety_1; to nie przechodz dalej
			
	key_2:	mov r0, #LINE_2
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz key_3
			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a,@dptr
			mov P1, a
			acall putkbdCharsin2Lines
wcisniety_2:
			; nawiasy z lewej = wcisniete to samo, z prawej = klawisz puszczony
			mov a, P7; wczytanie informacji o wcisetej kolumnie [P7 = 1111 0111 -> a = 1111 0111] [P7 = 1111 1111 -> a = 1111 1111]
			anl a, r0; [a = 0111 0111] [a = 0111 1111]
			clr c; wyczyszczenie aby nie przeszkadzal
			subb a, r0; odejmij, jezeli jest to samo co wyzej to beda wszystkie 0 [ 0111 0111 - 0111 1111 =~ 0000 1000] [ 0111 1111 - 0111 1111 = 0000 0000]
			jnz wcisniety_2; to nie przechodz dalej
			
	key_3:	mov r0, #LINE_3
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz key_4
			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a,@dptr
			mov P1, a
			acall putkbdCharsin2Lines
wcisniety_3:
			; nawiasy z lewej = wcisniete to samo, z prawej = klawisz puszczony
			mov a, P7; wczytanie informacji o wcisetej kolumnie [P7 = 1111 0111 -> a = 1111 0111] [P7 = 1111 1111 -> a = 1111 1111]
			anl a, r0; [a = 0111 0111] [a = 0111 1111]
			clr c; wyczyszczenie aby nie przeszkadzal
			subb a, r0; odejmij, jezeli jest to samo co wyzej to beda wszystkie 0 [ 0111 0111 - 0111 1111 =~ 0000 1000] [ 0111 1111 - 0111 1111 = 0000 0000]
			jnz wcisniety_3; to nie przechodz dalej
			
	key_4:	mov r0, #LINE_4
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz key_1
			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a,@dptr
			mov P1, a
			acall putkbdCharsin2Lines
wcisniety_4:
			; nawiasy z lewej = wcisniete to samo, z prawej = klawisz puszczony
			mov a, P7; wczytanie informacji o wcisetej kolumnie [P7 = 1111 0111 -> a = 1111 0111] [P7 = 1111 1111 -> a = 1111 1111]
			anl a, r0; [a = 0111 0111] [a = 0111 1111]
			clr c; wyczyszczenie aby nie przeszkadzal
			subb a, r0; odejmij, jezeli jest to samo co wyzej to beda wszystkie 0 [ 0111 0111 - 0111 1111 =~ 0000 1000] [ 0111 1111 - 0111 1111 = 0000 0000]
			jnz wcisniety_4; to nie przechodz dalej
			
			jmp key_1
            
          
 
    nop
    nop
    nop
    jmp $
    end start
