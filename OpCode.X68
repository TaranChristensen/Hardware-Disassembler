*-----------------------------------------------------------
* Title      : OpCode
* Written by : Circles
* Date       : ##/##/16
* Description: Operation Codes File
*-----------------------------------------------------------

* Put program code here

; Here we assume that A2 contains the address pointing to our OpCode, and
;  we assume that A1 contains the address pointing to our IOStringLoc
OPGETCODE   MOVE.L  (A2)+,D5    ; Push our OpCode into D5
            ROL.L   #4,D5       ; Rotate our OpCode 1 nybble left
            MOVE.B  D5,D6       ; Push the nybble's byte into D6
            ANDI.B  #$0F,D6     ; Isolate our opcode nybble
            CMP.B   #$01,D6     
            BEQ.S   MOVEB       ; MOVE.B
            CMP.B   #$03,D6     
            BEQ.S   MOVEW       ; MOVE.W
            CMP.B   #$02,D6
            BEQ.S   MOVEL       ; MOVE.L
            
            BRA.S   UNKNOWN
            
MOVEB
            MOVE.L  #'MOVE',(A1)+
            MOVE.W  #'.B',(A1)+
            ADDQ    #6,D1           ; We added 6 new characters to our IOStringLoc 
            RTS
MOVEW
            MOVE.L  #'MOVE',(A1)+
            MOVE.W  #'.W',(A1)+
            ADDQ    #6,D1           ; We added 6 new characters to our IOStringLoc 
            RTS
MOVEL
            MOVE.L  #'MOVE',(A1)+
            MOVE.W  #'.L',(A1)+
            ADDQ    #6,D1           ; We added 6 new characters to our IOStringLoc 
            RTS

UNKNOWN
            MOVE.L  #'????',(A1)+
            ADDQ    #4,D1           ; We added 4 new characters to our IOStringLoc 
            RTS
* Put variables and constants here



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
