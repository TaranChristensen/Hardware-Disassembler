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
            BEQ     ADDI        ; ADDI 
            CMP.B   #$01,D6     
            BEQ     MOVE        ; MOVE.B
            CMP.B   #$03,D6     
            BEQ     MOVE        ; MOVE.W
            CMP.B   #$02,D6
            BEQ     MOVE        ; MOVE.L
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
            
;  Here we assume the first left-most 4 bits have been confirmed: 0000
ADDI        MOVE.L  D5,D6               ; Push D5 into D6
            ROR.L   #8,D6               ; Rotate left-most middle nybble to the right-most nybble
            ANDI.B  #$0F,D6             ; Isolate opcode nybble
            CMP.B   #$06,D6             ; If it matches ADDI's left-most middle nybble, branch
            BEQ     ADDI8               ; First 8 left-most bits of ADDI confirmed 
            BRA     UNKNOWN             ; else unknown                       

;  Here we assume the first left-most 8 bits have been confirmed: 0000 0110            
ADDI8                                  ; Two consecutive tests for illegal Src EA Modes
            MOVE.L  D5,D6              ; Push D5 into D6 
            ANDI.L  #$003F,D6          ; Isolate the Src EA bits
            CMP.L   #$003C,D6          ; Compare with illegal EA mode #<data>
            BEQ     UNKNOWN
            
            ROR.L   #3,D6              ; Roll 3 bits right
            ANDI.L  #$0007,D6          ; Isolate the 3 Src (Mode) bits
            CMP.L   #$0001, D6         ; Compare with illegal mode An
            BEQ     UNKNOWN
            *--------------
                                
            MOVE.L  D5,D6              ; Push D5 into D6 
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
            BRA     ADDIOP
            
ADDIW       
            MOVE.L  #'ADDI',(A1)+
            MOVE.W  #'.W',(A1)+
            ADDQ    #6,D1              ; We added 6 new characters to our IOStringLoc 
            BRA     ADDIOP
            
ADDIL      
            MOVE.L  #'ADDI',(A1)+
            MOVE.W  #'.L',(A1)+
            ADDQ    #6,D1              ; We added 6 new characters to our IOStringLoc 
            BRA     ADDIOP

ADDIOP      MOVE.L  #'    ',(A1)+      ; Add a spacer into our IOStringLoc
            ADDQ    #4,D1              ; We added 4 bytes, aka 4 spaces
            
            MOVE.L  D5,D6              ; Push D5 into D6
            ANDI.L  #$003F,D6          ; Isolate the Src EA bits 
            JSR EAGETSRCEA             ; Find and print the code stored in D6 
            RTS
              
;  Here we assume the first left-most 4 bits are: 0001, 0011, or 0010
MOVE                                   ; Two consecutive tests for illegal Dst EA Modes
            MOVE.L  D5,D6              ; Push D5 into D6
            ROR.L   #6,D6              ; Roll 6 bits right 
            ANDI.L  #$003F,D6          ; Isolate the Dst EA bits
            CMP.L   #$0027, D6         ; Compare with illegal EA mode #<data>
            BEQ     UNKNOWN
            
            ANDI.L  #$0007,D6          ; Isolate the 3 Dst (Mode) bits
            CMP.L   #$0001, D6         ; Compare with illegal mode An
            BEQ     UNKNOWN
            *----------------                   
            MOVE.L  D5,D6              ; Push D5 into D6 
            LSR.L   #6,D6              ; Shift six bits to the right
            LSR.L   #6,D6              ; Shift six bits to the right
            ANDI.L  #$0003,D6          ; Isolate the size bits
                       
            CMP.L   #$0001,D6          ; See if the size is '01'..
            BEQ     MOVEB              ; ..If so, it's MOVE.B
            CMP.L   #$0003,D6          ; See if the size is '11'..
            BEQ     MOVEW              ; ..If so, it's MOVE.W
            CMP.L   #$0002,D6          ; See if the size is '10'..
            BEQ     MOVEL              ; ..If so, it's MOVE.L
            
            BRA     UNKNOWN            ; If it isn't any, then it's Unknown
            


MOVEB       MOVE.L  #'MOVE',(A1)+
            MOVE.W  #'.B',(A1)+
            ADDQ    #6,D1              ; We added 6 new characters to our IOStringLoc 
            
            MOVE.L  #1,D0               ; Put 1 into D0 to indicate it's a bytesize
            
            BRA MOVEOP
            
MOVEW       MOVE.L  #'MOVE',(A1)+
            MOVE.W  #'.W',(A1)+
            ADDQ    #6,D1               ; We added 6 new characters to our IOStringLoc 
            
            MOVE.L  #2,D0               ; Put 2 into D0 to indicate it's a wordsize
            
            BRA MOVEOP
            
MOVEL       MOVE.L  #'MOVE',(A1)+
            MOVE.W  #'.L',(A1)+
            ADDQ    #6,D1               ; We added 6 new characters to our IOStringLoc 
            
            MOVE.L  #3,D0               ; Put 3 into D0 to indicate it's a longsize
            
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
            
*--------------------------------------------------------------------------------------            
                                       ; LEA's left-most 10 bits are 0100 --- (111)
            MOVE.L  D5,D6              ; Push D5 into D6
            LSR.L   #6,D6              ; Shift 6 bits to the right 
            ANDI.L  #$0007,D6          ; Isolate 3 right-most bits
            CMP.L   #$0007,D6          ; See if matches 111
            BEQ     LEA                ; If equals, branch to LEA     
            
                                       ; JSR's left-most 10 bits are 0100 (111 010)
            MOVE.L  D5,D6              ; Push D5 into D6
            LSR.L   #6,D6              ; Shift 6 bits to the right
            ANDI.L  #$003F,D6          ; Isolate 6 right-most bit
            CMP.L   #$003A,D6          ; See if matches 11 1010
            BEQ     JSR                ; If equals, branch JSR
               
                                       ; MOVEM's left-most 9 bits are 0100 1- (001)
            MOVE.L  D5,D6              ; Push D5 into D6
            LSR.L   #7,D6              ; Shift 7 bits to the right
            ANDI.L  #$0007,D6          ; Isolate 3 right-most bit
            CMP.L   #$0001,D6          ; See if matches 001
            BEQ     MOVEM              ; If equals, branch MOVEM
      
            BRA     UNKNOWN            ; If it doesnt any match, then it's Unknown

