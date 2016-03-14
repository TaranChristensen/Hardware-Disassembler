*-----------------------------------------------------------
* Title      : Test
* Written by : Cirlces
* Date       : 03/09/16
* Description: Test file to test the 20 required OpCodes
*-----------------------------------------------------------
STARTTEST: ORG    $8000

NOP NOP
data1		DC.W		$FFFF,$E1F9,$C249,$C3C9,$D349
data2		DC.W		$FFFF,$C349
    NOP
    ADDI    #$45,$8907
    ADDI    #$02,D1
    MOVE.B  D0,D5
    MOVE.B  #$AB,D5
    MOVE.W  #$ABCD,D5
    MOVE.L  #$ABCDEF01,D5
MOP MOVE.W  (A2),D5
    MOVE.L  (A4)+,D5
    MOVEQ   #6,D5
    MOVEM   A1-A5/A7/D1-D4/D6-D7,-(A7)
AOP ADD     D1,D5
    ADDA    D3,A5
    ADDI    #5,D5
    SUB.B   D1,D5
    SUB.L   (A1),D5
    MULS    D3,D5
    MULS    #$1234,D5
    DIVU    D5,D5
    DIVU    #$1234,D5
    LEA     $5012,A5
    LEA     $10101010,A5
    CLR     D5
    AND     D0,D5
    AND     (A1),D5
    AND     D3,(A5)
    LSL     #2,D5
    LSL.W   (A7)
    ASR     #4,D5
    ROL     #6,D5
    CMP     D0,D5
    CMP     #1,D5
    CMP.L   #$12345678,D5
BOP BCC.L   $123F
    BGT     BOP
    BLE     $1012
    JSR     $1013
    RTS     

    END STARTTEST





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
