*-----------------------------------------------------------
* Title      : EA
* Written by : Circles
* Date       : ##/##/16
* Description: Effective Address File
*-----------------------------------------------------------

* Put program code here

; It is assumed that D6 contains the bits for the EA, algined to the far right. D5 contains
;  the original full op-code being reffered to. We assume that A2 contains the address 
;  pointing to the start of our EA address (if applicable), and we assume that A1 contains
;  the address pointing to our IOStringLoc. D1 contains the current length to be printed from A1

; For this method, D6 is in the format of: <3 bits Src Mode><3 bits Src Reg> 
EAGETSRCEA  
    ROR.L   #3,D6       ; Rotate our bits 3 to the right
    MOVE.B  D6,D7       ; Store the mode of the EA in D7
    ROL.L   #3,D6       ; Rotate our 3 bits back
    ANDI.L  #$0007,D6   ; Isolate the 3 rightmost bits as 'Reg'
    CMP.B   #0,D7       ; See if the mode == '000'
    BEQ     EADN

    CMP.B   #1,D7       ; See if the mode == '001'
    BEQ     EAAN        ; Address Register Direct
    
    CMP.B   #2,D7       ; See if the mode == '010'
    BEQ     EAANI       ; Address Register Indirect
    
    CMP.B   #3,D7       ; See if the mode == '011'
    BEQ     EAAPOST     ; Address Register Indirect with Post increment
    
    CMP.B   #4,D7       ; See if the mode == '100'
    BEQ     EAAPRE      ; Address Register Indirect with Pre increment
    
    CMP.B   #7,D7       ; See if the mode == '111' 
    BEQ     EA111       ; Determine if (Immediate Data, Aboslute Word or Long Address)

    BRA     EAUNKN

; For this method, D6 is in the format of: <3 bits Dst Reg><3 bits Dst Mode> 
EAGETDSTEA  
    MOVE.B  D6,D7       ; Store the right-most byte into D7
    AND.B   #$07,D7     ; Isolate 3 rightmost bits as 'Mode'
    LSR.L   #3,D6       ; Shift D6 to the right 3 bits (D6 Byte = 'Reg')
    CMP.B   #0,D7       ; See if the mode == '000'
    BEQ     EADN

    CMP.B   #1,D7       ; See if the mode == '001'
    BEQ     EAAN        ; Address Register Direct
    
    CMP.B   #2,D7       ; See if the mode == '010'
    BEQ     EAANI       ; Address Register Indirect
    
    CMP.B   #3,D7       ; See if the mode == '011'
    BEQ     EAAPOST     ; Address Register Indirect with Post increment
    
    CMP.B   #4,D7       ; See if the mode == '100'
    BEQ     EAAPRE      ; Address Register Indirect with Pre increment
    
    CMP.B   #7,D7       ; See if the mode == '111' 
    BEQ     EA111       ; Determine if (Immediate Data, Aboslute Word or Long Address)

    BRA     EAUNKN
         
;If the EA is a Dn EA    
;This method assume D6 contains the Reg for Dn  
EADN
    MOVE.B  #'D',(A1)+
    ADD.B   #48,D6      ; Add 48 into D6 to turn num 0 into ASCII 0
    MOVE.B  D6,(A1)+
    ADDQ    #2,D1
    RTS
;If the EA is a An EA    
;This method assume D6 contains the Reg for An  
EAAN
    MOVE.B  #'A',(A1)+
    ADD.B   #48,D6      ; Add 48 into D6 to turn num 0 into ASCII 0
    MOVE.B  D6,(A1)+
    ADDQ    #2,D1
    RTS

;If the EA is a (An) EA    
;This method assume D6 contains the Reg for (An)  
EAANI
    MOVE.B  #'(',(A1)+
    MOVE.B  #'A',(A1)+
    ADD.B   #48,D6      ; Add 48 into D6 to turn num 0 into ASCII 0
    MOVE.B  D6,(A1)+
    MOVE.B  #')',(A1)+
    ADDQ    #4,D1
    RTS
;If the EA is a (An)+ EA    
;This method assume D6 contains the Reg for (An)+  
EAAPOST
    MOVE.B  #'(',(A1)+
    MOVE.B  #'A',(A1)+
    ADD.B   #48,D6      ; Add 48 into D6 to turn num 0 into ASCII 0
    MOVE.B  D6,(A1)+
    MOVE.B  #')',(A1)+
    MOVE.B  #'+',(A1)+
    ADDQ    #5,D1
    RTS
;If the EA is a -(An) EA    
;This method assume D6 contains the Reg for -(An) 
EAAPRE
    MOVE.B  #'-',(A1)+
    MOVE.B  #'(',(A1)+
    MOVE.B  #'A',(A1)+
    ADD.B   #48,D6      ; Add 48 into D6 to turn num 0 into ASCII 0
    MOVE.B  D6,(A1)+
    MOVE.B  #')',(A1)+
    ADDQ    #5,D1
    RTS 