******************************************************************************************
*            MOVE.L  D5,D6              ; Push D5 into D6
*            LSR.L   #8,D6              ; Shift 8 bits to the right
*            
*            BTST    #$00,D6            ; See if our right-most bit is set
*            BNE     LEA                ; If our bit is set, branch to LEA     
*            
*            LSR.L   #1,D6              ; Shift another bit
*            BTST    #$00,D6            ; See if our right-most bit is set
*            BNE     JSR                ; If this one is set, branch to JSR
*            
**            BRA MOVEM
**                                       ; LEA's middle most left nybble is unique (---1)
**            BTST    #0,D6              ; Check the right most bit's value
**            BNE     LEA                ; If equals 1, branch
*               
*                                       ; MOVEM's middle most left nybble is unique (1-00)
*            ROR.L   #2,D6              ; first bit must be 0, rotate 1 bit 
*            BTST    #0,D6               ; Compare again for 00 match
*            BNE     MOVEM                           
*                                       
**            MOVE.L  D5,D6              ; Push D5 into D6; JSR's middle nybbles are unique (1110 10--)
**            ROR.L   #6,D6              ; Rotate 6 bits
**            ANDI.L  #$00FF,D6          ; Isolate the 8 known bits (00 1110 10)
**            CMP.L   #$003A,D6          ; Compare
**            BEQ     JSR                ; Branch
**            
*            BRA     UNKNOWN            ; If it doesnt any match, then it's Unknown
*-----------------------------------------------------------------------------------------

;  Here we assume the first left-most 8 bits have been confirmed: 0100 0010
CLR                                    ; Two consecutive tests for illegal Src EA Modes
            MOVE.L  D5,D6              ; Push D5 into D6 
            ANDI.L  #$003F,D6          ; Isolate the Src EA bits
            CMP.L   #$003C, D6         ; Compare with illegal EA mode #<data>
            BEQ     UNKNOWN
            
            ROR.L   #3,D6              ; Roll 3 bits right
            ANDI.L  #$0007,D6          ; Isolate the 3 Src (Mode) bits
            CMP.L   #$0001,D6          ; Compare with illegal mode An
            BEQ     UNKNOWN
            *----------------
            
            MOVE.L  D5,D6              ; Push D5 into D6
            LSR.L   #6,D6              ; Shift six bits to the right
            ANDI.L  #$0003,D6          ; Isolate the two size bits
                       
            CMP.L   #$0000,D6          ; See if the size is '00'..
            BEQ     CLRB               ; ..If so, it's CLR.B
            CMP.L   #$0001,D6          ; See if the size is '01'..
            BEQ     CLRW               ; ..If so, it's CLR.W
            CMP.L   #$0002,D6          ; See if the size is '10'..
            BEQ     CLRL               ; ..If so, it's CLR.L
            
            BRA     UNKNOWN            ; If it isn't any, then it's Unknown
            
CLRB        MOVE.W  #'CL',(A1)+
            MOVE.B  #'R',(A1)+
            MOVE.B  #'.',(A1)+
            MOVE.B  #'B',(A1)+
            ADDQ    #5,D1              ; We added 5 new characters to our IOStringLoc 
            BRA     CLROP
            
CLRW        MOVE.W  #'CL',(A1)+
            MOVE.B  #'R',(A1)+
            MOVE.B  #'.',(A1)+
            MOVE.B  #'W',(A1)+
            ADDQ    #5,D1              ; We added 5 new characters to our IOStringLoc 
            BRA     CLROP

CLRL        MOVE.W  #'CL',(A1)+
            MOVE.B  #'R',(A1)+
            MOVE.B  #'.',(A1)+
            MOVE.B  #'L',(A1)+
            ADDQ    #5,D1              ; We added 5 new characters to our IOStringLoc 
            BRA     CLROP
            
CLROP       MOVE.B  #' ',(A1)+
            MOVE.W  #'  ',(A1)+      ; Add a spacer into our IOStringLoc
            MOVE.W  #'  ',(A1)+
            ADDQ    #5,D1              ; We added 4 bytes, aka 4 spaces
            
            MOVE.L  D5,D6              ; Push D5 into D6
            ANDI.L  #$003F,D6          ; Isolate the Src EA bits 
            JSR EAGETSRCEA             ; Find and print the code stored in D6

            RTS
            
;  Here we assume that all 16 bits have been confirmed 
NOP
            MOVE.W  #'NO',(A1)+
            MOVE.B  #'P',(A1)+
            ADDQ    #3,D1              ; We added 3 new characters to our IOStringLoc 
            
            MOVE.B  #' ',(A1)+       ; Add a spacer into our IOStringLoc
            MOVE.W  #'  ',(A1)+      ; Add a spacer into our IOStringLoc
            MOVE.W  #'  ',(A1)+       ; Add a spacer into our IOStringLoc
            ADDQ    #5,D1              ; We added 4 bytes, aka 4 spaces        
            RTS

;  Here we assume that all 16 bits have been confirmed            
RTS         
            MOVE.W  #'RT',(A1)+
            MOVE.B  #'S',(A1)+
            ADDQ    #3,D1              ; We added 3 new characters to our IOStringLoc 
            
            MOVE.B  #' ',(A1)+       ; Add a spacer into our IOStringLoc
            MOVE.W  #'  ',(A1)+      ; Add a spacer into our IOStringLoc
            MOVE.W  #'  ',(A1)+       ; Add a spacer into our IOStringLoc
            ADDQ    #5,D1              ; We added 4 bytes, aka 4 spaces        
            RTS
            

;  Here we assume the first left-most 10 bits have been confirmed: 0100 1110 10 
JSR                                    ; Five consecutive tests for illegal Src EA Modes
            MOVE.L  D5,D6              ; Push D5 into D6 
            ANDI.L  #$003F,D6          ; Isolate the Src EA bits
            CMP.L   #$003C, D6         ; Compare with illegal EA mode #<data>
            BEQ     UNKNOWN
            
            ROR.L   #3,D6              ; Roll 3 bits right
            ANDI.L  #$0007,D6          ; Isolate the 3 Src (Mode) bits
            CMP.L   #$0000,D6          ; Compare with illegal mode Dn
            BEQ     UNKNOWN
            CMP.L   #$0001,D6          ; Compare with illegal mode An
            BEQ     UNKNOWN
            CMP.L   #$0003,D6          ; Compare with illegal mode (An)+
            BEQ     UNKNOWN
            CMP.L   #$0004,D6          ; Compare with illegal mode -(An)
            BEQ     UNKNOWN
            *----------------

            MOVE.W  #'JS',(A1)+
            MOVE.B  #'R',(A1)+
            ADDQ    #3,D1              ; We added 3 new characters to our IOStringLoc 
            
            MOVE.B  #' ',(A1)+
            MOVE.W  #'  ',(A1)+      ; Add a spacer into our IOStringLoc
            MOVE.L  #'    ',(A1)+      ; Add a spacer into our IOStringLoc
            ADDQ    #7,D1              ; We added 4 bytes, aka 4 spaces
            MOVE.L  D5,D6              ; Push D5 into D6
            
            ANDI.L  #$003F,D6          ; Isolate the Src EA bits 
            JSR EAGETSRCEA             ; Find and print the code stored in D6 
            RTS
            

