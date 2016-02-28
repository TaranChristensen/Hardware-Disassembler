*-----------------------------------------------------------
* Title      : OpCode
* Written by : Circles
* Date       : ##/##/16
* Description: Operation Codes File
*-----------------------------------------------------------

* Put program code here

; Here we assume that A2 contains the address pointing to our OpCode, and
;  we assume that A1 contains the address pointing to our IOStringLoc
OPGETCODE   MOVE.W  (A2)+,D5    ; Push our OpCode into D5
            MOVE.L  D5,D6       ; Also store the OpCode in D6
            ROR.L   #8,D6       ; Rotate our OpCode to right-most nybble
            ROR.L   #4,D6       ; 
            ANDI.B  #$0F,D6     ; Isolate our opcode nybble
            CMP.B   #$01,D6     
            BEQ.S   MOVEB       ; MOVE.B
            CMP.B   #$03,D6     
            BEQ.S   MOVEW       ; MOVE.W
            CMP.B   #$02,D6
            BEQ.S   MOVEL       ; MOVE.L
            
            BRA     UNKNOWN
            
MOVEB
            MOVE.L  #'MOVE',(A1)+
            MOVE.W  #'.B',(A1)+
            ADDQ    #6,D1           ; We added 6 new characters to our IOStringLoc 
            
            MOVE.L  #'    ',(A1)+     ; Add a spacer into our IOStringLoc
            ADDQ    #4,D1           ; We added 4 bytes, aka 4 spaces
            
            MOVE.L  D5,D6              ; Push D5 into D6
            ANDI.L  #$003F,D6          ; Isolate the Src EA bits 
            JSR EAGETSRCEA             ; Find and print the code stored in D6
            
            MOVE.B  #',',(A1)+
            ADDQ    #1,D1
            
            MOVE.L  D5,D6              ; Push D5 into D6
            LSR.L   #6,D6              ; Shift six bits to the right
            ANDI.L  #$003F,D6          ; Isolate the Dst EA bits
            JSR EAGETDSTEA
            
            RTS
MOVEW
            MOVE.L  #'MOVE',(A1)+
            MOVE.W  #'.W',(A1)+
            ADDQ    #6,D1           ; We added 6 new characters to our IOStringLoc 
            
            MOVE.L  #'    ',(A1)+       ; Add a spacer into our IOStringLoc
            ADDQ    #4,D1               ; We added 4 bytes, aka 4 spaces
            
            MOVE.L  D5,D6              ; Push D5 into D6
            ANDI.L  #$003F,D6          ; Isolate the Src EA bits 
            JSR EAGETSRCEA             ; Find and print the code stored in D6
            
            MOVE.B  #',',(A1)+
            ADDQ    #1,D1
            
            MOVE.L  D5,D6              ; Push D5 into D6
            LSR.L   #6,D6              ; Shift six bits to the right
            ANDI.L  #$003F,D6          ; Isolate the Dst EA bits
            JSR EAGETDSTEA
            
            RTS
MOVEL
            MOVE.L  #'MOVE',(A1)+
            MOVE.W  #'.L',(A1)+
            ADDQ    #6,D1           ; We added 6 new characters to our IOStringLoc 
            
            MOVE.L  #'    ',(A1)+       ; Add a spacer into our IOStringLoc
            ADDQ    #4,D1               ; We added 4 bytes, aka 4 spaces
            
            MOVE.L  D5,D6              ; Push D5 into D6
            ANDI.L  #$003F,D6          ; Isolate the Src EA bits 
            JSR EAGETSRCEA             ; Find and print the code stored in D6
            
            MOVE.B  #',',(A1)+
            ADDQ    #1,D1
            
            MOVE.L  D5,D6              ; Push D5 into D6
            LSR.L   #6,D6              ; Shift six bits to the right
            ANDI.L  #$003F,D6          ; Isolate the Dst EA bits
            JSR EAGETDSTEA
            
            RTS

UNKNOWN
            MOVE.L  #'????',(A1)+
            ADDQ    #4,D1           ; We added 4 new characters to our IOStringLoc 
            
            MOVE.L  #'    ',(A1)+       ; Add a spacer into our IOStringLoc
            ADDQ    #4,D1               ; We added 4 bytes, aka 4 spaces
            MOVE.W  #'  ',(A1)+         ; Add a spacer into our IOStringLoc
            ADDQ    #2,D1               ; We added 2 bytes, aka 2 spaces
        
            RTS
* Put variables and constants here




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