;If the EA is a #<data> EA    
;This method assume D6 contains the Reg for #<data>  
EAID
    MOVE.W  #'#$',(A1)+
    ADDQ    #2,D1
    MOVE.W  (A2)+,D6
    CLR     D4
    JSR     EAHEXtoASCII
    RTS
;If the EA is a (xxx).W EA    
;This method assume D6 contains the Reg for (xxx).W  
EAAWA
    MOVE.B  #'$',(A1)+
    ADDQ    #1,D1
    MOVE.W  (A2)+,D6   ; Push our next Word value into D6
    ; Push the ASCII equivlent characters of D6-- only the
    ;   first Word's worth (our entire Word we just acquired)
    CLR     D4
    JSR     EAHEXtoASCII
    
    RTS
;If the EA is a (xxx).L EA    
;This method assume D6 contains the Reg for (xxx).L  
EAALA
    MOVE.B  #'$',(A1)+
    ADDQ    #1,D1
    MOVE.L  (A2)+,D6   ; Push our next Long value into D6
    ; Push the ASCII equivlent characters of D6-- only the
    ;   first Word's worth of our Long
    CLR     D4         ; Clear our counter
    SWAP    D6         ; Flip the high-order Word with the Low-order
    JSR     EAHEXtoASCII
    SWAP    D6         ; Flip the high-order Word with the Low-order
    ; Print the second half of the Long, too
    CLR     D4
    JSR     EAHEXtoASCII
    
    RTS
;If the EA Mode = 111, Determine EA    
;This method assume D6 contains the Reg for EA  
EA111
    CMP.B #0,D6
    BEQ     EAAWA       ; Absolute Word Address 
    CMP.B #1,D6
    BEQ     EAALA       ; Absolute Long Address 
    CMP.B #4,D6
    BEQ     EAID        ; Immediate Data 
    *-----------------------------------------------let fall through? it shouldn't RTS right?
    BRA     EAUNKN
    
; Uses D6 as a storage, D3 as a go-between, and D4 as a counter..
;  This operates on the low-order word of D6, and pushes exactly 4 
;  characters into IOStringLoc, converted from HEX of D6's nybble,
;  to ASCII in IOStringLoc
EAHEXtoASCII    ADDQ    #1,D4
                ROL.W   #4,D6              Get the left-most nyblle to the front..
                MOVE.B  D6,D3              .. Put the front-most byte into D3    
                AND.B   #$0F,D3            Distill D3 down to the original left-most nybble
                CMP.B   #9,D3              See if our number is greater than 9..
                BLE     EADIGIT            If it is 9 or less, it's a digit..
                ADD.B   #7,D3              Otherwise it is a digit, and needs an additional 7
EADIGIT         ADD.B   #48,D3             We now have the nybble's ASCII code
                MOVE.B  D3,(A1)+           Move the ASCII code into the output string at A1
                CMP.B   #4,D4              See if we've read all the characters
                BNE.S   EAHEXtoASCII       Continue if we haven't
                
                ADDQ    #4,D1
                RTS
    
; MOVEM's (A7)+,A0-A6,D0-D7 format
; Gets the follow-up WORD in order to process it
EAMOVEMPOSTI
    MOVE.W  (A2)+,D6    ; Get follow-up word for processing
    
    MOVE.L  #$FF,D7     ; Initilize D7 to be our counter
    
    ROR.L   #7,D6       ; Shift our new bits seven to the right
IANSL    ; Increment An Start Loop  
    ADDQ    #1,D7       ; Itterate D7
    ROR.L   #1,D6       ; Rotate one bit to the right  
    CMP.B   #8,D7       ; Check if we've hit A8
    BEQ     INOA        ; If we have, break the loop
    BTST    #$00,D6     ; Check the far right bit
    BEQ     IANSL       ; If it isn't 1, continue checking
    
    MOVE.B  #'A',(A1)+
    
    ADD.B   #48,D7      ; Add 48 into D7 to turn num 0 into ASCII 0
    MOVE.B  D7,(A1)+
    ADDQ    #2,D1
    
    SUB.B   #47,D7      ; Balance out out D7 from ASCII conversion
    ROR.L   #1,D6       ; Rotate one bit to the right  
    CMP.B   #8,D7       ; Check if we've hit A8
    BEQ     INOEA       ; If we have, break the loop
    BTST    #$00,D6     ; Check the far right bit
    BEQ     INOEA       ; If it is 0, skip past -A
IANEL    ; Increment An End Loop  
    ADDQ    #1,D7       ; Itterate D7
    ROR.L   #1,D6       ; Rotate one bit to the right  
    CMP.B   #8,D7       ; Check if we've hit A8
    BEQ     IANELE      ; If we have, break the loop
    BTST    #$00,D6     ; Check the far right bit
    BNE     IANEL       ; If it isn't 0, continue checking    
