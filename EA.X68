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
    CMP.B   #2,D0
    BGT     EAIDL
    MOVE.W  (A2)+,D6
    CLR     D4
    JSR     EAHEXtoASCII
    RTS
    
;If the EA is a #<data> EA    
;This method assume D6 contains the Reg for #<data> of size Long
EAIDL
    MOVE.L  (A2)+,D6
    CLR     D4
    SWAP    D6
    JSR     EAHEXtoASCII
    SWAP    D6
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
EAMOVEMPOSTI ; Initilize variables for An and MOVEM
    MOVE.W  (A2)+,D5
    MOVE.L  D5,D6
    ROR.L   #7,D6                   ; Rotate our A bits to the front
    CLR     D0
    CLR     D7
    MOVE.L  #$FF,D7                 ; Initlize our D7 to -1 
EAMOVEMPOSTIAN
    JSR     EAMOVEMPOSTILOOPSTART   ; Find our starting An
    CMP     #8,D7
    BGE     EAMOVEMPOSTIANEND       ; If A8, branch to AnEnd
    JSR     EAMOVEMSLASH            ; Add a slash, if we need to
    
    MOVE.B  #'A',(A1)+
    ADD.W   #48,D7                  ; Convert D7 to ASCII equivlent
    MOVE.B  D7,(A1)+
    ADDQ    #2,D1                   ; Add our number into IOStringLoc
    SUB     #47,D7                  ; Equilize D7
    
    ; Check immediately next number to see if there is an ending
    MOVE.B  #1,D0                   ; Set our slash equal to TRUE
    CMP     #8,D7
    BGE     EAMOVEMPOSTIANEND       ; If A8, branch to AnEnd
    ROR.L   #1,D6                   ; See if our next bit is set
    BTST    #$00,D6                 ; If it isn't set, we have no '-An'..
    BEQ     EAMOVEMPOSTIAN          ; .. Look for our next /An
    
    JSR     EAMOVEMPOSTILOOPEND
    CMP     #8,D7
    BGE     EAMOVEMPOSTIANEND       ; If A8, branch to AnEnd
    MOVE.B  #'-',(A1)+
    MOVE.B  #'A',(A1)+
    ADD.W    #48,D7                  ; Convert D7 to ASCII equivlent
    MOVE.B  D7,(A1)+
    ADDQ    #3,D1                   ; Add our number into IOStringLoc
    SUB     #48,D7                  ; Equilize D7
    
    ADDQ    #1,D7                   ; Account for our extra rotation in LoopEnd
    BRA     EAMOVEMPOSTIAN
    
EAMOVEMPOSTIANEND ; Initilize variables for Dn
    MOVE.L  D5,D6
    CLR     D7
    MOVE.L  #$FF,D7                 ; Initlize our D7 to -1 
    ROL.L   #1,D6                   ; Initlize our mask to -1
EAMOVEMPOSTIDN
    JSR     EAMOVEMPOSTILOOPSTART   ; Find our starting Dn
    CMP     #8,D7
    BGE     EAMOVEMPOSTIEND         ; If D8, branch to End
    JSR     EAMOVEMSLASH            ; Add a slash, if we need to
    
    MOVE.B  #'D',(A1)+
    ADD.W   #48,D7                  ; Convert D7 to ASCII equivlent
    MOVE.B  D7,(A1)+
    ADDQ    #2,D1                   ; Add our number into IOStringLoc
    SUB     #47,D7                  ; Equilize D7
    
    ; Check immediately next number to see if there is an ending
    MOVE.B  #1,D0                   ; Set our slash equal to TRUE
    CMP     #8,D7
    BGE     EAMOVEMPOSTIEND         ; If D8, branch to End
    ROR.L   #1,D6                   ; See if our next bit is set
    BTST    #$00,D6                 ; If it isn't set, we have no '-Dn'..
    BEQ     EAMOVEMPOSTIDN          ; .. Look for our next /Dn
    
    JSR     EAMOVEMPOSTILOOPEND
    CMP     #8,D7
    BGE     EAMOVEMPOSTIEND         ; If D8, branch to End
    MOVE.B  #'-',(A1)+
    MOVE.B  #'D',(A1)+
    ADD.W    #48,D7                  ; Convert D7 to ASCII equivlent
    MOVE.B  D7,(A1)+
    ADDQ    #3,D1                   ; Add our number into IOStringLoc
    SUB     #48,D7                  ; Equilize D7
    
    ADDQ    #1,D7                   ; Account for our extra rotation in LoopEnd
    BRA     EAMOVEMPOSTIDN

EAMOVEMPOSTIEND
    RTS
    
EAMOVEMPOSTILOOPSTART
    ADDQ.B  #1,D7       ; Itterate D7
    ROR.L   #1,D6       ; Rotate one bit to the right  
    CMP.B   #8,D7       ; Check if we've hit A8
    BGE     EAMOVEMSLASHEND      ; If we have, break the loop
    BTST    #$00,D6     ; Check the far right bit
    BEQ     EAMOVEMPOSTILOOPSTART       ; If it is 0, continue checking 
    RTS
    
EAMOVEMPOSTILOOPEND
    ADDQ.B  #1,D7       ; Itterate D7
    ROR.L   #1,D6       ; Rotate one bit to the right  
    CMP.B   #9,D7       ; Check if we've hit A8
    BGE     EAMOVEMSLASHEND      ; If we have, break the loop
    BTST    #$00,D6     ; Check the far right bit
    BNE     EAMOVEMPOSTILOOPEND       ; If it isn't 0, continue checking 
    SUBQ    #1,D7
    RTS
    