;  Here we assume that these left-most bits have been confirmed, where - have not been confirmed: 0100 -- 001
MOVEM                                  ; Four consecutive tests for illegal Src EA Modes
            MOVE.L  D5,D6              ; Push D5 into D6 
            ANDI.L  #$003F,D6          ; Isolate the Src EA bits
            CMP.L   #$003C, D6         ; Compare with illegal EA mode #<data>
            BEQ     UNKNOWN
            
            ROR.L   #3,D6              ; Roll 3 bits right
            ANDI.L  #$0007,D6          ; Isolate the 3 Src (Mode) bits
            CMP.L   #$0000,D6          ; Compare with illegal mode Dn
            BEQ     UNKNOWN
            CMP.L   #$0001,D6          ; Compare with illegal mode An
            BEQ     UNKNOWN
            CMP.L   #$0003,D6          ; Compare with illegal mode (An)+
            BEQ     UNKNOWN
            *----------------

            MOVE.L  #'MOVE',(A1)+
            MOVE.W  #'M.',(A1)+
            ADDQ    #6,D1              ; We added 6 new characters to our IOStringLoc 
            
            MOVE.L  D5,D6              ; Copy our OpCode
            LSR.L   #6,D6              ; Shift it 6 bits to the right
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
            ADDQ    #3,D1              ; We added 4 bytes, aka 4 spaces 
            
            LSR.L   #4,D6              ; Shift our OpCode 4 bits to the left of Size (going to the right)
            BTST    #$00,D6            ; Check our Direction bit
            BEQ     MOVEMPRED          ; If it's 0, our direction is Pre Decrement (eg. Move TO the stack)
            BRA     MOVEMPOSTI         ; Otherwise, it's Post Increment (eg. Move FROM the stack)
            
MOVEMPRED   ; This part is where we get the gross A0-A6/D0-D7 part
            JSR     EAMOVEMPRED  
            
            MOVE.B  #',',(A1)+
            ADDQ    #1,D1
            
            MOVE.L  D5,D6              ; Copy our OpCode to D6
            ANDI.L  #$3F,D6            ; Isolate our EA src bits
            
            JSR EAGETSRCEA  
          
            RTS

MOVEMPOSTI  MOVE.L  D5,D6              ; Copy our OpCode to D6
            ANDI.L  #$3F,D6            ; Isolate our EA src bits
            
            JSR EAGETSRCEA  
            
            MOVE.B  #',',(A1)+
            ADDQ    #1,D1
            
            ; This part is where we get the gross A0-A6/D0-D7 part
            JSR     EAMOVEMPOSTI
            
            RTS
            

;  Here we assume that these left-most bits have been confirmed, where - have not been confirmed: 0100 --- 111            
LEA                                    ; Five consecutive tests for illegal Src EA Modes
            MOVE.L  D5,D6              ; Push D5 into D6 
            ANDI.L  #$003F,D6          ; Isolate the Src EA bits
            CMP.L   #$003C, D6         ; Compare with illegal EA mode #<data>
            BEQ     UNKNOWN
            
            ROR.L   #3,D6              ; Roll 3 bits right
            ANDI.L  #$0007,D6          ; Isolate the 3 Src (Mode) bits
            CMP.L   #$0000,D6          ; Compare with illegal mode Dn
            BEQ     UNKNOWN
            CMP.L   #$0001,D6          ; Compare with illegal mode An
            BEQ     UNKNOWN
            CMP.L   #$0003,D6          ; Compare with illegal mode (An)+
            BEQ     UNKNOWN
            CMP.L   #$0004,D6          ; Compare with illegal mode -(An)
            BEQ     UNKNOWN
            *----------------
            
            MOVE.W  #'LE',(A1)+
            MOVE.B  #'A',(A1)+
            ADDQ    #3,D1               ; We added 3 new characters to our IOStringLoc 
             
            MOVE.B  #' ',(A1)+          ; Added an extra space here, due to only 3 character OpCode
            MOVE.L  #'    ',(A1)+       ; Add a spacer into our IOStringLoc
            MOVE.W  #'  ',(A1)+ 
            ADDQ    #7,D1               ; We added 4 bytes, aka 4 spaces
            
            MOVE.L  D5,D6               ; Copy D5 into D6
            ANDI.L  #$003F,D6           ; Isolate the Src EA bits
            JSR EAGETSRCEA
            
            MOVE.B  #',',(A1)+
            ADDQ    #1,D1
            
            MOVE.L  D5,D6               ; Copy D5 into D6
            ROR.L   #8,D6               ; Rotate 9 bits to the right (An Dst bits)
            ROR.L   #1,D6               ; 
            ANDI.L  #$0005,D6           ; Isolate the An Destination bits
            JMP EAAN
            RTS      
            
Bcc         MOVE.L  D5,D6               ; Copy our OpCode into D6
            ROL.W   #8,D6               ; Rotate our condition bit into place
            ANDI.B  #$0F,D6             ; Isolate the right-most nybble (condition)
            
            CMP.B   #%0100,D6           ; See if our Condition is '0100'
            BEQ     BCCOP               ; If it is, we have a BCC operation
            CMP.B   #%1110,D6           ; See if our Condition is '1110'
            BEQ     BGTOP               ; If it is, we have a BGT operation
            CMP.B   #%1111,D6           ; See if our Condition is '1111'
            BEQ     BLEOP               ; If it is, we have a BLE operation
            
            BRA     UNKNOWN             ; Otherwise we don't know what kind of operation we have
            
BCCOP       MOVE.W  #'BC',(A1)+
            MOVE.B  #'C',(A1)+
            ADDQ    #3,D1               ; We've added three characters into our IOStringLoc
            BRA     BccSIZE             ; Branch to find our Bcc Op's Size
            
BGTOP       MOVE.W  #'BG',(A1)+
            MOVE.B  #'T',(A1)+
            ADDQ    #3,D1               ; We've added three characters into our IOStringLoc
            BRA     BccSIZE             ; Branch to find our Bcc Op's Size
            
BLEOP       MOVE.W  #'BL',(A1)+
            MOVE.B  #'E',(A1)+
            ADDQ    #3,D1               ; We've added three characters into our IOStringLoc
            BRA     BccSIZE             ; Branch to find our Bcc Op's Size