IANELE
    SUBQ    #1,D7
    
    MOVE.B  #'-',(A1)+
    MOVE.B  #'A',(A1)+
    
    ADD.B   #48,D7      ; Add 48 into D7 to turn num 0 into ASCII 0
    MOVE.B  D7,(A1)+
    ADDQ    #3,D1
    SUB.B   #48,D7      ; SUB 48 into D7 for ASCII conversion
    BRA     INOEA       ; Branch past the 'No An Skip Label'

INOA     ; No An Skip label 
    BSET.L  #$1F,D7     ; Set our MSB to equal 1
 
INOEA    ; No An Ending (aka Single An) Skip Label
    ADD.B   #1,D7       ; Add 1 for 0ing balance
    BCLR    #$08,D7     ; Incase we're iterated base FF in A
    ROL.L   D7,D6       ; Rotate our A bits back into view
    ROL.L   #8,D6       ; Rotate our D bits back into place
    ROL.L   #1,D6       ; Rotate an extra bit over, to account for the loop
    MOVE.B  #$FF,D7     ; Initilize D7

IDNSL    ; Increment Dn Start Loop  
    ADDQ    #1,D7       ; Itterate D7
    ROR.L   #1,D6       ; Rotate one bit to the right  
    CMP.B   #8,D7       ; Check if we've hit D8
    BEQ     ENDEAMOVEMPI ; If we have, break the loop
    BTST    #$00,D6     ; Check the far right bit
    BEQ     IDNSL       ; If it isn't 1, continue checking     
    
    ; The issue with the below line:
    ;  We need to skip / if there are no An registers, as we do in INOA
    ;  We also need to skip / if there are no Dn registers, as we do here
    ;  However, we need to skip / if there are no An's, but we still need to run
    ;   the above code to determine the starting Dn, so we use the MSB of D7
    ;   as a boolean to determine if we had an An
    BTST    #$1F,D7     ; If our MSB is equal to 1, we have no A
    BNE     INOA2       ; .. So, skip the /
    MOVE.B  #'/',(A1)+
    ADDQ    #1,D1
INOA2     ; 2nd No An Skip label 
    BCLR    #$1F,D7     ; If our MSB is set, clear it
    MOVE.B  #'D',(A1)+
    ADD.B   #48,D7      ; Add 48 into D7 to turn num 0 into ASCII 0
    MOVE.B  D7,(A1)+    
    ADDQ    #2,D1
    
    SUB.B   #47,D7      ; Balance out our D7 from ASCII conversion
    ROR.L   #1,D6       ; Rotate one bit to the right  
    CMP.B   #8,D7       ; Check if we've hit A8
    BEQ     ENDEAMOVEMPI  ; If we have, break to the end
    BTST    #$00,D6     ; Check the far right bit
    BEQ     ENDEAMOVEMPI ; If it is 0, we have no -Dn
IDNEL    ; Increment Dn End Loop  
    ADDQ    #1,D7       ; Itterate D7
    ROR.L   #1,D6       ; Rotate one bit to the right  
    CMP.B   #8,D7       ; Check if we've hit A8
    BEQ     INENLE      ; If we have, break the loop
    BTST    #$00,D6     ; Check the far right bit
    BNE     IDNEL       ; If it isn't 0, continue checking    
INENLE
    SUBQ    #1,D7
    
    MOVE.B  #'-',(A1)+
    MOVE.B  #'D',(A1)+

    ADD.B   #48,D7      ; Add 48 into D7 to turn num 0 into ASCII 0
    MOVE.B  D7,(A1)+
    ADDQ    #3,D1 
    ; If no Dn, skip to the end
ENDEAMOVEMPI
    RTS
    
EAMOVEMPRED
    MOVE.W  (A2)+,D6    ; Get follow-up word for processing
    
    MOVE.L  #$FF,D7     ; Initilize D7 to be our counter
    
    ROR.L   #8,D6       ; Shift our new bits eight to the right
DANSL    ; Decrement An Start Loop  
    ADDQ    #1,D7       ; Itterate D7
    ROL.L   #1,D6       ; Rotate one bit to the left  
    CMP.B   #8,D7       ; Check if we've hit A8
    BEQ     DNOA        ; If we have, break the loop
    BTST    #$00,D6     ; Check the far right bit
    BEQ     DANSL       ; If it isn't 1, continue checking
    
    MOVE.B  #'A',(A1)+
    
    ADD.B   #48,D7      ; Add 48 into D7 to turn num 0 into ASCII 0
    MOVE.B  D7,(A1)+
    ADDQ    #2,D1
    
    SUB.B   #47,D7      ; Balance out out D7 from ASCII conversion
    ROL.L   #1,D6       ; Rotate one bit to the left  
    CMP.B   #8,D7       ; Check if we've hit A8
    BEQ     DNOEA       ; If we have, break the loop
    BTST    #$00,D6     ; Check the far right bit
    BEQ     DNOEA       ; If it is 0, skip past -A
