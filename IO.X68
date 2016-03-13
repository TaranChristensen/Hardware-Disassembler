*-----------------------------------------------------------
* Title      : IO
* Written by : Circles
* Date       : ##/##/16
* Description: Input Output File
*-----------------------------------------------------------
                LEA     COUNTER,A3         initialize the COUNTER variable
                MOVE.L  #0,(A3)            clear the variable
                
*-------Code for output-------

IOINTRO         ADD.L   #$00000016,(A3)    COUNTER++
                LEA     IntroMsg,A1        Display the intro
                MOVE.B  #14, D0
                TRAP    #15
                
                LEA     Intro2,A1        Display the intro
                MOVE.B  #14, D0
                TRAP    #15

IOLOOP          LEA     HexStart,A1        Display the prompt and loop it
                MOVE.B  #14,D0          
                TRAP    #15   
                ADD.L   #$00000002,(A3)    COUNTER++ COUNTER++

*-------Code for input-------

                LEA     IOStringLoc,A1     Store the string of our user input at StartAddress,A1 
                MOVE.B  #2,D0              uses Trap #15, Task 2
                TRAP    #15              
        
                CLR.L   D4                 Ensure our counter (D4) is 0 

                JSR     LENGTH_CHECK 
                CLR.L   D2  
                CMP.B   #1,D5              if 1 then it passed the tests         
                
                BEQ     IOASCIItoHEX
                BRA     IOLOOP
                
CHECK31         CMP.L   #$0000001F,(A3)    compare the counter to 29
                BGT     ENTERCHECK         counter is at at least 30
                RTS                        counter is still low

ENTERCHECK      CLR.L   D0
                LEA     ENTERPROMPT,A1     display the enter prompt
                MOVE.B  #14,D0
                TRAP    #15
                
                MOVE.L  #$2000,A1  

                MOVE.B  #2,D0              wait for the user to hit enter
                TRAP    #15
                
                MOVE.L  #0,(A3)            clear the counter
                ADD.L   #$00000001,(A3)    COUNTER++
             
                RTS
                
LENGTH_CHECK    CLR.L   D5                 store the result of the test
                MOVEQ   #$0,D6             make D6 0
                CMP.B   D6,D1              see if null
                BEQ     BAD_LENGTH         if null then branch to bad input
                CMPI    #$8,D1             see if it is more than 8 characters long
                BGT     BAD_LENGTH         if more than 8 branch to bad input
                MOVE.B  #$1,D5             passed the length checks so move 1
                RTS                        go back
                
BAD_LENGTH      MOVEQ   #$0,D5             did not pass the test
                LEA     FAIL_INPUT,A1      load bad input message
                MOVE.B  #14,D0          
                TRAP    #15 
                ADD.L   #$00000001,(A3)    COUNTER++
                RTS                        go back
                
STARTLESSTHNEND LEA     STARTGTEND,A1      load the error 
                MOVE.B  #14,D0
                TRAP    #15
                ADD.L   #$00000001,(A3)    COUNTER++
                BRA     IOLOOP             go back to the start


TEST_ODD        CLR.L   D6           
                CLR.L   D5
                MOVE.L  #$00000002,D5      divide by 2 to see remainder
                MOVE.W  D2,D6              create a copy of the input in D6
                DIVU    D5,D6              divide the hex number by 2
                
                SWAP    D6                 put the remainder on the far right
                
                CMP.B   #1,D6              see if the remainder is one
                BEQ     BAD_EVEN           branch to bad even
            
                CLR.L   D6
                CLR.L   D5
 
                RTS       
                
BAD_EVEN        CLR.L   D5
                CLR.L   D6
                LEA     FAIL_INPUT,A1      load bad input message  
                MOVE.B  #14,D0          
                TRAP    #15 
                ADD.L   #$00000001,(A3)    COUNTER++
                BRA     IOLOOP             go back to the beginning
                
*-------Code for the starting address-------

IOASCIItoHEX    ADDQ    #1,D4
                LSL.L   #4,D2              Scoot D2 a nybble
                MOVE.B  (A1)+,D3           Move a Byte from A1's address to D3
                SUB.B   #48,D3             Sub 48 to turn ASCII 0 into binary 0
                CMP.B   #9,D3              If our number is greater than 9..
                BLE.S   IOORTAG            .. it must be a character; A-F: 
                SUB.B   #7,D3              Sub 7 to turn A into 10
