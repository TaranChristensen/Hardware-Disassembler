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
            BEQ     ADDI        ; ADDI (Worked on)
            CMP.B   #$01,D6     
            BEQ     MOVEB       ; MOVE.B
            CMP.B   #$03,D6     
            BEQ     MOVEW       ; MOVE.W
            CMP.B   #$02,D6
            BEQ     MOVEL       ; MOVE.L
            CMP.B   #$04,D6
            BEQ     CNRJML      ; CLR or NOP or RTS or JSR or MOVEM or LEA (Implement)(Working on NOP,RTS,CLR)
            CMP.B   #$06,D6
            BEQ     Bcc         ; Bcc (BCC, BGT, BLE) (Implement)
            CMP.B   #$07,D6
            BEQ     MOVEQ       ; MOVEQ (Implement)
            CMP.B   #$08,D6
            BEQ     DIVU        ; DIVU (Implement)
            CMP.B   #$09,D6
            BEQ     SUB         ; SUB (Implement)
            CMP.B   #$0B,D6
            BEQ     CMP         ; CMP (Implement)
            CMP.B   #$0C,D6
            BEQ     MULSAND     ; MULS or AND opcodes (Implement AND)
            CMP.B   #$0D,D6
            BEQ     ADDADDA     ; ADD or ADDA (Implement)
            CMP.B   #$0E,D6 
            BEQ     ASLSRO      ; ASd (ASR) or LSd (LSL) or ROd (ROL) (Implement)
            BRA     UNKNOWN  
   
ADDI                                    ; Confirmed first left-most 4 bits of ADDI
            MOVE.L  D5,D6               ; Push D5 into D6
            ROR.L   #8,D6               ; Rotate left-most middle nybble to the right-most nybble
            ANDI.B  #$0F,D6             ; Isolate opcode nybble
            CMP.B   #$06,D6             ; If it matches ADDI's left-most middle nybble, branch
            BEQ     ADDI8               ; First 8 left-most bits of ADDI confirmed 
            BRA     UNKNOWN             ; else unknown                       
            
ADDI8                                   ; Confirmed first left-most 8 bits of ADDI

            MOVE.L  D5,D6              ; Push D5 into D6 (Copy OPcode over isolated nybble)
            LSR.L   #6,D6              ; Shift six bits to the right
            ANDI.L  #$0003,D6          ; Isolate the size bits
                       
            CMP.L   #$0000,D6          ; See if the size is '00'..
            BEQ     ADDIB              ; ..If so, it's ANDI.B
            CMP.L   #$0001,D6          ; See if the size is '01'..
            BEQ     ADDIW              ; ..If so, it's ANDI.W
            CMP.L   #$0002,D6          ; See if the size is '10'..
            BEQ     ADDIL              ; ..If so, it's ANDI.L
            
            BRA     UNKNOWN            ; If it isn't any, then it's Unknown
            
ADDIB       
            MOVE.L  #'ADDI',(A1)+
            MOVE.W  #'.B',(A1)+
            ADDQ    #6,D1              ; We added 6 new characters to our IOStringLoc 
            
            MOVE.L  #'    ',(A1)+      ; Add a spacer into our IOStringLoc
            ADDQ    #4,D1              ; We added 4 bytes, aka 4 spaces
            
            MOVE.L  D5,D6              ; Push D5 into D6
            ANDI.L  #$003F,D6          ; Isolate the Src EA bits 
            JSR EAGETSRCEA             ; Find and print the code stored in D6
            
            RTS
            
ADDIW       
            MOVE.L  #'ADDI',(A1)+
            MOVE.W  #'.W',(A1)+
            ADDQ    #6,D1              ; We added 6 new characters to our IOStringLoc 
            
            MOVE.L  #'    ',(A1)+      ; Add a spacer into our IOStringLoc
            ADDQ    #4,D1              ; We added 4 bytes, aka 4 spaces
            
            MOVE.L  D5,D6              ; Push D5 into D6
            ANDI.L  #$003F,D6          ; Isolate the Src EA bits 
            JSR EAGETSRCEA             ; Find and print the code stored in D6
            RTS
            
ADDIL      
            MOVE.L  #'ADDI',(A1)+
            MOVE.W  #'.L',(A1)+
            ADDQ    #6,D1              ; We added 6 new characters to our IOStringLoc 
            
            MOVE.L  #'    ',(A1)+      ; Add a spacer into our IOStringLoc
            ADDQ    #4,D1              ; We added 4 bytes, aka 4 spaces
            
            MOVE.L  D5,D6              ; Push D5 into D6
            ANDI.L  #$003F,D6          ; Isolate the Src EA bits 
            JSR EAGETSRCEA             ; Find and print the code stored in D6
                
            RTS 
              
MOVEB       MOVE.L  #'MOVE',(A1)+
            MOVE.W  #'.B',(A1)+
            ADDQ    #6,D1              ; We added 6 new characters to our IOStringLoc 
            
            BRA MOVEOP
            
