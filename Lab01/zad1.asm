ljmp start
			
org 0100h
	start:	
		mov r1, #00h ;pierwszy 16-bitowy argument w r1-r0
		mov r0, #05h
		
		mov r3, #01h ;drugi 16-bitowy argument w r3-r2
		mov r2, #03h
		
		clr c        ;wyczysc bit pozyczki
		mov a, r0    ;zaladuj do akumulatora mlodsze bity odjemnej
		subb a, r2   ;odejmij mlodsze bity odjemnika
		mov r4, a    ;zapisz mlodsze bity wyniku do r4
		
		mov a, r1    ;zaladuj do akumulatora starsze bity odjemnej
		subb a, r3   ;odejmij starsze bity odjemnika uwzgledniajac pozyczke
		mov r5, a	 ;zapisz wynik w r5
		
	nop
	nop
	nop
	jmp $
	end start