IOORTAG         OR.B    D3,D2              Store our nybble into D2
                CMP.B   D4,D1              See if we've read all the characters
                BNE.S   IOASCIItoHEX       Continue if we haven't
            
            
                MOVE.L  #0,StartAddress
                MOVE.L  D2,StartAddress    Store our StartAddress
                
                JSR     TEST_ODD           test if the address is odd
                
                CLR.L   D1
                CLR.L   D2

*-------Code for the ending address-------

ENDLOOP         LEA     HexEnd,A1          load the ending address prompt
                MOVE.B  #14,D0
                TRAP    #15  
                ADD.L   #$00000002,(A3)
                
                LEA     IOStringLoc,A1     Store the string of our user input at StartAddress,A1 
                MOVE.B  #2,D0              uses Trap #15, Task 2
                TRAP    #15              
        
                CLR.L   D4                 Ensure our counter (D4) is 0 

                JSR     LENGTH_CHECK       check to make sure the length is ok
                CMP.B   #1,D5              if 1 then it passed the tests         

                BEQ     IOASCIItoHEX2      convert to hex
                BRA     ENDLOOP
                
IOASCIItoHEX2   ADDQ    #1,D4
                LSL.L   #4,D2              Scoot D2 a nybble
                MOVE.B  (A1)+,D3           Move a Byte from A1's address to D3
                SUB.B   #48,D3             Sub 48 to turn ASCII 0 into binary 0
                CMP.B   #9,D3              If our number is greater than 9..
                BLE.S   IOORTAG2           .. it must be a character; A-F: 
                SUB.B   #7,D3              Sub 7 to turn A into 10
IOORTAG2        OR.B    D3,D2              Store our nybble into D2
                CMP.B   D4,D1              See if we've read all the characters
                BNE.S   IOASCIItoHEX2      Continue if we haven't
            
  
                MOVE.L  #0,EndingAddress
                MOVE.L  D2,EndingAddress   Store our EndingAddress
                
                JSR     TEST_ODD           tezt if the ending address is odd
                
                MOVE.L  StartAddress,A2    Push our start address into A2
                
                CMP.L   EndingAddress,A2   compare the ending address with the startingaddress
                BGT     STARTLESSTHNEND    branch if the starting is greater than the ending
                
                CLR.L   D1
                
                MOVE.L  StartAddress,A2    Push our start address into A2 
                
*-------Output Opcode------- 

OUTPUTOPCODE    MOVE.L  #0,IOStringLoc     ********** Testing purposes ********** 
                CLR.L   D1
        

                LEA     IOStringLoc,A1     Load our IOStringLoc into A1 for string contruction purposes
        
                MOVE.L  A2,D6
                CLR     D4
                SWAP    D6
                JSR     EAHEXtoASCII
                CLR     D4
                SWAP    D6
                JSR     EAHEXtoASCII
                MOVE.L  #'    ',(A1)+      Add a spacer into our IOStringLoc
                MOVE.W  #'  ',(A1)+      Add a spacer into our IOStringLoc
                ADDQ    #6,D1              We added 4 bytes, aka 4 spaces
        
                JSR OPGETCODE              Get the OpCode pointed at by A2, it's string stored in IOStringLoc
                
                LEA     IOStringLoc,A1     Now that we've populated the string, load it's beginning
                MOVE.B  #1,D0              Trap task 1 prints a string at A1 with #D1 bytes.
                TRAP    #15           
        
                LEA     SPC,A1             Puts the space before the opCode
                MOVE.B  #13,D0
                TRAP    #15
                
                ADD.L   #$00000001,(A3)    COUNTER++
                JSR     CHECK31
                
                CMP.L   EndingAddress,A2   compare the current address with the ending address
                BLT     OUTPUTOPCODE       if the current is less than the ending keep looping

*-------Output User Input------- 

                ; The following outputs the input, converting what we've saved in HEX to ASCII
                ; We won't need this in the final version, but the below code should be handy
                ;  for print out EA values
                MOVE.L  StartAddress,D2    Ensure our address is actually at D2
                MOVEQ   #8,D1              There are 8 characters in the hex of our address
                CLR.L   D4                 Ensure our counter (D4) is 0
                LEA     IOStringLoc,A1     Load our IO String location, to store our output at  

        
