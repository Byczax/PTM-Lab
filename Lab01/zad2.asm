ljmp start;

org 0100h;
	start:
	
	mov dptr, #8000h ;adres w pamieci zewnetrznej
	mov a, #0f0h     ;akumulator przechowuje bierzaca wartosc do wpisania
	zapis16:		 ;petla zapisujaca 16 kolejnych wartosci bajtow 0x01,0x02,...,0x10
	add a, #10h      ;odtworzenie wartosci z poprzedniej iteracji
	inc a            ;utworzenie nowej wartosci
	movx @dptr, a    ;zapisanie wartosci pod adres
	inc dptr         ;inkrementacja rejestru przechowujacego adres w pamieci zewnetrzenej
	clr c            ;przygotowanie do operacji odejmowania
	subb a, #10h     ;odejmowanie, sluzy sprawdzeniu, czy osiagnieto koniec tablicy
	jc zapis16       ;skok, jesli nie osiagnieto konca tablicy
	
	mov a, #00h      ;znacznik konca tablicy (17-ty bajt)
	movx @dptr, a    ;zapisz znacznik konca tablicy
	
	
	//alternatywny kod, w ktorym rozpisano instrukcje
	//w razie, gdyby uzytkowanik mial potrzebe edycji wartosci bajtow
	/*
	mov dptr, #8000h;przejscie na adres 8000 oraz wpisanie liczb do pierwszych 16 komorek
	mov a, #0fh     ;wartosc do przechowania, przetestowano takze dla wartosci #05h
	movx @dptr, a;
	inc dptr;
	mov a, #02h;
	movx @dptr, a;
	inc dptr;
	mov a, #03h;
	movx @dptr, a;
	inc dptr;
	mov a, #04h;
	movx @dptr, a;
	inc dptr;
	mov a, #05h;
	movx @dptr, a;
	inc dptr;
	mov a, #06h;
	movx @dptr, a;
	inc dptr;
	mov a, #07h;
	movx @dptr, a;
	inc dptr;
	mov a, #08h;
	movx @dptr, a;
	inc dptr;
	mov a, #09h;
	movx @dptr, a;
	inc dptr;
	mov a, #0ah;
	movx @dptr, a;
	inc dptr;
	mov a, #0bh;
	movx @dptr, a;
	inc dptr;
	mov a, #0ch;
	movx @dptr, a;
	inc dptr;
	mov a, #0dh;
	movx @dptr, a;
	inc dptr;
	mov a, #0eh;
	movx @dptr, a;
	inc dptr;
	mov a, #0fh;
	movx @dptr, a;
	inc dptr;
	mov a, #10h;
	movx @dptr, a;
	inc dptr;
	mov a, #00h;
	movx @dptr, a;
	*/
	
	mov r0, #00h     ;maksimum w tablicy
	mov dptr, #8000h ;adres poczatkowy
	
	odczyt16max:	 ;petla odczytujaca 16 elementow tablicy (+ 17-ty, znacznik konca tablicy #00h)
	movx a, @dptr	 ;odczyt wartosci spod adresu
	jz koniecmax
	clr c     		 ;przygotowanie do odejmowania
	subb a, r0		 ;odejmowanie sprawdzajace, czy nowa wartosc jest wieksza od dotychczasowej
	jc niekopiujmax	 ;skok warunkowy, jesli nie jest wieksza
	add a, r0		 ;odtworzenie wartosci w rejestrze a
	mov r0,a		 ;przechowanie nowej maksymalnej wartosci
	niekopiujmax:
	movx a,@dptr	 ;sprawdzenie, czy nie nastapil koniec tablicy
	inc dptr
	jnz odczyt16max
	
	koniecmax:
	
	mov r1, #0ffh    ;minimum w tablicy
	mov dptr, #8000h ;adres poczatkowy
	
	odczyt16min:     ;petla odczytujaca 16 elementow tablicy (+ 17-ty, znacznik konca tablicy #00h)
	movx a, @dptr	 ;odczyt wartosci spod adresu
	jz koniecmin     ;dodatkowy skok sprawdzajacy, czy pobrano bajt #00h
	clr c     		 ;przygotowanie do odejmowania
	subb a, r1		 ;odejmowanie sprawdzajace, czy nowa wartosc jest wieksza od dotychczasowej
	jnc niekopiujmin	 ;skok warunkowy, jesli nie jest wieksza
	add a, r1		 ;odtworzenie wartosci w rejestrze a
	mov r1,a		 ;przechowanie nowej maksymalnej wartosci
	niekopiujmin:
	movx a,@dptr	 ;sprawdzenie, czy nie nastapil koniec tablicy
	inc dptr
	jnz odczyt16min
	
	koniecmin:
	;teraz wartosc maksymalna znaduje sie w r0, a minimalna w r1
	nop;
	nop;
	nop;
	jmp $;
	end start;