MOVEW       MOVE.L  #'MOVE',(A1)+
            MOVE.W  #'.W',(A1)+
            ADDQ    #6,D1               ; We added 6 new characters to our IOStringLoc 
            
            BRA MOVEOP
            
MOVEL       MOVE.L  #'MOVE',(A1)+
            MOVE.W  #'.L',(A1)+
            ADDQ    #6,D1               ; We added 6 new characters to our IOStringLoc 
            
            BRA MOVEOP
            
MOVEOP      MOVE.L  #'    ',(A1)+       ; Add a spacer into our IOStringLoc
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
; Here we assume that the first left-most four bits equal 0100            
CNRJML      
            MOVE.L  D5,D6              ; Push D5 into D6 (Copy OPcode over isolated nybble)
            
            *NOP & RTS's machine code is uniquely hardcoded, check first
            CMP.L   #$4E71,D6          ; See if the OPcode matches NOP's hardcode
            BEQ     NOP
            CMP.L   #$4E75,D6          ; See if the OPcode matches RTS's hardcode
            BEQ     RTS
                                       ; CLR's middle most left nybble is unique (0010)
            ROR.L   #8,D6              ; Rotate our OpCode to right-most nybble
            ANDI.B  #$0F,D6            ; Isolate our opcode nybble
            CMP.B   #$02,D6            ; See if matches nybble
            BEQ     CLR               
<<<<<<< HEAD
            
            MOVE.L  D5,D6              ; Push D5 into D6
            LSR.L   #8,D6              ; Shift 8 bits to the right
            
            BTST    #$00,D6            ; See if our right-most bit is set
            BNE     LEA                ; If our bit is set, branch to LEA     
            
            LSR.L   #1,D6              ; Shift another bit
            BTST    #$00,D6            ; See if our right-most bit is set
            BNE     JSR                ; If this one is set, branch to JSR
            
            BRA     MOVEM
=======
                                       ; LEA's middle most left nybble is unique (xxx1)
            BTST    #1,D6              ; Check the right most bit's value
            BEQ     LEA                ; If equals 1, branch
               
                                       ; MOVEM's middle most left nybble is unique (1x00)
            ROR.L   #1,D6              ; first bit must be 0, rotate 1 bit 
            BTST    #0,D6               ; Compare again for 00 match
            BEQ     MOVEM                           
                                       
            MOVE.L  D5,D6              ; Push D5 into D6; JSR's middle nybbles are unique (1110 10xx)
            ROR.L   #6,D6              ; Rotate 6 bits
            ANDI.L  #$00FF,D6          ; Isolate the 8 known bits (00 1110 10)
            CMP.L   #$003A,D6          ; Compare
            BEQ     JSR                ; Branch
            
            BRA     UNKNOWN            ; If it doesnt any match, then it's Unknown
>>>>>>> origin/master


;  Here we assume the first left-most 8 bits have been confirmed: 0100 0010
CLR         *(Implement)

            RTS
            
;  Here we assume that all 16 bits have been confirmed 
NOP
            MOVE.W  #'NO',(A1)+
            MOVE.B  #'P',(A1)+
            ADDQ    #3,D1              ; We added 3 new characters to our IOStringLoc 
            
            MOVE.L  #'    ',(A1)+      ; Add a spacer into our IOStringLoc
            ADDQ    #4,D1              ; We added 4 bytes, aka 4 spaces        
            RTS

;  Here we assume that all 16 bits have been confirmed            
RTS         
            MOVE.W  #'RT',(A1)+
            MOVE.B  #'S',(A1)+
            ADDQ    #3,D1              ; We added 3 new characters to our IOStringLoc 
            
            MOVE.L  #'    ',(A1)+      ; Add a spacer into our IOStringLoc
            ADDQ    #4,D1              ; We added 4 bytes, aka 4 spaces        
            RTS
            
<<<<<<< HEAD
=======
;  Here we assume the first left-most 10 bits have been confirmed: 0100 1110 10 
>>>>>>> origin/master
JSR         *(Implement)
            MOVE.W  #'JS',(A1)+
            MOVE.B  #'R',(A1)+
            ADDQ    #3,D1              ; We added 3 new characters to our IOStringLoc 
            RTS
            
<<<<<<< HEAD
=======
;  Here we assume that these left-most have been confirmed, where - have not been confirmed: 0100 --00
>>>>>>> origin/master
MOVEM       *(Implement)
            MOVE.L  #'MOVE',(A1)+
            MOVE.W  #'M.',(A1)+
            ADDQ    #6,D1              ; We added 6 new characters to our IOStringLoc 
            
            MOVE.L  D5,D6              ; Copy our OpCode
            LSR.L   #7,D6              ; Rotate it 7 bits to the right
            BTST    #$00,D6            ; If our size bit is 0..
            BEQ     MOVEMW             ; .. Its a MOVEM of size W
            BRA     MOVEML             ; .. Otherwise it's of size L

MOVEMW      MOVE.B  #'W',(A1)+
            ADDQ    #1,D1              ; We've added another character into IOStringLoc
            BRA     MOVEMOP            ; MovemOp label, to skip MovemL label
            
