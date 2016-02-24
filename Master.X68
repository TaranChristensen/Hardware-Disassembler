*-----------------------------------------------------------
* Title      : Master
* Written by : Circles
* Date       : ##/##/16
* Description: Project Master File
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
    INCLUDE "IO.X68"    ;
    INCLUDE "OpCode.X68"    ;
    INCLUDE "EA.X68"    ;


    
*-------Code for output-------
        LEA     MESSAGE,A1      Display the intro
        MOVE.B  #14, D0
        TRAP    #15

LOOP    LEA     MESS2,A1        Display the prompt and loop it
        MOVE.B  #14,D0          
        TRAP    #15       

*-------Code for input-------
        MOVE.B  #4,D0           Trap task 4 does the following:
        TRAP    #15             Read a number from the keyboard into D1.L
        
        LEA     RES,A1          Output the beginning of the message
        MOVE.B  #14,D0  
        TRAP    #15
        
        MOVE.B  #3,D0           Output the number that was input
        TRAP    #15
        
        LEA     SPC,A1          Puts the space after the number
        MOVE.B  #14,D0
        TRAP    #15
        
        CMP.L   #0,D1           Compares D1 to the number 0
        BEQ     DONE            Branch to DONE if they are equal

        BRA     LOOP
        
*-------Finishes the program-        
DONE    LEA     OUTRO,A1        Display the ending message 
        MOVE.B  #14,D0
        TRAP    #15
        MOVE.B  #9,D0
        TRAP    #15             Halt Simulator

CR      EQU     $0D         
LF      EQU     $0A 

*-------Various outputs------
MESSAGE DC.B    'Team Circles Disassembler ',CR,LF,0     Intro
MESS2   DC.B    'Enter something (0) to quit: ',0         Prompt for the user
RES     DC.B    'You typed in ',0                         Response to the user
SPC     DC.B    ' ',CR,LF,0                               endl
OUTRO   DC.B    'Goodbye !',0                             Outro message
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
