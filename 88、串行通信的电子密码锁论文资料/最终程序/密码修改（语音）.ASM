 ORG   0000H

 ajmp  main
 org   0030h

main:  MOV   SP,#70
      MOV   SCON,#50H
      MOV   TMOD,#20H
      MOV   TH1,#0F3H
      SETB  TR1
      MOV   R7,#00H         ;延时
      DJNZ  R7,$
      MOV   R7,#10H         ;内定密码在TABLE的起始地址
      MOV   R6,#06          ;内定6个密码
      MOV   R1,#35H         ;6个密码分别存入35H~30H地址
L1:   MOV   A,R7            ;内定密码取码指针
      MOV   DPTR,#TABLE     ;数据指针指到TABLE
      MOVC  A,@A+DPTR       ;至TABLE取码
      MOV   @R1,A           ;存入35H~30H地址
      DEC   R1              ;存下一个地址
      INC   R7              ;取码指针加1
      DJNZ  R6,L1
START: ORL   P2,#0FFH 
       ORL  P3,#0FFH        ;清除P2
      SETB P3.2
      MOV   R4,#06          ;清除显示器存放地址40H~45H的地址
      MOV   R0,#40H
CLEAR:MOV   @R0,#00H
      INC   R0
      DJNZ  R4,CLEAR

L2:   MOV   R3,#0F7H        ;扫描指针初值
      MOV   R1,#00H         ;键盘取码指针
L3:   MOV   A,R3
      MOV   P1,A
      MOV   A,P1
      MOV   R4,A
      SETB  C
      MOV   R5,#04H
L4:   RLC   A
      JNC   KEYIN
      INC   R1
      DJNZ  R5,L4
      CALL  DISP
      MOV   A,R3
      SETB  C
      RRC   A
      MOV   R3,A
      JC    L3
      lcall LLL
      JMP   L2
KEYIN:MOV   A,R1
      XRL   A,#0EH
      JZ    X3
      MOV   A,R1
      XRL   A,#0FH
      JZ    X4
      MOV   R7,#10
D1:   MOV   R6,#248
      DJNZ  R6,$
      DJNZ  R7,D1
D2:   MOV   A,P1
      XRL   A,R4
      JZ    D2
      MOV   A,R1
      MOV   DPTR,#TABLE
      MOV   R7,A
      XRL   A,#0AH
      JZ    SET0
      MOV   A,R7
      XRL   A,#0BH
      JZ    START
      MOV   A,R7
      XRL   A,#0CH
      JZ    L2
      MOV   A,R7
      XRL   A,#0DH
      JZ    L2
      MOV   A,R7
      XCH   A,40H
      XCH   A,41H
      XCH   A,42H
      XCH   A,43H
      XCH   A,44H
      XCH   A,45H
      CALL  DISP
      JMP   L2
X3:   JMP   DISP2
X4:   JMP   COMP
DISP: MOV   R0,#45H
DISP1:MOV   A,@R0
      ADD   A,#50H         ;显示D6
      MOV   P0,A
      CALL  DELAY
      DEC   R0
      MOV   A,@R0          ;D5数据值加上74138扫描值
      ADD   A,#40H         ;显示D5
      MOV   P0,A
      CALL  DELAY
      DEC   R0
      MOV   A,@R0          ;D4数据值加上74138扫描值
      ADD   A,#30H         ;显示D4
      MOV   P0,A           ;扫描延时
      CALL  DELAY
      DEC   R0
      MOV   A,@R0          ;D3数据值加上74138扫描值
      ADD   A,#20H         ;显示D3
      MOV   P0,A           ;扫描延时
      CALL  DELAY
      DEC   R0
      MOV   A,@R0          ;D2数据值加上74138扫描值
      ADD   A,#10H         ;显示D2
      MOV   P0,A           ;扫描延时
      CALL  DELAY
      DEC   R0
      MOV   A,@R0          ;D1数据值加上74138扫描值
      ADD   A,#00H         ;显示D1
      MOV   P0,A           ;扫描延时
      CALL  DELAY
      RET
SET0: MOV   R2,#06H
      MOV   R0,#40H
      MOV   R1,#30H
E1:   MOV   A,@R0
      XCH   A,@R1
      INC   R0
      INC   R1
      DJNZ  R2,E1
      call  yuyin4
      CALL  DELAY
E2:   JMP   START
COMP: MOV   R1,#45H
      MOV   R0,#35H
      MOV   R2,#06H
C1:   MOV   A,@R1
      XRL   A,@R0
      JNZ   C3
      DEC   R1
      DEC   R0
      DJNZ  R2,C1
      CLR   P3.2
      CALL  YUYIN1
      MOV   R2,#0FFH
C2:   MOV   R6,#0FFH
      DJNZ  R6,$
      DJNZ  R2,C2
C3:   CALL YUYIN2
       JMP   START
DISP2:
      MOV   R0,#35H
      CALL  DISP1
      MOV   A,P1
      XRL   A,R4
      JZ    DISP2
      call  yuyin3
      CALL  DELAY
      JMP   START
DELAY:MOV   R7,#03
D3:   MOV   R6,#248
      DJNZ  R6,$
      DJNZ  R7,D3
      RET
Lll:  JBC   RI,UART
      call  disp
      ret
UART: MOV   A,SBUF
      MOV   R7,A
      XRL   A,#0AH
      JZ    COMPQ
      AJMP COMPA
COMPQ: LJMP COMP

COMPA: MOV   A,R7
     XRL   A,#0BH
      JZ    ss
      ajmp ddd
ss:   ajmp start

ddd:  MOV   A,R7
      XCH   A,40H
      XCH   A,41H
      XCH   A,42H
      XCH   A,43H
      XCH   A,44H
      XCH   A,45H
      CALL  DISP
      ret
yuyin1:   MOV   P2,#01H
          lcall  delay2
          MOV   P2,#00H
          lcall  delay1
          jmp    start
 delay1:  mov   r3,#50
    do1:   mov   r4,#100
    Do2:   MOV   R5,#248
          DJNZ  R5,$
          DJNZ  R4,Do2
          djnz  r3,do1
          ret
delay2:  mov   r2,#20
      D03:MOV  R6,#100
      D04:mov   r7,#248
          djnz  r7,$
          DJNZ  R6,D04
          djnz  r2,d03
         ret
YUYIN2:   MOV   P2,#41H
          lcall  delay2
          MOV   P2,#40H
          lcall  delay21
          jmp    start
delay21:  mov   r3,#100
          CALL  DO1
          ret
yuyin3:   MOV   P2,#21H
          lcall  delay2
          MOV   P2,#20H
          lcall  delay31
          jmp    start
 delay31:  mov   r3,#100
           call     DO1     
           ret
yuyin4:    MOV   P2,#09H
          lcall  delay2
          MOV   P2,#08H
          lcall  delay41
          jmp    start
 delay41:  mov   r3,#100
           call      DO1 
           ret
     
      ORG   1000H
TABLE:DB  01H,02H,03H,0CH
      DB  04H,05H,06H,0DH
      DB  07H,08H,09H,0EH
      DB  0AH,00H,0BH,0FH
      DB  02H,02H,01H,05H,08H,02H
      END