BccSIZE     ; Find Displacement value
            ; Branch to proper displacement value label
            ; Store the value of A2 into D7
            ; Get our total displacement into D6
            ; Print the new address as D7 +/- D6
            
            MOVE.B  #' ',(A1)+       ; Add a spacer into our IOStringLoc
            MOVE.W  #'  ',(A1)+      ; Add a spacer into our IOStringLoc
            MOVE.W  #'  ',(A1)+       ; Add a spacer into our IOStringLoc
            MOVE.W  #'  ',(A1)+       ; Add a spacer into our IOStringLoc
            ADDQ    #7,D1              ; We added 4 bytes, aka 4 spaces   
            
            MOVE.B  #'$',(A1)+
            ADDQ    #1,D1
            
            MOVE.L  D5,D6
            ANDI.L  #$FF,D6             ; Isolate our Size bits
            CMP.B   #$00,D6             ; If it's equal to $00..
            BEQ     Bcc16               ; .. It has a 16 bit displacement
            ANDI.L  #$FF,D6             ; If it's equal to $FF..
            BEQ     Bcc32               ; .. It has a 32 bit displacement
            ; Otherwise, it's an 8 bit displacement
            
            MOVE.L  A2,D7               ; Get our initial address
            TST.B   D6                  ; Is D6 negative?
            BMI     Bcc8NEG             ; Branch to Negative
            
            ADD.W   D6,D7               ; Otherwise, Add what we have to D7
            
            MOVE.L  D7,D6               ; Push our expected address into D6 to print
            CLR     D4                  ; Clear counter
            JSR     EAHEXtoASCII        ; Print
            
            RTS 
            
Bcc8NEG     NEG.B   D6 
            SUB.W   D6,D7
            
            MOVE.L  D7,D6               ; Push our expected address into D6 to print
            CLR     D4                  ; Clear counter
            JSR     EAHEXtoASCII        ; Print
            
            RTS  
         
Bcc16       MOVE.L  A2,D7               ; Get our initial address
            MOVE.W  (A2)+,D6
            TST.W   D6                  ; Is D6 negative?
            BMI     Bcc16NEG             ; Branch to Negative
            
            ADD.L   D6,D7               ; Otherwise, Add what we have to D7
            
            MOVE.L  D7,D6               ; Push our expected address into D6 to print
            CLR     D4                  ; Clear counter
            JSR     EAHEXtoASCII        ; Print
            
            RTS 
Bcc16NEG    NEG.W   D6 
            SUB.L   D6,D7
            
            MOVE.L  D7,D6               ; Push our expected address into D6 to print
            CLR     D4                  ; Clear counter
            JSR     EAHEXtoASCII        ; Print
            
            RTS  


Bcc32       MOVE.L  A2,D7               ; Get our initial address
            MOVE.L  (A2)+,D6
            TST.L   D6                  ; Is D6 negative?
            BMI     Bcc16NEG            ; Branch to Negative
            
            ADD.L   D6,D7               ; Otherwise, Add what we have to D7
            
            MOVE.L  D7,D6               ; Push our expected address into D6 to print
            CLR     D4                  ; Clear counter
            SWAP    D6
            JSR     EAHEXtoASCII        ; Print
            CLR     D4                  ; Clear counter
            SWAP    D6
            JSR     EAHEXtoASCII        ; Print
            
            RTS 

Bcc32NEG    NEG.L   D6 
            SUB.L   D6,D7
            
            MOVE.L  D7,D6               ; Push our expected address into D6 to print
            CLR     D4                  ; Clear counter
            SWAP    D6
            JSR     EAHEXtoASCII        ; Print
            CLR     D4                  ; Clear counter
            SWAP    D6
            JSR     EAHEXtoASCII        ; Print
    
            RTS           
MOVEQ
            MOVE.L  #'MOVE',(A1)+
            MOVE.B  #'Q',(A1)+
            ADDQ    #5,D1               ; We added 4 new characters to our IOStringLoc
            
            MOVE.B  #' ',(A1)+
            MOVE.W  #'  ',(A1)+         ; Add a spacer into our IOStringLoc
            MOVE.W  #'  ',(A1)+
            ADDQ    #4,D1               ; We added 4 bytes, aka 4 spaces
            
            MOVE.L  D5,D6               ; Copy D5 into D6
            ANDI.L  #$00FF,D6           ; Isolate the Src EA bits
            
            MOVE.B  #'#',(A1)+
            MOVE.B  #'$',(A1)+
            ADDQ    #1,D1               ; We added 4 bytes, aka 4 spaces
            MOVE.B  #2,D4               ; "Start" at 2 characters
            ROL.L   #$8,D6
            JSR     EAHEXtoASCII
            
            MOVE.B  #',',(A1)+
            ADDQ    #1,D1
            
            MOVE.L  D5,D6               ; Copy D5 into D6
            ROR.L   #8,D6               ; Rotate 9 bits to the right (Dn Dst bits)
            ROR.L   #1,D6               ; Rotate 9 bits to the right (Dn Dst bits)
            ANDI.L  #$0007,D6           ; Isolate the Dn Destination bits
            JMP EADN
            
            RTS 
            
DIVU 
                                       ; One test for illegal Src EA Mode
            MOVE.L  D5,D6              ; Push D5 into D6   
            ROR.L   #3,D6              ; Roll 3 bits right
            ANDI.L  #$0007,D6          ; Isolate the 3 Src (Mode) bits
            CMP.L   #$0001,D6          ; Compare with illegal mode An
            BEQ     UNKNOWN
            *----------------       
            MOVE.L  #'DIVU',(A1)+
            ADDQ    #4,D1               ; We added 4 new characters to our IOStringLoc
            
            MOVE.L  #'    ',(A1)+       ; Add a spacer into our IOStringLoc
            MOVE.W  #'  ',(A1)+         ; Add a spacer into our IOStringLoc
            ADDQ    #6,D1               ; We added 4 bytes, aka 4 spaces
            
            MOVE.L  D5,D6               ; Copy D5 into D6
            ANDI.L  #$003F,D6           ; Isolate the Src EA bits
            MOVE.L  #2,D0               ; Put 2 into D0 to indicate it's a wordsize
            JSR EAGETSRCEA
            
            MOVE.B  #',',(A1)+
            ADDQ    #1,D1
            
            MOVE.L  D5,D6               ; Copy D5 into D6
            ROR.L   #8,D6               ; Rotate 9 bits to the right (Dn Dst bits)
            ROR.L   #1,D6               ; Rotate 9 bits to the right (Dn Dst bits)
            ANDI.L  #$0007,D6           ; Isolate the Dn Destination bits
            JMP EADN
            
            RTS

            