IOHEXtoASCII    ADDQ    #1,D4
                ROL.L   #4,D2              Get the left-most nyblle to the front..
                MOVE.B  D2,D3              .. Put the front-most byte into D3    
                AND.B   #$0F,D3            Distill D3 down to the original left-most nybble
                CMP.B   #9,D3              See if our number is greater than 9..
                BLE     IODIGIT            If it is 9 or less, it's a digit..
                ADD.B   #7,D3              Otherwise it is a digit, and needs an additional 7
IODIGIT         ADD.B   #48,D3             We now how the nybble's ASCII code
                MOVE.B  D3,(A1)+           Move the ASCII code into the output string at A1
                CMP.B   D4,D1              See if we've read all the characters
                BNE.S   IOHEXtoASCII       Continue if we haven't

                LEA     CONTINUE,A1        ask if the user wnats to exit
                MOVE.B  #14,D0
                TRAP    #15
                
                MOVE.B  #0,D1              clear D1
                MOVE.B  #5,D0              keybaord echo trap task
                TRAP    #15
                
                LEA     SPACER,A1          println
                MOVE.B  #14,D0
                TRAP    #15
                
                CMP.B   #$71,D1            compare with lowercase q
                BEQ     IODONE             if equal then go to the end

                BRA     IOLOOP             not equal so go to the beginning
        
*-------Finishes the program--  
      
IODONE          LEA     OUTRO,A1           Display the ending message 
                MOVE.B  #14,D0
                TRAP    #15
                MOVE.B  #9,D0
                TRAP    #15                Halt Simulator
        
                SIMHALT
        
CR              EQU     $0D         
LF              EQU     $0A 
IOStringLoc     EQU     $0100              This is where we will store the string of the user input, and other strings

*-------Various outputs------

IntroMsg        DC.B '                              -----------',CR,LF
                DC.B '                            /             \',CR,LF
                DC.B '                           /     TEAM      \',CR,LF
                DC.B '                          /                 \',CR,LF
                DC.B '                         |                   |',CR,LF
                DC.B '                         |      CIRCLES      |',CR,LF
                DC.B '                         |                   |',CR,LF
                DC.B '                          \                 /',CR,LF
                DC.B '                           \ DISSASSEMBLER /',CR,LF
                DC.B '                            \             /',CR,LF
                DC.B '                              -----------',CR,LF,CR,LF,0
                
Intro2          DC.B    'This program will dissassemble machine code into readable code',CR,LF
                DC.B    'It will ask for a starting and ending address',CR,LF
                DC.B    'Please type both in hex, with a length of 8 or less',CR,LF
                DC.B    'And not ending in an odd number',CR,LF
                DC.B    'If an address is input that does not meet the criteria',CR,LF
                DC.B    'The program will start over at the starting address prompt',CR,LF
                DC.B    'When the program has reached the ending address',CR,LF
                DC.B    'It will ask if you want to try again with different addresses',CR,LF
                DC.B    'When this happens press "q" to exit.',CR,LF,CR,0
                
HexStart        DC.B    CR,LF,'Enter a starting address: ',0 Prompt for the user
HexEnd          DC.B    CR,LF,'Enter an ending address: ',0 Prompt for the user
SPC             DC.B    '     ',0                                tab
UnkEA           DC.B    '<EA>,<EA>',0                            Interim message for unkown EAs.
OUTRO           DC.B    CR,LF,'Thank you for using Team Circles Dissassembler!',0                            Outro message
FAIL_INPUT      DC.B    'I am sorry, but you typed an address that did not meet the criteria',CR,LF,0 
ENTERPROMPT     DC.B    'The screen limit has been reached, please press enter to continue',0
STARTGTEND      DC.B    'The ending address was less than the starting address, please try again',CR,LF,0
CONTINUE        DC.B    CR,LF,'Press "q" to quit or anything else to continue: ',0 ask to exit
SPACER          DC.B    CR,LF,0 put the new line after the keyboard input

*-------Variables and constants------

StartAddress    DS.L    1
EndingAddress   DS.L    1
COUNTER         DS.L    1 keep track of the lines on the screen
























*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
