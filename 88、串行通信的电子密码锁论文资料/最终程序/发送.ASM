       ORG   00H
       MOV   SP,#70H        ;设置堆栈
       MOV   SCON,#50H      ;UART工作在MODE1
       MOV   TMOD,#20H      ;TIMER1工作在MODE2
       MOV   TH1,#0F3H      ;波特率为2400
       SETB  TR1            ;启动TIMER1
START: MOV   R4,#06H        ;清除显示器地址30H~35H
       MOV   R0,#30H
CLEAR: MOV   @R0,#00H
       INC   R0
       DJNZ  R4,CLEAR
L1:    MOV   R3,#0F7H       ;扫描初值（P13=0）
       MOV   R1,#00H        ;取码指针
L2:    MOV   A,R3           ;开始扫描
       MOV   P1,A           ;将扫描值输出至P1
       MOV   A,P1           ;读入P1值，判断是否有键按下？
       MOV   R4,A           ;存入R4，以判断是否放开
       SETB  C              ;C =1
       MOV   R5,#03H        ;扫描P15~P17
L3:    RLC   A              ;将按键值左移一位
       JNC   KEYIN          ;判断C =0？有键按下则=0，跳至KEYIN
       INC   R1             ;C=1则表示无键按下，将取码指针值加1
       DJNZ  R5,L3          ;3列扫描完毕了？
       CALL  DISP           ;调用显示子程序
       MOV   A,R3           ;扫描值载入
       SETB  C              ;C=1
       RRC   A              ;扫描下一行（P13~P10）
       MOV   R3,A           ;存入扫描寄存器
       MOV   R3,A
       JC    L2             ;C =1？是则P10尚未扫描到
       JMP   L1             ;C =0则4行已扫描完毕
KEYIN: MOV   R7,#60         ;消除抖动
D2:    MOV   R6,#248
       DJNZ  R6,$
       DJNZ  R7,D2
D3:    MOV   A,P1           ;读入P1值
       XRL   A,R4           ;与上次读入值作比较
       JZ    D3             ;ACC=0则相等，表示按钮未放
       MOV   A,R1           ;按钮已放开，取码指针载入累加器
       MOV   DPTR,#TABLE    ;数据指针指到TABLE
       MOVC  A,@A+DPTR      ;至TABLE取码
       MOV   R7,A           ;取到的数据码暂存入R7
       XRL   A,#0AH         ;是否按“* ”
       JZ    COMP           ;是则跳至COMP
       MOV   A,R7           ;不是，则再检测
       XRL   A,#0BH         ;是否按“#”
       
       JZ    START          ;是则跳至START清除
       MOV   A,R7           ;不是，则为数字键
       MOV   SBUF,A         ;将按键值发送给8751-R
WAIT:  JBC   TI,L4          ;发送完毕否？如发送完毕TI=1
       JMP   WAIT
L4:    XCH   A,30H          ;现按键值存入（30H）
       XCH   A,31H          ;旧（30H）值存入（31H）
       XCH   A,32H          ;旧（31H）值存入（32H）
       XCH   A,33H          ;旧（32H）值存入（33H）
       XCH   A,34H          ;旧（33H）值存入（34H）
       XCH   A,35H          ;旧（34H）值存入（35H）
       CALL  DISP           ;调用显示子程序
       JMP   L1
COMP:  MOV   A,R7           ;发送开门码（0AH）给8751-R
       MOV   SBUF,A
WAIT1: JBC   TI,START       ;发送完毕否？如发送完毕TI=1
       JMP   WAIT1
DISP:  MOV   A,35H          ;D6数据值加上74138扫描值
       ADD   A,#50H         ;显示D6
       MOV   P0,A           ;扫描延时
       CALL  DELAY
       MOV   A,34H          ;D5数据值加上74138扫描值
       ADD   A,#40H         ;显示D5
       MOV   P0,A           ;扫描延时
       CALL  DELAY
       MOV   A,33H          ;D4数据值加上74138扫描值
       ADD   A,#30H         ;显示D4
       MOV   P0,A           ;扫描延时
       CALL  DELAY
       MOV   A,32H          ;D3数据值加上74138扫描值
       ADD   A,#20H         ;显示D3
       MOV   P0,A           ;扫描延时
       CALL  DELAY
       MOV   A,31H          ;D2数据值加上74138扫描值
       ADD   A,#10H         ;显示D2
       MOV   P0,A           ;扫描延时
       CALL  DELAY
       MOV   A,30H          ;D1数据值加上74138扫描值
       ADD   A,#00H         ;显示D1
       MOV   P0,A           ;扫描延时
       CALL  DELAY
       RET
DELAY: MOV   R7,#06
D1:    MOV   R6,#248
       DJNZ  R6,$
       DJNZ  R7,D1
       RET
;MAIN:  LCALL FIRST
 ;      ACALL D50S
  ;     ACALL ISDCLR
;FIRST: LCALL ISDCLR
 ;      MOV   R4,#00H
  ;     LCALL SPEAKER
   ;    RET
;SPEAKER:MOV  DPTR,#0A0H
 ;       MOV  A,R4
  ;      ORL  A,#080H
   ;     MOVX @DPTR,A
    ;    ACALL D50S
     ;   ANL   A,#3FH
      ;  MOVX  @DPTR,A
       ; RET
;ISDCLR: MOV    DPTR,#0A0H
 ;       ORL    A,#40H
  ;      MOVX   @DPTR,A
   ;     LCALL  D50S
;D50S:   MOV    R6,#100
;SD:     MOV    R7,#248
 ;       DJNZ   R7,$
  ;      DJNZ   R6,SD
   ;     RET
;D4S:    MOV    R5,#8
;DE1:    ACALL  D50S
 ;       DJNZ   R5,DE1
  ;      RET

TABLE: DB    01H,02H,03H    ;键盘码
       DB    04H,05H,06H
       DB    07H,08H,09H
       DB    0AH,00H,0BH
       END
