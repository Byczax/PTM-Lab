MOV R7, A       ;(1) zamiana odczytanego dziwolaga na ASCII 
ANL 07H, #0FH   ;(2)
CLR C           ; wyczyszczenie C aby przypadkiem nie przeszkodzilo
RRC A           ;(3)
ANL A, #0F0H    ;(4)
ORL A, R7       ;(5)