SUB         MOVE.L  D5,D6               ; Copy D5 into D6
            LSR.L   #6,D6               ; Shift the size bits to the far right
            ANDI.B  #$4,D6              ; Isolate the size bits    
                 
            CMP.B   #%0100,D6           ; See if D6 is size "%100" through "%110"..
            BEQ     SUBEA              ; If it is, our OpCode is in the format of..
            
            MOVE.L  D5,D6               ; Copy D5 into D6
            LSR.L   #6,D6               ; Shift the size bits to the far right
            ANDI.B  #$7,D6              ; Isolate the size bits    
            
            CMP.B   #%10,D6             ; See if D6 is size "%000" through "%010"..
            BEQ     SUBLDN              ; If it is, our OpCode is in the format of..
            CMP.B   #%01,D6             ; .. <EA> ~ Dn --> Dn
            BEQ     SUBWDN
            CMP.B   #%00,D6
            BEQ     SUBBDN              ; == 000 at this point
            
            BRA     UNKNOWN
            
SUBEA       MOVE.L  D5,D6               ; Copy D5 into D6
            AND.B   #$3F,D6             ; Isolate our EA Src bits
            CMP.B   #$39,D6             ; Check for Illegal #$ mode
            BEQ     UNKNOWN
            AND.B   #$38,D6             ; Isolate our EA Src Mode bits
            CMP.B   #$08,D6             ; Check for Illegal mode An
            BEQ     UNKNOWN
            CMP.B   #$00,D6             ; Check for Illegal mode Dn 
            BEQ     UNKNOWN
            
            MOVE.L  D5,D6               ; Copy D5 into D6
            LSR.L   #6,D6               ; Shift the size bits to the far right
            ANDI.B  #$7,D6              ; Isolate the size bits    
                 
            CMP.B   #%0110,D6           ; See if D6 is size "%100" through "%110"..
            BEQ     SUBLEA              ; If it is, our OpCode is in the format of..
            CMP.B   #%101,D6            ; .. Dn ~ <EA> --> <EA>
            BEQ     SUBWEA
            CMP.B   #%100,D6
            BEQ     SUBBEA
            
            BRA     UNKNOWN

SUBLEA      MOVE.L  #'SUB.',(A1)+
            ADDQ    #4,D1               ; We added 4 new characters to our IOStringLoc
            MOVE.B  #'L',(A1)+
            ADDQ    #1,D1               ; We added 1 byte into D1
            BRA     ANDEA
            
SUBWEA      MOVE.L  #'SUB.',(A1)+
            ADDQ    #4,D1               ; We added 4 new characters to our IOStringLoc
            MOVE.B  #'W',(A1)+
            ADDQ    #1,D1               ; We added 1 byte into D1
            BRA     ANDEA

SUBBEA      MOVE.L  #'SUB.',(A1)+
            ADDQ    #4,D1               ; We added 4 new characters to our IOStringLoc
            MOVE.B  #'B',(A1)+
            ADDQ    #1,D1               ; We added 1 byte into D1
            BRA     ANDEA

SUBLDN      MOVE.L  #'SUB.',(A1)+
            ADDQ    #4,D1               ; We added 4 new characters to our IOStringLoc
            MOVE.B  #'L',(A1)+
            ADDQ    #1,D1               ; We added 1 byte into D1
            BRA ANDDN
            
SUBWDN      MOVE.L  #'SUB.',(A1)+
            ADDQ    #4,D1               ; We added 4 new characters to our IOStringLoc
            MOVE.B  #'W',(A1)+
            ADDQ    #1,D1               ; We added 1 byte into D1
            BRA ANDDN

SUBBDN      MOVE.L  #'SUB.',(A1)+
            ADDQ    #4,D1               ; We added 4 new characters to our IOStringLoc
            MOVE.B  #'B',(A1)+
            ADDQ    #1,D1               ; We added 1 byte into D1
            BRA ANDDN  

;  Here we assume that these left-most nybble has been confirmed: 1011  
CMP        
            MOVE.L  D5,D6               ; Push D5 into D6
            ROR.L   #6,D6               ; Rotate 6 bits to the right
            LSL.L   #1,D6               ; Add 0 to right most bit
            ANDI.B  #$0F,D6             ; Isolate right-most nybble
            
            CMP.B   #$00,D6             ; If it matches CMP.B's size bit + 0 added to right
            BEQ     CMPB                ; First 4 left-most bits plus size of CMP confirmed

            CMP.B   #$02,D6             ; If it matches CMP.W's size bit + 0 added to right
            BEQ     CMPW                ; First 4 left-most bits plus size of CMP confirmed 

            CMP.B   #$04,D6             ; If it matches CMP.B's size bit + 0 added to right
            BEQ     CMPL                ; First 4 left-most bits plus size of CMP confirmed 
 
            BRA     UNKNOWN             ; else unknown 

;  Here we assume that confirming these bits, 1011 --- 000 --- ---, is enough to identify CMP.B 
CMPB        MOVE.W  #'CM',(A1)+
            MOVE.B  #'P',(A1)+
            MOVE.B  #'.',(A1)+
            MOVE.B  #'B',(A1)+
            ADDQ    #5,D1              ; We added 5 new characters to our IOStringLoc 
            MOVE.L  #1,D0               ; Put 1 into D0 to indicate it's a bytesize
            BRA     CMPOP

;  Here we assume that confirming these bits, 1011 --- 001 --- ---, is enough to identify CMP.W   
CMPW        MOVE.W  #'CM',(A1)+
            MOVE.B  #'P',(A1)+
            MOVE.B  #'.',(A1)+
            MOVE.B  #'W',(A1)+
            ADDQ    #5,D1              ; We added 5 new characters to our IOStringLoc 
            MOVE.L  #2,D0               ; Put 2 into D0 to indicate it's a wordsize
            BRA     CMPOP
            
;  Here we assume that confirming these bits, 1011 --- 010 --- ---, is enough to identify CMP.L
CMPL        MOVE.W  #'CM',(A1)+
            MOVE.B  #'P',(A1)+
            MOVE.B  #'.',(A1)+
            MOVE.B  #'L',(A1)+
            ADDQ    #5,D1              ; We added 5 new characters to our IOStringLoc 
            MOVE.L  #3,D0               ; Put 3 into D0 to indicate it's a longsize
            BRA     CMPOP
            
CMPOP       MOVE.B  #' ',(A1)+
            MOVE.W  #'  ',(A1)+      ; Add a spacer into our IOStringLoc
            MOVE.W  #'  ',(A1)+
            ADDQ    #5,D1              ; We added 4 bytes, aka 4 spaces
            
            MOVE.L  D5,D6               ; Push D5 into D6
            ANDI.L  #$003F,D6           ; Isolate the Src EA bits 
            JSR EAGETSRCEA              ; Find and print the code stored in D6
            
            MOVE.B  #',',(A1)+
            ADDQ    #1,D1
            
            MOVE.L  D5,D6               ; Copy D5 into D6
            ROR.L   #8,D6               ; Rotate 9 bits to the right (Dn Dst bits)
            ROR.L   #1,D6               ; Rotate 9 bits to the right (Dn Dst bits)
            ANDI.L  #$0007,D6           ; Isolate the Dn Destination bits
            JMP EADN
            
            RTS          
        
