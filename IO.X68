*-----------------------------------------------------------
* Title      : IO
* Written by : Circles
* Date       : ##/##/16
* Description: Input Output File
*-----------------------------------------------------------

* Put program code here
*-------Code for output-------
IOINTRO LEA     IntroMsg,A1      Display the intro
        MOVE.B  #14, D0
        TRAP    #15

IOLOOP  LEA     HexStart,A1        Display the prompt and loop it
        MOVE.B  #14,D0          
        TRAP    #15       

*-------Code for input-------
        LEA  IOStringLoc,A1     ; Store the string of our user input at StartAddress,A1 
        MOVE.B  #2,D0           ;   uses Trap #15, Task 2
        TRAP    #15             ;
        
        CMP.L   #1,D1           ; Compares D1 to the number 1 (eg. String length of 1)
        BEQ     IODONE          ; Branch to DONE if they are equal
        
        CLR.L   D4              ; Ensure our counter (D4) is 0      
            
IOASCIItoHEX    ADDQ    #1,D4
                LSL.L   #4,D2           ; Scoot D2 a nybble
                MOVE.B  (A1)+,D3        ; Move a Byte from A1's address to D3
                SUB.B   #48,D3          ; Sub 48 to turn ASCII 0 into binary 0
                CMP.B   #9,D3           ; If our number is greater than 9..
                BLE.S   IOORTAG         ; .. it must be a character; A-F: 
                SUB.B   #7,D3           ; Sub 7 to turn A into 10
IOORTAG         OR.B    D3,D2           ; Store our nybble into D2
                CMP.B   D4,D1           ; See if we've read all the characters
                BNE.S   IOASCIItoHEX    ; Continue if we haven't
            
        MOVE.L  #0,StartAddress
        MOVE.L  D2,StartAddress     ; Store our StartAddress
        
        CLR.L   D1
        
        ; ==== OUTPUT OPCODE ===    
        MOVE.L  #0,IOStringLoc      ; == Testing Purposes; not nessessary ==   
        
        ; <Testing section>        
        MOVE.L  StartAddress,A2     ; Push our start address into A2 
        MOVE.W  #$C1C1,(A2)+    ; Push OpCode for MULS D1,D0 into our start address
        MOVE.W  #$3200,(A2)+    ; Push OpCode for Move.W D0,D1 into our start address
        MOVE.W  #$2200,(A2)+    ; Push OpCode for Move.L D0,D1 into our start address
        ; </Testing section>
        
        MOVE.L  StartAddress,A2     ; Push our start address into A2 
        LEA     IOStringLoc,A1      ; Load our IOStringLoc into A1 for string contruction purposes
        
        ; Here we could loop all of the addresses of A2 until End, or something.
        MOVE.L  #'####',(A1)+       ; Move our "OpCode location" into our IOStringLoc <---- THIS NEEDS TO BE HEX
        ADDQ    #4,D1               ; We added 4 new characters                       <---- THIS NEEDS TO BE 8
        MOVE.L  #'    ',(A1)+       ; Add a spacer into our IOStringLoc
        ADDQ    #4,D1               ; We added 4 bytes, aka 4 spaces
        
        JSR OPGETCODE               ; Get the OpCode pointed at by A2, it's string stored in IOStringLoc
        
        LEA     IOStringLoc,A1      ; Now that we've populated the string, load it's beginning
        MOVE.B  #1,D0               ; Trap task 1 prints a string at A1 with #D1 bytes.
        TRAP    #15

        LEA     SPC,A1              ; Puts the space before the opCode
        MOVE.B  #13,D0
        TRAP    #15
        ; ==== END OUTPUT OPCODE ====

        LEA     RES,A1          ; Output the beginning of the message
        MOVE.B  #14,D0  
        TRAP    #15

        ; ==== OUTPUT USER INPUT ====
        ; The following outputs the input, converting what we've saved in HEX to ASCII
        ; We won't need this in the final version, but the below code should be handy
        ;  for print out EA values
        MOVE.L  StartAddress,D2 ; Ensure our address is actually at D2
        MOVEQ   #8,D1           ; There are 8 characters in the hex of our address
        CLR.L   D4              ; Ensure our counter (D4) is 0
        LEA     IOStringLoc,A1  ; Load our IO String location, to store our output at  
        
IOHEXtoASCII    ADDQ    #1,D4
                ROL.L   #4,D2           ; Get the left-most nyblle to the front..
                MOVE.B  D2,D3           ; .. Put the front-most byte into D3    
                AND.B   #$0F,D3         ; Distill D3 down to the original left-most nybble
                CMP.B   #9,D3           ; See if our number is greater than 9..
                BLE     IODIGIT         ; If it is 9 or less, it's a digit..
                ADD.B   #7,D3           ; Otherwise it is a digit, and needs an additional 7
IODIGIT         ADD.B   #48,D3          ; We now how the nybble's ASCII code
                MOVE.B  D3,(A1)+        ; Move the ASCII code into the output string at A1
                CMP.B   D4,D1           ; See if we've read all the characters
                BNE.S   IOHEXtoASCII    ; Continue if we haven't
        
        LEA     IOStringLoc,A1  ; Now that we've populated the string, load it's beginning
        MOVE.B  #1,D0           ; Trap task 1 prints a string at A1 with #D1 bytes.
        TRAP    #15
        ; ==== END OUTPUT USER INPUT ====

        LEA     SPC,A1          Puts the space after the number
        MOVE.B  #13,D0
        TRAP    #15

        BRA     IOLOOP
        
*-------Finishes the program-        
IODONE  LEA     OUTRO,A1        Display the ending message 
        MOVE.B  #14,D0
        TRAP    #15
        MOVE.B  #9,D0
        TRAP    #15             Halt Simulator
        
        SIMHALT
        
CR              EQU     $0D         
LF              EQU     $0A 
IOStringLoc     EQU     $0100   ; This is where we will store the string of the user input, and other strings

*-------Various outputs------
IntroMsg        DC.B    'Team Circles Disassembler ',CR,LF,0     Intro
HexStart        DC.B    'Please enter a full hexidecimal address to get started, or',CR,LF,'type in 0 to quit: ',0         Prompt for the user
RES             DC.B    'You typed in ',0                        Response to the user
SPC             DC.B    '     ',0                                tab
UnkEA           DC.B    '<EA>,<EA>',0                            Interim message for unkown EAs.
OUTRO           DC.B    'Goodbye !',0                            Outro message
StartAddress    DS.L    1

* Put variables and constants herevv







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
