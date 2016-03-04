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
    BRA     EAUNKN

; For this method, D6 is in the format of: <3 bits Dst Reg><3 bits Dst Mode> 
EAGETDSTEA  
    MOVE.B  D6,D7       ; Store the right-most byte into D7
    AND.B   #$07,D7     ; Isolate 3 rightmost bits as 'Mode'
    LSR.L   #3,D6       ; Shift D6 to the right 3 bits (D6 Byte = 'Reg')
    CMP.B   #0,D7       ; See if the mode == '000'
    BEQ     EADN
    BRA     EAUNKN
         
;If the EA is a Dn EA    
;This method assume D6 contains the Reg for Dn  
EADN
    MOVE.B  #'D',(A1)+
    ADD.B   #48,D6      ; Add 48 into D6 to turn num 0 into ASCII 0
    MOVE.B  D6,(A1)+
    ADDQ    #2,D1
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