; This label determines if the code is either MULS or AND, by looking at it's size bits     
MULSAND     MOVE.L  D5,D6               ; Copy D5 into D6
            AND.B   #$38,D6             ; Check if the Src is of mode An
            CMP.B   #$08,D6
            BEQ     UNKNOWN             ; An is Invalid, branch to Unknown  
            MOVE.L  D5,D6               ; Copy D5 into D6 
            LSR.L   #6,D6               ; Shift the size bits to the far right
            ANDI.B  #$7,D6              ; Isolate the size bits
            CMP.B   #7,D6               ; See if the size is '111'..
            BEQ.S   MULS                ; ..If so, it's a MULS opcode
            BRA     AND                 ; Otherwise, it's an AND code
        
MULS                                   ; One test for illegal Src EA Mode
*            MOVE.L  D5,D6              ; Push D5 into D6   
*            ROR.L   #3,D6              ; Roll 3 bits right
*            ANDI.L  #$0007,D6          ; Isolate the 3 Src (Mode) bits
*            CMP.L   #$0001,D6          ; Compare with illegal mode An
*            BEQ     UNKNOWN
            *----------------
            MOVE.L  #'MULS',(A1)+
            ADDQ    #4,D1               ; We added 4 new characters to our IOStringLoc
            
            MOVE.L  #'    ',(A1)+       ; Add a spacer into our IOStringLoc
            MOVE.W  #'  ',(A1)+         ; Add a spacer into our IOStringLoc
            ADDQ    #6,D1               ; We added 4 bytes, aka 4 spaces
            
            MOVE.L  #2,D0               ; Put 2 into D0 to indicate it's a wordsize
            MOVE.L  D5,D6               ; Copy D5 into D6
            DC.L    0,0,0,0             ; Fault Bandaid
            ANDI.L  #$003F,D6           ; Isolate the Src EA bits
            JSR EAGETSRCEA
            
            MOVE.B  #',',(A1)+
            ADDQ    #1,D1
            
            MOVE.L  D5,D6               ; Copy D5 into D6
            ROL.W   #7,D6               ; Rotate 9 bits to the right (Dn Dst bits)
            ANDI.L  #$0007,D6           ; Isolate the Dn Destination bits
            JMP EADN
            
            RTS
            
; At this point, we know D6 is the size of our opcode
AND         AND.B   #$04,D6
            CMP.B   #%0100,D6           ; See if D6 is size "%100" through "%110"..
            BEQ     ANDEACH             ; .. Dn ~ <EA> --> <EA>
            
            MOVE.L  D5,D6               ; Copy D5 into D6
            LSR.L   #6,D6               ; Shift the size bits to the far right
            ANDI.B  #$7,D6              ; Isolate the size bits 
            
            CMP.B   #%10,D6             ; See if D6 is size "%000" through "%010"..
            BEQ     ANDLDN              ; If it is, our OpCode is in the format of..
            CMP.B   #%01,D6             ; .. <EA> ~ Dn --> Dn
            BEQ     ANDWDN
            CMP.B   #%00,D6
            BEQ     ANDBDN              ; == 000 at this point
            
            BRA     UNKNOWN

ANDEACH     MOVE.L  D5,D6               ; Copy D5 into D6
            AND.B   #$3F,D6             ; Isolate our EA Src bits
            CMP.B   #$39,D6             ; Check for Illegal #$ mode
            BEQ     UNKNOWN
            AND.B   #$38,D6             ; Isolate our EA Src Mode bits
            CMP.B   #$08,D6             ; Check for Illegal mode An
            BEQ     UNKNOWN
            CMP.B   #$00,D6             ; Check for Illegal mode Dn 
            BEQ     UNKNOWN
            
            MOVE.L  D5,D6               ; Copy D5 into D6
            LSR.L   #6,D6               ; Shift the size bits to the far right
            ANDI.B  #$7,D6              ; Isolate the size bits    
                 
            CMP.B   #%0110,D6           ; See if D6 is size "%100" through "%110"..
            BEQ     ANDLEA              ; If it is, our OpCode is in the format of..
            CMP.B   #%101,D6            ; .. Dn ~ <EA> --> <EA>
            BEQ     ANDWEA
            CMP.B   #%100,D6
            BEQ     ANDBEA
            
            BRA     UNKNOWN

            
ANDLEA      MOVE.L  #'AND.',(A1)+
            MOVE.B  #'L',(A1)+
            ADDQ    #5,D1               ; We added 5 byte into D1
            BRA     ANDEA
            
ANDWEA      MOVE.L  #'AND.',(A1)+
            MOVE.B  #'W',(A1)+
            ADDQ    #5,D1               ; We added 5 byte into D1
            BRA     ANDEA

ANDBEA      MOVE.L  #'AND.',(A1)+
            MOVE.B  #'B',(A1)+
            ADDQ    #5,D1               ; We added 5 byte into D1
            BRA     ANDEA

ANDEA       MOVE.B  #' ',(A1)+          ; Add a spacer into our IOStringLoc
            MOVE.W  #'  ',(A1)+         ; Add a spacer into our IOStringLoc
            MOVE.W  #'  ',(A1)+          ; Add a spacer into our IOStringLoc
            ADDQ    #5,D1               ; We added 4 bytes, aka 4 spaces
            
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
            
ANDLDN      MOVE.L  #'AND.',(A1)+
            ADDQ    #4,D1               ; We added 4 new characters to our IOStringLoc
            MOVE.B  #'L',(A1)+
            ADDQ    #1,D1               ; We added 1 byte into D1
            BRA ANDDN
            
ANDWDN      MOVE.L  #'AND.',(A1)+
            ADDQ    #4,D1               ; We added 4 new characters to our IOStringLoc
            MOVE.B  #'W',(A1)+
            ADDQ    #1,D1               ; We added 1 byte into D1
            BRA ANDDN

ANDBDN      MOVE.L  #'AND.',(A1)+
            ADDQ    #4,D1               ; We added 4 new characters to our IOStringLoc
            MOVE.B  #'B',(A1)+
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
ADDADDA     MOVE.L  D5,D6               ; Copy D5 into D6
            LSR.L   #6,D6               ; Shift the size bits to the far right
            ANDI.B  #$4,D6              ; Isolate the size bits
            
            CMP.B   #%0100,D6           ; See if D6 is size "%100" through "%110"..
            BEQ     ADDEA              ; .. Dn ~ <EA> --> <EA>
            
            MOVE.L  D5,D6               ; Copy D5 into D6
            LSR.L   #6,D6               ; Shift the size bits to the far right
            ANDI.B  #$7,D6              ; Isolate the size bits

            
            CMP.B   #%10,D6             ; See if D6 is size "%000" through "%010"..
            BEQ     ADDLDN              ; If it is, our OpCode is in the format of..
            CMP.B   #%01,D6             ; .. <EA> ~ Dn --> Dn
            BEQ     ADDWDN
            CMP.B   #%00,D6
            BEQ     ADDBDN              ; == 000 at this point
            
            CMP.B   #%011,D6            ; ADDA Word Operation <EA> -> An 
            BEQ     ADDAW
            CMP.B   #%111,D6            ; ADDA Word Operation <EA> -> An  
            BEQ     ADDAL
            BRA     UNKNOWN
            
