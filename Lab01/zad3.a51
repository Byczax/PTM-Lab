ljmp start
	
	; W tym programie zmienna r0 oraz r1 bedzie dzialac jako licznik petli
	; r3 bedzie zmienna do petli poza funkcjami 
	; r4
	; r5 przechowanie tymczasowe
	; r7, r6przechowuja zapisane wartosci
org 050H
	; Opóznienie do wyswietlania (wziete z programu wstawionego na eportalu
	delay:	mov r0, #0FFH
	one:	mov r1, #0FFH
	dwa:	djnz r1, dwa
		djnz r0, one
	ret
		
	; Przesuwaj diode w lewo 8 razy
	wlewo:	mov r0, #08h; petla 8 razy
	skok: 	mov p1, a; przypisanie dla p1 wartosci a
			rl a; przesuniecie a w lewo o jeden bit
			;delay; (skomentowane aby bylo latwiej testowac)
			djnz r0, skok; skok oraz dekrementacja o 1 zmiennej r0
	ret; koniec funkcji
	; Przesuwaj diode w prawo 8 razy
	wprawo:	mov r0, #08h; petla 8 razy
	skok2: 	rr a;przesuniecie a w prawo o jeden bit
			mov p1, a; przypisanie dla p1 wartosci a
			djnz r0, skok2; skok oraz dekrementacja o 1 zmiennej r0
	ret; koniec funkcji
	; przesuwanie a w lewo 
	wlewosave:	mov r0, #08h; petla 8 razy
	skok3: 	mov r5, a;tymczasowe przechowanie wartosci a
			orl a, r7; suma a oraz r7
			mov p1, a; przypisanie p1 sumy wartosci a oraz r7
			mov a, r5; przywrocenie wartosci a przed suma
			rl a; przesuniecie a w lewo o jeden bit
			;delay; (skomentowane aby bylo latwiej testowac)
			djnz r0, skok3; skok oraz dekrementacja o 1 zmiennej r0
	ret; koniec funkcji
	; zsumowanie przesuniecia do swiecenia diody2
	sumaprzesun:
			mov a, r6; cykl przesuniecia r6
			rr a; przesuniecie o 1 bit w prawo
			mov r6, a; przywrocenie wartosci
			orl a,r7; suma a oraz r7
			mov r7, a; zapisanie sumy do r7
			mov a, #01h; reset wartosci a
			ret; koniec funkcji
org 0100h
	start:	mov p1, #00h; reset wartosci p1
			mov a, #01h; reset wartosci a
			
			mov r6, #01h; reset wartosci r6
			mov r7, #00h; reset wartosci r7
			
			
			jmp diody2;wybór trybu swiecenia,do wyboru: 
			; 1.diody1: przemieszczanie sie diody z lewej do prawej i spowrotem
			; 2.diody2: przemieszczanie sie wraz z ladowaniem od prawej strony
			; 3.diody3: pasek ladowania
			
			; Swiecenie tam i spowrotem
			diody1:	acall wlewo; wywloanie funkcji do przesuwania 8 razy wartosci w lewo
					acall wprawo; wywloanie funkcji do przesuwania 8 razy wartosci w prawo
					jmp diody1; ponowne wykonanie
			
			; Swiecenie wraz z ladowaniem z prawej strony
			diody2:
			acall wlewo; ; wywloanie funkcji do przesuwania 8 razy wartosci w lewo
			mov r2, #07h; utworzenie petli 7-krotnej
			petli:	acall sumaprzesun; suma przesuniecia
					acall wlewosave; ; wywloanie funkcji do przesuwania 8 razy wartosci w lewo wraz z zapamietaniem
					djnz r2, petli; ponowne wykonanie
			mov r7, #00h; reset
			mov r6, #01h; reset
			mov a, #01h; reset
			jmp diody2; ponowne wykonanie
			; Swiecenie jak pasek ladowania
			diody3:
			mov p1, #00h; wylaczenie diód
			mov r2, #08h; petla 8-krotna
			;delay; (skomentowane aby bylo latwiej testowac)
			mov r5, a; przypisanie zmiennej tymczasowej wartosci a
			loadskok: 	mov p1, a; wpisanie wartosci
						rl a; przesuniecie wartosci
						orl a, r6; uzupelnienie pustych bitow z tylu
						mov r6, a
						;delay; (skomentowane aby bylo latwiej testowac)
						djnz r2, loadskok; ponowne wykonanie
			mov r6, #01h; reset
			jmp diody3; ponowne wykonanie
		
			; standardowy koniec programu
			nop
			nop
			nop
			jmp $
			end start