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
            CMP.B   #$00,D6
            BEQ     ANDI        ; ANDI
            CMP.B   #$01,D6     
            BEQ     MOVEB       ; MOVE.B
            CMP.B   #$03,D6     
            BEQ     MOVEW       ; MOVE.W
            CMP.B   #$02,D6
            BEQ     MOVEL       ; MOVE.L
            CMP.B   #$04,D6
            BEQ     CNRJML      ; CLR or NOP or RTS or JSR or MOVEM or LEA
            CMP.B   #$06,D6
            BEQ     Bcc         ; Bcc (BCC, BGT, BLE)
            CMP.B   #$07,D6
            BEQ     MOVEQ       ; MOVEQ
            CMP.B   #$08,D6
            BEQ     DIVU        ; DIVU
            CMP.B   #$09,D6
            BEQ     SUB         ; SUB
            CMP.B   #$0B,D6
            BEQ     CMP         ; CMP
            CMP.B   #$0C,D6
            BEQ     MULSAND     ; MULS or AND opcodes
            CMP.B   #$0D,D6
            BEQ     ADDADDA     ; ADD or ADDA
            CMP.B   #$0E,D6 
            BEQ     ASLSRO      ; ASd (ASR) or LSd (LSL) or ROd (ROL)
            BRA     UNKNOWN  
   
ANDI        *(Implement)
                 
            RTS            
MOVEB
            MOVE.L  #'MOVE',(A1)+
            MOVE.W  #'.B',(A1)+
            ADDQ    #6,D1              ; We added 6 new characters to our IOStringLoc 
            
            MOVE.L  #'    ',(A1)+      ; Add a spacer into our IOStringLoc
            ADDQ    #4,D1              ; We added 4 bytes, aka 4 spaces
            
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
            ADDQ    #6,D1               ; We added 6 new characters to our IOStringLoc 
            
            MOVE.L  #'    ',(A1)+       ; Add a spacer into our IOStringLoc
            ADDQ    #4,D1               ; We added 4 bytes, aka 4 spaces
            
            MOVE.L  D5,D6               ; Push D5 into D6
            ANDI.L  #$003F,D6           ; Isolate the Src EA bits 
            JSR EAGETSRCEA              ; Find and print the code stored in D6
            
            MOVE.B  #',',(A1)+
            ADDQ    #1,D1
            
            MOVE.L  D5,D6               ; Push D5 into D6
            LSR.L   #6,D6               ; Shift six bits to the right
            ANDI.L  #$003F,D6           ; Isolate the Dst EA bits
            JSR EAGETDSTEA
            
            RTS
MOVEL
            MOVE.L  #'MOVE',(A1)+
            MOVE.W  #'.L',(A1)+
            ADDQ    #6,D1               ; We added 6 new characters to our IOStringLoc 
            
            MOVE.L  #'    ',(A1)+       ; Add a spacer into our IOStringLoc
            ADDQ    #4,D1               ; We added 4 bytes, aka 4 spaces
            
            MOVE.L  D5,D6               ; Push D5 into D6
            ANDI.L  #$003F,D6           ; Isolate the Src EA bits 
            JSR EAGETSRCEA              ; Find and print the code stored in D6
            
            MOVE.B  #',',(A1)+
            ADDQ    #1,D1
            
            MOVE.L  D5,D6               ; Push D5 into D6
            LSR.L   #6,D6               ; Shift six bits to the right
            ANDI.L  #$003F,D6           ; Isolate the Dst EA bits
            JSR EAGETDSTEA
            
            RTS
            
; This label determines if the code is either CLR or NOP or RTS or JSR or MOVEM or LEA            
CNRJML      *(Implement)
                 
            RTS
            
Bcc         *(Implement)
                 
            RTS
            
MOVEQ       *(Implement)
                 
            RTS 
            
DIVU        *(Implement)
                 
            RTS
            
SUB         *(Implement)
                 
            RTS
  
CMP         *(Implement)
                 
            RTS         
       
; This label determines if the code is either MULS or AND, by looking at it's size bits     
MULSAND     MOVE.L  D5,D6               ; Copy D5 into D6
            LSR.L   #6,D6               ; Shift the size bits to the far right
            ANDI.B  #$3,D6              ; Isolate the size bits
            CMP.B   #3,D6               ; See if the size is '11'..
            BEQ.S   MULS                ; ..If so, it's a MULS opcode
            BRA     AND                 ; Otherwise, it's an AND code
        
MULS        MOVE.L  #'MULS',(A1)+
            ADDQ    #4,D1               ; We added 4 new characters to our IOStringLoc
            
            MOVE.L  #'    ',(A1)+       ; Add a spacer into our IOStringLoc
            ADDQ    #4,D1               ; We added 4 bytes, aka 4 spaces
            
            MOVE.L  D5,D6               ; Copy D5 into D6
            ANDI.L  #$003F,D6           ; Isolate the Src EA bits
            JSR EAGETSRCEA
            
            MOVE.B  #',',(A1)+
            ADDQ    #1,D1
            
            MOVE.L  D5,D6               ; Copy D5 into D6
            ROR.L   #8,D6               ; Rotate 9 bits to the right (Dn Dst bits)
            ROR.L   #1,D6               ; Rotate 9 bits to the right (Dn Dst bits)
            ANDI.L  #$0003,D6           ; Isolate the Dn Destination bits
            JMP EADN
            
            RTS
            
; At this point, we know D6 is the size of our opcode
AND
                 
            RTS

; This label determines if the code is either ADD or ADDA           
ADDADDA     *(Implement)
                 
            RTS

; This label determines if the code is either ASd (ASR) or LSd (LSL) or ROd (ROL) 
ASLSRO      *(Implement)
                 
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