MOVEML      MOVE.B  #'L',(A1)+
            ADDQ    #1,D1              ; We've added another character into IOStringLoc
            
MOVEMOP     MOVE.B  #' ',(A1)+         ; Add a spacer into our IOStringLoc
            MOVE.W  #'  ',(A1)+        ;
            MOVE.B  #' ',(A1)+         ;
            ADDQ    #4,D1              ; We added 4 bytes, aka 4 spaces 
            
            LSR.L   #4,D6              ; Shift our OpCode 4 bits to the left of Size (going to the right)
            BTST    #$00,D6            ; Check our Direction bit
            BEQ     MOVEMPRED          ; If it's 0, our direction is Pre Decrement (eg. Move TO the stack)
            BRA     MOVEMPOSTI         ; Otherwise, it's Post Increment (eg. Move FROM the stack)
            
MOVEMPRED               
            RTS
            
<<<<<<< HEAD
MOVEMPOSTI  MOVE.L  D5,D6              ; Copy our OpCode to D6
            ANDI.L  #$3F,D6            ; Isolate our EA src bits
            
            JSR EAGETSRCEA  
            
            MOVE.B  #',',(A1)+
            ADDQ    #1,D1
            
            ; This part is where we get the gross A0-A6/D0-D7 part
            JSR     EAMOVEMPOSTI
            
            RTS
            
=======
;  Here we assume that these left-most have been confirmed, where - have not been confirmed: 0100 ---1            
>>>>>>> origin/master
LEA         *(Implement)
            MOVE.W  #'LE',(A1)+
            MOVE.B  #'A',(A1)+
            ADDQ    #3,D1              ; We added 3 new characters to our IOStringLoc 
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
            ANDI.B  #$7,D6              ; Isolate the size bits
            CMP.B   #7,D6               ; See if the size is '111'..
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
AND         MOVE.L  #'AND.',(A1)+
            ADDQ    #4,D1               ; We added 4 new characters to our IOStringLoc
            
            CMP.B   #%0110,D6            ; See if D6 is size "%100" through "%110"..
            BEQ     ANDLEA              ; If it is, our OpCode is in the format of..
            CMP.B   #%101,D6            ; .. Dn ~ <EA> --> <EA>
            BEQ     ANDWEA
            CMP.B   #%100,D6
            BEQ     ANDBEA
            
            CMP.B   #%10,D6             ; See if D6 is size "%000" through "%010"..
            BEQ     ANDLDN              ; If it is, our OpCode is in the format of..
            CMP.B   #%01,D6             ; .. <EA> ~ Dn --> Dn
            BEQ     ANDWDN
            BRA     ANDBDN              ; == 000 at this point
            
ANDLEA      MOVE.B  #'L',(A1)+
            ADDQ    #1,D1               ; We added 1 byte into D1
            BRA     ANDEA
            
ANDWEA      MOVE.B  #'W',(A1)+
            ADDQ    #1,D1               ; We added 1 byte into D1
            BRA     ANDEA

ANDBEA      MOVE.B  #'B',(A1)+
            ADDQ    #1,D1               ; We added 1 byte into D1
            BRA     ANDEA

ANDEA       MOVE.B  #$09,(A1)+          ; Add a spacer into our IOStringLoc
            ADDQ    #1,D1               ; We added 4 bytes, aka 4 spaces
            
            MOVE.L  D5,D6
            LSR.L   #8,D6               ; Shift our OpCode a total of 9 bits to the right
            LSR.L   #1,D6               ; 
            ANDI.L  #$07,D6             ; Isolate our data register
            
            JSR EADN
            
            MOVE.B  #',',(A1)+
            ADDQ    #1,D1
            
            MOVE.L  D5,D6               ; Copy our OpCode again
            ANDI.L  #$3F,D6             ; Isolate our EA bits
            
            JSR EAGETSRCEA  
            
            RTS
            
ANDLDN      MOVE.B  #'L',(A1)+
            ADDQ    #1,D1               ; We added 1 byte into D1
            BRA ANDDN
            
ANDWDN      MOVE.B  #'L',(A1)+
            ADDQ    #1,D1               ; We added 1 byte into D1
            BRA ANDDN

ANDBDN      MOVE.B  #'L',(A1)+
            ADDQ    #1,D1               ; We added 1 byte into D1
            BRA ANDDN  

ANDDN
            MOVE.B  #$09,(A1)+          ; Add a spacer into our IOStringLoc
            ADDQ    #1,D1               ; We added 4 bytes, aka 4 spaces
            
            MOVE.L  D5,D6               ; Copy our OpCode again
            ANDI.L  #$3F,D6             ; Isolate our EA bits
            
            JSR EAGETSRCEA              
            
            MOVE.B  #',',(A1)+
            ADDQ    #1,D1
            
            MOVE.L  D5,D6
            LSR.L   #8,D6               ; Shift our OpCode a total of 9 bits to the right
            LSR.L   #1,D6               ; 
            ANDI.L  #$07,D6             ; Isolate our data register
            
            JSR EADN
            
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











<<<<<<< HEAD
=======

>>>>>>> origin/master
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
