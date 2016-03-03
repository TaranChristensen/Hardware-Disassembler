*-----------------------------------------------------------
* Title      : Master
* Written by : Circles
* Date       : ##/##/16
* Description: Project Master File
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
    INCLUDE "IO.X68"        ; Handles our input and output, as well as which address to refer to
    INCLUDE "OpCode.X68"    ; Handles determining OpCodes
    INCLUDE "EA.X68"        ; Handles EA types
    
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
