*-----------------------------------------------------------
* Title      : Test
* Written by : Cirlces
* Date       : 03/09/16
* Description: Test file to test the 20 required OpCodes
*-----------------------------------------------------------
STARTTEST: ORG    $8000

    NOP
    MOVE.B  D0,D1
    MOVE.W  (A2),D3
    MOVE.L  (A4)+,D5
    MOVEQ   #6,D7
    MOVEM   A0-A6/D0-D6,-(A7)
    ADD     D1,D2
    ADDA    D3,A4
    ADDI    #5,D6
    SUB     D1,D2
    MULS    D3,D4
    DIVU    D5,D6
    LEA     $5012,A1
    CLR     D0
    AND     D0,D1
    LSL     #2,D3
    ASR     #4,D5
    ROL     #6,D7
    CMP     D0,D1
    ;BCC     $1001
    ;BGT     $1002
    ;BLE     $1003
    JSR     $1004
    RTS     

    END STARTTEST
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