ADDLDN      MOVE.L  #'ADD.',(A1)+
            ADDQ    #4,D1               ; We added 4 new characters to our IOStringLoc
            MOVE.B  #'L',(A1)+
            ADDQ    #1,D1               ; We added 1 byte into D1
            BRA ANDDN
            
ADDWDN      MOVE.L  #'ADD.',(A1)+
            ADDQ    #4,D1               ; We added 4 new characters to our IOStringLoc
            MOVE.B  #'W',(A1)+
            ADDQ    #1,D1               ; We added 1 byte into D1
            BRA ANDDN

ADDBDN      MOVE.L  #'ADD.',(A1)+
            ADDQ    #4,D1               ; We added 4 new characters to our IOStringLoc
            MOVE.B  #'B',(A1)+
            ADDQ    #1,D1               ; We added 1 byte into D1
            BRA ANDDN  

ADDEA       MOVE.L  D5,D6               ; Copy D5 into D6
            AND.B   #$3F,D6             ; Isolate our EA Src bits
            CMP.B   #$39,D6             ; Check for Illegal #$ mode
            BEQ     UNKNOWN
            AND.B   #$38,D6             ; Isolate our EA Src Mode bits
            CMP.B   #$08,D6             ; Check for Illegal mode An
            BEQ     UNKNOWN
            CMP.B   #$00,D6             ; Check for Illegal mode Dn 
            BEQ     UNKNOWN
            
            MOVE.L  D5,D6               ; Copy D5 into D6
            LSR.L   #6,D6               ; Shift the size bits to the far right
            ANDI.B  #$7,D6              ; Isolate the size bits    
                 
            CMP.B   #%0110,D6           ; See if D6 is size "%100" through "%110"..
            BEQ     ADDLEA              ; If it is, our OpCode is in the format of..
            CMP.B   #%101,D6            ; .. Dn ~ <EA> --> <EA>
            BEQ     ADDWEA
            CMP.B   #%100,D6
            BEQ     ADDBEA
            
            BRA     UNKNOWN

            
ADDLEA      MOVE.L  #'ADD.',(A1)+
            ADDQ    #4,D1               ; We added 4 new characters to our IOStringLoc
            MOVE.B  #'L',(A1)+
            ADDQ    #1,D1               ; We added 1 byte into D1
            BRA     ANDEA
            
ADDWEA      MOVE.L  #'ADD.',(A1)+
            ADDQ    #4,D1               ; We added 4 new characters to our IOStringLoc
            MOVE.B  #'W',(A1)+
            ADDQ    #1,D1               ; We added 1 byte into D1
            BRA     ANDEA

ADDBEA      MOVE.L  #'ADD.',(A1)+
            ADDQ    #4,D1               ; We added 4 new characters to our IOStringLoc
            MOVE.B  #'B',(A1)+
            ADDQ    #1,D1               ; We added 1 byte into D1
            MOVE.L  #1,D0               ; Move 1 into D0 to indicate bytesize
            BRA     ANDEA
            
ADDAW       MOVE.L  #'ADDA',(A1)+
            ADDQ    #4,D1               ; We added 4 new characters to our IOStringLoc
            MOVE.W  #'.W',(A1)+
            ADDQ    #2,D1               ; We added 1 byte into D1
            MOVE.L  #2,D0               ; Move 2 into D0 to indicate wordsize
            BRA     ADDAN
            
ADDAL       MOVE.L  #'ADDA',(A1)+
            ADDQ    #4,D1               ; We added 4 new characters to our IOStringLoc
            MOVE.W  #'.L',(A1)+
            ADDQ    #2,D1               ; We added 1 byte into D1
            MOVE.L  #3,D0               ; Move 3 into D0 to indicate longsize
            BRA     ADDAN
       
ADDAN
            MOVE.L  #'    ',(A1)+          ; Add a spacer into our IOStringLoc
            
            ADDQ    #4,D1               ; We added 4 bytes, aka 4 spaces
            
            MOVE.L  D5,D6               ; Copy our OpCode again
            ANDI.L  #$3F,D6             ; Isolate our EA bits
            
            JSR EAGETSRCEA              
            
            MOVE.B  #',',(A1)+
            ADDQ    #1,D1
            
            MOVE.L  D5,D6
            LSR.L   #8,D6               ; Shift our OpCode a total of 9 bits to the right
            LSR.L   #1,D6               ; 
            ANDI.L  #$07,D6             ; Isolate our data register
            
            JSR EAAN
            
            RTS
; This label determines if the code is either ASd (ASR) or LSd (LSL) or ROd (ROL) 
ASLSRO
            MOVE.L  D5,D6               ; Copy our OpCode
            LSR.W   #6,D6               ; Shift our size bits into place
            ANDI.B  #$03,D6             ; Isolate our size bits
            CMP.B   #%11,D6             ; If our size is '11'..
            BEQ     AASLSRO             ; ..this is an address ASLSRO
            
            MOVE.L  D5,D6               ; Copy our OpCode
            LSR.W   #3,D6               ; Shift our identification bits over
            ANDI.B  #03,D6              ;  and isolate them
            
            CMP.B   #%00,D6             ; If '00', this is a ASd op
            BEQ     ASD
            CMP.B   #%01,D6             ; If '01', this is a LSd op
            BEQ     LSD
            CMP.B   #%11,D6             ; If '11', this is a ROd op
            BEQ     ROD
            
            BRA     UNKNOWN             ; This catches for ROX, non-required op

ASD         MOVE.W  #'AS',(A1)+
            ADDQ    #2,D1
            BRA     ASLSRODR
            
LSD         MOVE.W  #'LS',(A1)+
            ADDQ    #2,D1
            BRA     ASLSRODR
            
ROD         MOVE.W  #'RO',(A1)+
            ADDQ    #2,D1
            BRA     ASLSRODR
            
; This section checks our ASd/LSd/ROd direction, and defaults to Right 
ASLSRODR    MOVE.L  D5,D6               ; Copy our OpCode
            ROR.L   #8,D6               ; Shift our direction bit into place
            BTST    #$00,D6             ; Check our right-most bit 
            BNE     ASLSRODL            ; If it's '1', our direction is left
            
            MOVE.B  #'R',(A1)+          ; Otherwise it's right
            MOVE.B  #'.',(A1)+
            ADDQ    #2,D1
            
            BRA ASLSROSIZE
            
