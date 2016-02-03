       ORG      0000H
       MOV      SP,#70       ;设置堆栈
       MOV      SCON,#50H    ;UART工作在MODE1
       MOV      TMOD,#20H    ;TIMER1工作在MODE2
       MOV      TH1,#0F3H    ;波特率为2400
       SETB     TR1          ;启动TIMER1
START: ORL      P2,#0FFH     ;电锁不动作
       MOV      R4,#06H      ;清除键盘显示器地址30H~35H
       MOV      R0,#30H
CLEAR: MOV      @R0,#00H
       INC      R0
       DJNZ     R4,CLEAR
L1:    JBC     RI,UART      ;是否有接收信号？如有RI=1
       CALL     DISP
       JMP      L1
UART:  MOV      A,SBUF      ;将接收的数据存入累加器
       MOV      R7,A
       XRL      A,#0AH       ;是否为比较码“0AH”，是则比较密码
       JZ       COMP
       MOV      A,R7
       XRL      A,#0BH       ;是否为清除码“0BH”，是则清除为“000000”
       JZ       START
       MOV      A,R7         ;不是“0AH”或“0BH”，就是数字码
       XCH      A,30H        ;将数字码存入（30H）
       XCH      A,31H        ;旧（30H）值存入（31H）
       XCH      A,32H        ;旧（31H）值存入（32H）
       XCH      A,33H        ;旧（32H）值存入（33H）
       XCH      A,34H        ;旧（33H）值存入（34H）
       XCH      A,35H        ;旧（34H）值存入（35H）
       CALL     DISP         ;调用显示子程序
       JMP      L1
DISP:  MOV      A,35H        ;D6数据值加上74138扫描值
       ADD      A,#50H       ;显示D6
       MOV      P0,A         ;扫描延时
       CALL     DELAY
       MOV      A,34H        ;D5数据值加上74138扫描值
       ADD      A,#40H       ;显示D5
       MOV      P0,A         ;扫描延时
       CALL     DELAY
       MOV      A,33H        ;D4数据值加上74138扫描值
       ADD      A,#30H       ;显示D4
       MOV      P0,A         ;扫描延时
       CALL     DELAY
       MOV      A,32H        ;D3数据值加上74138扫描值
       ADD      A,#20H       ;显示D3
       MOV      P0,A         ;扫描延时
       CALL     DELAY
       MOV      A,31H        ;D2数据值加上74138扫描值
       ADD      A,#10H       ;显示D2
       MOV      P0,A         ;扫描延时
       CALL     DELAY
       MOV      A,30H        ;D1数据值加上74138扫描值
       ADD      A,#00H       ;显示D1
       MOV      P0,A         ;扫描延时
       CALL     DELAY
       RET
COMP:                        ;比较按键值与密码值
       MOV      R0,#35H
       MOV      R2,#06H      ;比较6个码
       MOV      R7,#00       ;TABLE密码取值指针
X4:    MOV      A,R7
       MOV      DPTR,#TABLE  ;数据指针指到TABLE
       MOVC     A,@A+DPTR    ;至TABLE取密码值
       XRL      A,@R0        ;与显示值比较
       JNZ      X7           ;不相同则跳至START清除
       DEC      R0           ;比较下一个码
       INC      R7
       DJNZ     R2,X4        ;六个码比较完毕了?
       MOV      P2,#0FEH   ;令电锁动作
       MOV      R2,#200    ;0.1秒
X6:    MOV      R6,#248
       DJNZ     R6,$
       DJNZ     R2,X6
X7:    JMP      START
DELAY: MOV      R7,#06     ;显示器扫描时间
D1:    MOV      R6,#248
       DJNZ     R6,$
       DJNZ     R7,D1
       RET
TABLE: DB       02H,02H,01H,05H,08H,02H
       END