DANEL    ; Decrement An End Loop  
    ADDQ    #1,D7       ; Itterate D7
    ROL.L   #1,D6       ; Rotate one bit to the left  
    CMP.B   #8,D7       ; Check if we've hit A8
    BEQ     DANELE      ; If we have, break the loop
    BTST    #$00,D6     ; Check the far right bit
    BNE     DANEL       ; If it isn't 0, continue checking    
DANELE
    SUBQ    #1,D7
    
    MOVE.B  #'-',(A1)+
    MOVE.B  #'A',(A1)+
    
    ADD.B   #48,D7      ; Add 48 into D7 to turn num 0 into ASCII 0
    MOVE.B  D7,(A1)+
    ADDQ    #3,D1
    SUB.B   #48,D7      ; SUB 48 into D7 for ASCII conversion
    BRA     DNOEA       ; Branch past the 'No An Skip Label'

DNOA     ; No An Skip label 
    BSET.L  #$1F,D7     ; Set our MSB to equal 1
 
DNOEA    ; No An Ending (aka Single An) Skip Label
    ADDQ.B  #1,D7       ; Add 1 for 0ing balance
    BCLR    #$08,D7     ; Incase we're iterated base FF in A
    ROR.L   D7,D6       ; Rotate our A bits back into view
    ROR.L   #8,D6       ; Rotate our D bits back into place
    ROR.L   #1,D6       ; Rotate an extra bit over, to account for the loop
    MOVE.B  #$FF,D7     ; Initilize D7

DDNSL    ; Decrement Dn Start Loop  
    ADDQ.B  #1,D7       ; Itterate D7
    ROL.L   #1,D6       ; Rotate one bit to the right  
    CMP.B   #8,D7       ; Check if we've hit D8
    BEQ     ENDEAMOVEMPD ; If we have, break the loop
    BTST    #$00,D6     ; Check the far right bit
    BEQ     DDNSL       ; If it isn't 1, continue checking     
    
    ; The issue with the below line:
    ;  We need to skip / if there are no An registers, as we do in INOA
    ;  We also need to skip / if there are no Dn registers, as we do here
    ;  However, we need to skip / if there are no An's, but we still need to run
    ;   the above code to determine the starting Dn, so we use the MSB of D7
    ;   as a boolean to determine if we had an An
    BTST    #$1F,D7     ; If our MSB is equal to 1, we have no A
    BNE     DNOA2       ; .. So, skip the /
    MOVE.B  #'/',(A1)+
    ADDQ    #1,D1
DNOA2     ; 2nd No An Skip label 
    BCLR    #$1F,D7     ; If our MSB is set, clear it
    MOVE.B  #'D',(A1)+
    ADD.B   #48,D7      ; Add 48 into D7 to turn num 0 into ASCII 0
    MOVE.B  D7,(A1)+    
    ADDQ    #2,D1
    
    SUB.B   #47,D7      ; Balance out our D7 from ASCII conversion
    ROL.L   #1,D6       ; Rotate one bit to the right  
    CMP.B   #8,D7       ; Check if we've hit A8
    BEQ     ENDEAMOVEMPD  ; If we have, break to the end
    BTST    #$00,D6     ; Check the far right bit
    BEQ     ENDEAMOVEMPD ; If it is 0, we have no -Dn
DDNEL    ; Decrement Dn End Loop  
    ADDQ    #1,D7       ; Itterate D7
    ROL.L   #1,D6       ; Rotate one bit to the right  
    CMP.B   #8,D7       ; Check if we've hit A8
    BEQ     DNENLE      ; If we have, break the loop
    BTST    #$00,D6     ; Check the far right bit
    BNE     DDNEL       ; If it isn't 0, continue checking    
DNENLE
    SUBQ    #1,D7
    
    MOVE.B  #'-',(A1)+
    MOVE.B  #'D',(A1)+

    ADD.B   #48,D7      ; Add 48 into D7 to turn num 0 into ASCII 0
    MOVE.B  D7,(A1)+
    ADDQ    #3,D1 
    ; If no Dn, skip to the end
ENDEAMOVEMPD
    RTS

; If the EA is unknown
EAUNKN
    MOVE.B  #'<',(A1)+  ; We did this byte-by-byte in case A1 is at an odd register
    MOVE.B  #'E',(A1)+
    MOVE.B  #'A',(A1)+
    MOVE.B  #'>',(A1)+
    ADDQ    #4,D1
    RTS

* Put variables and constants here







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