; This section is our ASd/LSd/ROd left direction
ASLSRODL    MOVE.B  #'L',(A1)+          ; L for Left
            MOVE.B  #'.',(A1)+
            ADDQ    #2,D1
            ; Carry into our Size determiner
; Determines what size our ASd/LSd/ROd is
;  Our previous operations on D6 leave our size bits
;  just our of range, so we shift them in
ASLSROSIZE  
            ROL.L   #2,D6               ; Shift our size bits in
            ANDI.B  #$03,D6             ; Isolate our size bits
            CMP.B   #%00,D6             ; If our size is '00'..
            BEQ     ASLSROB             ; ..Then it's a byte op
            CMP.B   #%01,D6             ; If our size is '01'..
            BEQ     ASLSROW             ; ..Then it's a word op
            ; Otherwise it's a long op, because we accounted for '11' earlier
            
            MOVE.B  #'L',(A1)+          ; Add L for Long
            BRA     ASLSROIR            ; Complete the rest of the ASLSRO Op
            
ASLSROB     MOVE.B  #'B',(A1)+          ; Add B for Byte
            BRA     ASLSROIR            ; Complete the rest of the ASLSRO Op
            
ASLSROW     MOVE.B  #'W',(A1)+          ; Add W for Word
            ; Carry through to complete the rest of the ASLSRO Op  
     
; This section determines if our ASLSRO is an Immediate or Dn shfit, and defaults to Immediate
ASLSROIR    MOVE.B  #' ',(A1)+
            MOVE.W  #'  ',(A1)+
            MOVE.W  #'  ',(A1)+
            ADDQ    #6,D1               ; We've added 5 new characters (Size char, plus spaces)
            
            ;MOVE.L  D5,D6
            ROL.L   #1,D6               ; Get our Immediate / Register bit out front
            BTST.L  #$00,D6
            BNE     ASLSROIRDN          ; If it's '1', we have a Dn ASLSRO
            ; Otherwise, assume immediate ASLSRO
            MOVE.B  #'#',(A1)+
            ADDQ    #1,D1
            BRA     ASLSROOP            ; Branch to our ASLSRO Op finish
; An ASLSRO of Dn Register type   
ASLSROIRDN  MOVE.B  #'D',(A1)+
            ADDQ    #1,D1
            ; Continue through to our ASLSRO Op finish
; Finishes the ASLSRO Op
ASLSROOP
            MOVE.L  D5,D6               ; Copy our OpCode into D6
            ROR.L   #8,D6               ; Shift our Count/Reg bits into place
            ROR.L   #1,D6               ;
            ANDI.B  #$07,D6             ; Isolate the Count/Reg bits
            
            ADDI.B  #48,D6 
            MOVE.B  D6,(A1)+            ; Push our number to the IOStringLoc
            ADDQ    #1,D1
            
            MOVE.B  #',',(A1)+
            ADDQ    #1,D1
            
            MOVE.L  D5,D6               ; Isolate our Dn affected num bits
            ANDI.L  #$07,D6             ;
            JSR     EADN
            
            RTS
; Start of the Effective Address version of ASLSRO
AASLSRO     MOVE.L  D5,D6               ; Copy our OpCode into D6
            AND.L   #$3F,D6             ; Isolate the EA Srcs bits
            CMP.B   #$39,D6             ; Check for illegal #$ mode
            BEQ     UNKNOWN
            AND.L   #$38,D6             ; Isolate the EA src mode bits
            CMP.B   #$08,D6             ; Check for illegal An Mode
            BEQ     UNKNOWN
            CMP.B   #$00,D6             ; Check for illegal Dn mode
            BEQ     UNKNOWN
            

            MOVE.L  D5,D6               ; Copy our OpCode into D6
            ROL.W   #7,D6               ; Shift our determination bits to the far right
            ANDI.B  #$07,D6             ; Isolate the determination bits   
            
            CMP.B   #$01,D6             ; If our determination is '001'..
            BEQ     ALSD                ; It's a Logical Shift
            CMP.B   #$03,D6             ; If it's '011'
            BEQ     AROD                ; It's a Rotation 
            CMP.B   #$00,D6             ; If it's '000'
            BEQ     AASD                ; It's an Arithmetic Shift
            
            BRA     UNKNOWN              ; Otherwise it's data

AASD        MOVE.W  #'AS',(A1)+
            ADDQ    #2,D1
            BRA     AASLSRODR
            
ALSD        MOVE.W  #'LS',(A1)+
            ADDQ    #2,D1
            BRA     AASLSRODR
            
AROD        MOVE.W  #'RO',(A1)+
            ADDQ    #2,D1
            BRA     AASLSRODR
            
; This section checks our ASd/LSd/ROd direction, and defaults to Right 
AASLSRODR   MOVE.L  D5,D6              ; Copy our OpCode
            ROR.L   #8,D6               ; Shift our direction bit into place
            BTST    #$00,D6             ; Check our right-most bit 
            BNE     AASLSRODL           ; If it's '1', our direction is left
            
            MOVE.B  #'R',(A1)+          ; Otherwise it's right
            ADDQ    #1,D1
            
            BRA AASLSROOP
            
; This section is our ASd/LSd/ROd left direction
AASLSRODL   MOVE.B  #'L',(A1)+          ; L for Left
            ADDQ    #1,D1
            ; Carry into finishing AASLSRO op

; This section finishes off our Effective Address ASLSRO Op
AASLSROOP   MOVE.L  D5,D6               ; Copy our OpCode
            ANDI.L  #$3F,D6             ; Isolate our EA bits
            
            MOVE.B  #'.',(A1)+
            MOVE.B  #'W',(A1)+
            MOVE.B  #' ',(A1)+
            MOVE.B  #' ',(A1)+
            MOVE.B  #' ',(A1)+
            MOVE.B  #' ',(A1)+
            MOVE.B  #' ',(A1)+
            ADDQ    #7,D1
            
            JSR EAGETSRCEA
            
            RTS
UNKNOWN
            MOVE.L  #'DATA',(A1)+
            ADDQ    #4,D1           ; We added 4 new characters to our IOStringLoc 
            
            MOVE.L  #'    ',(A1)+       ; Add a spacer into our IOStringLoc
            MOVE.W  #'  ',(A1)+         ; Add a spacer into our IOStringLoc
            ADDQ    #6,D1               ; We added 6 bytes, aka 6 spaces
            
            MOVE.B  #'$',(A1)+
            ADDQ    #1,D1
            
            MOVE.L  D5,D6
            JSR     EAHEXtoASCII
            
            RTS
* Put variables and constants here















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