EAMOVEMSLASH
    CMP     #1,D0       ; If D0 != 1
    BNE     EAMOVEMSLASHEND  ; RTS
    CLR     D0          ; Reset our slash
    MOVE.B  #'/',(A1)+  ; Otherwise Add a slash
    ADDQ    #1,D1  
EAMOVEMSLASHEND     
    RTS
    
; MOVEM's A0-A6,D0-D7,-(An) format
; Gets the follow-up WORD in order to process it
EAMOVEMPRED ; Initilize variables for An and MOVEM
    MOVEM.L D5,-(SP)                ; Save our original OpCode for later
    MOVE.W  (A2)+,D5
    MOVE.L  D5,D6
    ROR.L   #8,D6                   ; Rotate our A bits to the front
    CLR     D0
    CLR     D7
    MOVE.L  #$FF,D7                 ; Initlize our D7 to -1 
EAMOVEMPREDAN
    JSR     EAMOVEMPREDLOOPSTART    ; Find our starting An
    CMP     #8,D7
    BGE     EAMOVEMPREDANEND        ; If A8, branch to AnEnd
    JSR     EAMOVEMSLASH            ; Add a slash, if we need to
    
    MOVE.B  #'A',(A1)+
    ADD.W   #48,D7                  ; Convert D7 to ASCII equivlent
    MOVE.B  D7,(A1)+
    ADDQ    #2,D1                   ; Add our number into IOStringLoc
    SUB     #47,D7                  ; Equilize D7
    
    ; Check immediately next number to see if there is an ending
    MOVE.B  #1,D0                   ; Set our slash equal to TRUE
    CMP     #8,D7
    BGE     EAMOVEMPREDANEND        ; If A8, branch to AnEnd
    ROL.L   #1,D6                   ; See if our next bit is set
    BTST    #$00,D6                 ; If it isn't set, we have no '-An'..
    BEQ     EAMOVEMPREDAN           ; .. Look for our next /An
    
    JSR     EAMOVEMPREDLOOPEND
    CMP     #8,D7
    BGE     EAMOVEMPREDANEND        ; If A8, branch to AnEnd
    MOVE.B  #'-',(A1)+
    MOVE.B  #'A',(A1)+
    ADD.W    #48,D7                 ; Convert D7 to ASCII equivlent
    MOVE.B  D7,(A1)+
    ADDQ    #3,D1                   ; Add our number into IOStringLoc
    SUB     #48,D7                  ; Equilize D7
    
    ADDQ    #1,D7                   ; Account for our extra rotation in LoopEnd
    BRA     EAMOVEMPREDAN
    
EAMOVEMPREDANEND ; Initilize variables for Dn
    MOVE.L  D5,D6
    CLR     D7
    MOVE.L  #$FF,D7                 ; Initlize our D7 to -1 
    ROL.L   #8,D6                   ; Initlize our mask to -1
    ROL.L   #8,D6                   ;
EAMOVEMPREDDN
    JSR     EAMOVEMPREDLOOPSTART   ; Find our starting Dn
    CMP     #8,D7
    BGE     EAMOVEMPREDEND          ; If D8, branch to End
    JSR     EAMOVEMSLASH            ; Add a slash, if we need to
    
    MOVE.B  #'D',(A1)+
    ADD.W   #48,D7                  ; Convert D7 to ASCII equivlent
    MOVE.B  D7,(A1)+
    ADDQ    #2,D1                   ; Add our number into IOStringLoc
    SUB     #47,D7                  ; Equilize D7
    
    ; Check immediately next number to see if there is an ending
    MOVE.B  #1,D0                   ; Set our slash equal to TRUE
    CMP     #8,D7
    BGE     EAMOVEMPREDEND          ; If D8, branch to End
    ROL.L   #1,D6                   ; See if our next bit is set
    BTST    #$00,D6                 ; If it isn't set, we have no '-Dn'..
    BEQ     EAMOVEMPREDDN           ; .. Look for our next /Dn
    
    JSR     EAMOVEMPREDLOOPEND
    CMP     #8,D7
    BGE     EAMOVEMPREDEND          ; If D8, branch to End
    MOVE.B  #'-',(A1)+
    MOVE.B  #'D',(A1)+
    ADD.W   #48,D7                  ; Convert D7 to ASCII equivlent
    MOVE.B  D7,(A1)+
    ADDQ    #3,D1                   ; Add our number into IOStringLoc
    SUB     #48,D7                  ; Equilize D7
    
    ADDQ    #1,D7                   ; Account for our extra rotation in LoopEnd
    BRA     EAMOVEMPREDDN

EAMOVEMPREDEND
    MOVEM.L (SP)+,D5
    RTS
    
EAMOVEMPREDLOOPSTART
    ADDQ.B  #1,D7       ; Itterate D7
    ROL.L   #1,D6       ; Rotate one bit to the right  
    CMP.B   #8,D7       ; Check if we've hit A8
    BGE     EAMOVEMSLASHEND      ; If we have, break the loop
    BTST    #$00,D6     ; Check the far right bit
    BEQ     EAMOVEMPREDLOOPSTART       ; If it is 0, continue checking 
    RTS
    
EAMOVEMPREDLOOPEND
    ADDQ.B  #1,D7       ; Itterate D7
    ROL.L   #1,D6       ; Rotate one bit to the right  
    CMP.B   #9,D7       ; Check if we've hit A8
    BGE     EAMOVEMSLASHEND      ; If we have, break the loop
    BTST    #$00,D6     ; Check the far right bit
    BNE     EAMOVEMPREDLOOPEND       ; If it isn't 0, continue checking 
    SUBQ    #1,D7
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
