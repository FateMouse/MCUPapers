  CONFIG12 EQU 7FH
  TEMPH EQU 21H
  TEMPL EQU 20H
  REG2 EQU 22H
  REG3 EQU 23H
  REG4 EQU 24H
  DAT EQU P0.7
  SCLK  EQU P3.4
  IO   EQU P3.3
  RST  EQU P3.2
  year DATA 66H
  month DATA 65H
  week DATA 64H
  day  DATA 63H
  hour DATA 62H
  mintue DATA 61H
  second DATA 60H

  ORG 0000H
  LJMP  START
  ORG 001BH
  LJMP INTT1

START:             ;初值
  LCALL ZJ
  SETB EA
  MOV TMOD,#10H    ;计数器1，方式1
  MOV TL1,#00H
  MOV TH1,#00H
  MOV 32H,#8EH
  MOV 31H,#00H     ;允许写1302
  LCALL WRITE
  MOV 32H,#90H
  MOV 31H,#0A6H   ;1302充电，充电电流1.1MA
  LCALL WRITE
  ;主程序~~~~~~~~~~~~~~~~~~~~~
MAIN1:
  MOV 32H,#8DH    ;读出年
  LCALL  READ
  MOV year,31H

  MOV 32H,#8BH   ;读出星期
  LCALL READ
  MOV week,31H

  MOV 32H,#89H   ;读出月
  LCALL READ
  MOV month,31H

  MOV 32H,#87H  ;读出日
  LCALL READ
  MOV day,31H

  MOV 32H,#85H  ;读出小时
  LCALL READ
  MOV hour,31H

  MOV 32H,#83H  ;读出分钟
  LCALL READ
  MOV mintue,31H

  MOV 32H,#81H  ;读出秒
  LCALL READ
  MOV second,31H
  ;~~~~~~~~~~~~分离缓存~~~~~~~~
  MOV R0,year    ;年分离，送显示缓存
  LCALL DIVIDE
  MOV 7BH,R1
  MOV 4BH,R1
  MOV 7CH,R2
  MOV 4CH,R2
  MOV 78H,week
  MOV 48H,week
  MOV R0,month  ;月分离，送显示缓存
  LCALL DIVIDE
  MOV 79H,R1
  MOV 49H,R1
  MOV 7AH,R2
  MOV 4AH,R2
  MOV R0,day   ;日分离，送显示缓存
  LCALL DIVIDE
  MOV 76H,R1
  MOV 46H,R1
  MOV 77H,R2
  MOV 47H,R2
  MOV R0,hour ;小时分离，送显示缓存
  LCALL DIVIDE
  MOV 74H,R1
  MOV 44H,R1
  MOV 75H,R2
  MOV 45H,R2
  MOV R0,mintue ;分钟分离，送显示缓存
  LCALL DIVIDE
  MOV 72H,R1
  MOV 42H,R1
  MOV 73H,R2
  MOV 43H,R2
  MOV R0,second  ;秒分离，送显示缓存
  LCALL  DIVIDE
  MOV 70H,R1
  MOV 40H,R1
  MOV 71H,R2
  MOV 41H,R2
  CLR EA
  LCALL TOUTOU
  LCALL NS
  SETB EA
  LCALL DISPLAY
  LCALL GENGXIAN    ;更新农历程序
  JNB P0.1,SETG111
  JNB F0,SSS
  CLR P0.4         ;非闰月，则p0.4清零,指示灯亮
  LJMP MAIN1
SETG111:
  LJMP SETG
SSS:
  
  SETB P0.4          ;闰月，则p0.4置位，指示灯不亮
  LJMP MAIN1

;~~~~~~~~~~~~~~~~~~~~~~~~~  温度

TOUTOU:
  LCALL CHUSHI
  LCALL RDTEMP
  MOV A,TEMPL
  ANL A,#11110000B
  MOV TEMPL,A
  MOV A,TEMPH
  ANL A,#00000111B
  ORL A,TEMPL
  SWAP A
  MOV 25H,A
  MOV A,25H
  MOV B,#64H
  DIV AB
  MOV A,B
  MOV B,#0AH
  DIV AB
  SWAP A
  ORL A,B
  MOV 10H,A
  RET
CHUSHI:
  LCALL RESET
  MOV A,#0CCH
  LCALL WRITE111
  MOV A,#4EH
  LCALL WRITE111
  MOV A,#CONFIG12
  LCALL WRITE111
  RET
RDTEMP:
  LCALL RESET
  MOV A,#0CCH
  LCALL WRITE111
  MOV A,#44H
  LCALL WRITE111
  LCALL DL1MS
  LCALL RESET
  MOV A,#0CCH
  LCALL WRITE111
  MOV A,#0BEH
  LCALL WRITE111
  LCALL ERAD111
  MOV TEMPL,A
  LCALL ERAD111
  MOV TEMPH,A
  RET
RESET:
LA:
  SETB DAT
  MOV 52H,#200
LB:
  CLR DAT
  DJNZ 52H,LB
  SETB DAT
  MOV 52H,#30
LC:
  DJNZ 52H,LC
  CLR C
  ORL C,DAT
  JC LB
  MOV 58H,#80
LD:
  ORL C,DAT
  JC LP
  DJNZ 58H,LD
  SJMP LA
LP:
  MOV 52H,#250
LF:
  DJNZ 52H,LF
  RET
WRITE111:
  MOV 53H,#8
W51HA:
  SETB DAT
  MOV 54H,#8
  RRC A
  CLR DAT
W52HA:
  DJNZ 54H,W52HA
  MOV DAT,C
  MOV 54H,#30
W53HA:
  DJNZ 54H,W53HA
  DJNZ 53H,W51HA
  SETB DAT
  RET
ERAD111:
  CLR EA
  MOV 58H,#8
RD1A:
  CLR DAT
  MOV 54H,#6
  NOP
  SETB DAT
RD2A:
  DJNZ 54H,RD2A
  MOV C,DAT
  RRC A
  MOV 55H,#30
RD3A:
  DJNZ 55H,RD3A
  DJNZ 58H,RD1A
  SETB DAT
  RET


;公历设置程序~~~~~~

SETG :
  SETB TR1
  SETB ET1
  MOV 32H,#8EH
  MOV 31H,#00H      ;允许写1302
  LCALL WRITE
  MOV 32H,#80H
  MOV 31H,#80H      ;1302停止振荡
  LCALL WRITE
GWAIT:           ;~
  LCALL DISPLAY
  JNB P0.1,GWAIT
SETG1:
  LCALL DISPLAY
  JNB P0.1,SETG2
  JNB P0.2,GADDYEAR
  JNB P0.3,JIANYEAR
  AJMP SETG1
GADDYEAR:
  MOV R7,66H      ;年加一
  LCALL ADD1
  MOV 66H,A
  CJNE A,#51H,GADDYEAR1
  MOV 66H,#00H
  AJMP GADDYEAR1
JIANYEAR:
  MOV R7,66H      ;年减一
  LCALL JIAN1
  MOV 66H,A
  CJNE A,#00H,GADDYEAR1
  MOV 66H,#51H
GADDYEAR1:
  MOV 32H,#8CH    ;年值送人1302
  MOV 31H,66H
  LCALL WRITE
  MOV R0,66H
  LCALL DIVIDE    ;年分离送显示缓存
  MOV 4BH,R1
  MOV 7BH,R1
  MOV 4CH,R2
  MOV 7CH,R2
WAITT1:          ;~~~~~~~
  LCALL DISPLAY
  JNB P0.2,WAITT1
  JNB P0.3,WAITT1
  AJMP SETG1
SETG2:
  SETB 0AH         ;调月时闪标志
GWAIT2:
  LCALL DISPLAY
  JNB P0.1,GWAIT2
SETG3:
  LCALL DISPLAY
  JNB P0.1,SETG4
  JNB P0.2,GADDMONTH
  JNB P0.3,JIANMONTH
  AJMP SETG3
GADDMONTH:
  MOV R7,65H     ;月加一
  LCALL ADD1
  MOV 65H,A
  CJNE A,#13H,GADDMONTH1
  MOV 65H,#01H
  AJMP GADDMONTH1
JIANMONTH:
  MOV R7,65H     ;月减一
  LCALL JIAN1
  MOV 65H,A
  CJNE A,#00H,GADDMONTH1
  MOV 65H,#12H
GADDMONTH1:
  MOV 32H,#88H  ;月值送人1302
  MOV 31H,65H
  LCALL WRITE
  MOV R0,65H
  LCALL DIVIDE  ;月分离，送显示缓存
  MOV 79H,R1
  MOV 49H,R1
  MOV 7AH,R2
  MOV 4AH,R2
WAITT2:            ;~
  LCALL DISPLAY
  JNB P0.2,WAITT2
  JNB P0.3,WAITT2
  AJMP SETG3
SETG4:
  SETB 0BH    ;调日时闪标志
GWAIT4:
  LCALL DISPLAY
  JNB P0.1,GWAIT4
SETG5:
  LCALL DISPLAY
  JNB P0.1,SETG6
  JNB P0.2,GADDDAY
  JNB P0.3,JIANDAY
  AJMP SETG5
GADDDAY:
  MOV R7,63H     ;日加一
  LCALL ADD1
  MOV 63H,A
  CJNE A,#32H,GADDDAY1
  MOV  63H,#01H
JIANDAY:
  MOV R7,63H     ;日减一
  LCALL JIAN1
  MOV 63H,A
  CJNE A,#00H,GADDDAY1
  MOV  63H,#31H
GADDDAY1:
  MOV 32H,#86H ;日值送人1302
  MOV 31H,63H
  LCALL WRITE
  MOV R0,63H
  LCALL DIVIDE  ;日分离，送显示缓存
  MOV 76H,R1
  MOV 46H,R1
  MOV 77H,R2
  MOV 47H,R2
WAITT3:              ;~~~
  LCALL DISPLAY
  JNB P0.2,WAITT3
  JNB P0.3,WAITT3
  AJMP SETG5
SETG6:
  SETB 0CH    ;调星期时闪标志
GWAIT6:
  LCALL DISPLAY
  JNB P0.1,GWAIT6
SETG7:
  LCALL DISPLAY
  JNB P0.1,SETG8
  JNB P0.2,GADDWEEK
  JNB P0.3,JIANWEEK
  AJMP SETG7
GADDWEEK:
  MOV R7,64H       ;星期加一
  LCALL ADD1
  MOV 64H,A
  CJNE A,#07H,GADDWEEK1
  MOV  64H,#00H
  AJMP GADDWEEK1
JIANWEEK:
  MOV R7,64H       ;星期减一
  LCALL JIAN1
  MOV 64H,A
  CJNE A,#00H,GADDWEEK1
  MOV  64H,#06H
GADDWEEK1:
  MOV 32H,#8AH
  MOV 31H,64H     ;星期值送人1302
  LCALL WRITE
  MOV R0,64H
  LCALL DIVIDE     ;星期值分离送显示缓存
  MOV 48H,R1
  MOV 78H,R1
WAITT4:                ;~~~~
  LCALL DISPLAY
  JNB P0.2,WAITT4
  JNB P0.3,WAITT4
  AJMP SETG7
SETG8:
  SETB 0DH       ;调小时时闪标志
GWAIT8:
  LCALL DISPLAY
  JNB P0.1,GWAIT8
SETG9:
  LCALL DISPLAY
  JNB P0.1,SETG10
  JNB P0.2,GADDHOUR
  JNB P0.3,JIANHOUR
  AJMP SETG9
GADDHOUR:
  MOV R7,62H        ;小时加一
  LCALL ADD1
  MOV 62H,A
  CJNE A,#24H,GADDHOUR1
  MOV 62H,#00H
  AJMP GADDHOUR1
JIANHOUR:
  MOV R7,62H        ;小时减一
  LCALL JIAN1
  MOV 62H,A
  CJNE A,#00H,GADDHOUR1
  MOV 62H,#23H
GADDHOUR1:
  MOV 32H,#84H     ;小时值送人1302
  MOV 31H,62H
  LCALL WRITE
  MOV R0,62H
  LCALL DIVIDE      ;小时值分离送显示缓存
  MOV 74H,R1
  MOV 44H,R1
  MOV 75H,R2
  MOV 45H,R2
WAITT5:              ;~~~~~
  LCALL DISPLAY
  JNB P0.2,WAITT5
  JNB P0.3,WAITT5
  AJMP SETG9
SETG10:
  SETB 0EH        ;调分时候闪标志
GWAIT10:
  LCALL DISPLAY
  JNB P0.1,GWAIT10
SETG11:
  LCALL DISPLAY
  JNB P0.1,SETGOUT
  JNB P0.2,GADDMINTUE
  JNB P0.3,JIANMINTUE
  AJMP SETG11
GADDMINTUE:
  MOV R7,61H      ;分钟加一
  LCALL ADD1
  MOV 61H,A
  CJNE A,#60H,GADDMINTUE1
  MOV 61H,#00H
  AJMP GADDMINTUE1
JIANMINTUE:
  MOV R7,61H      ;分钟减一
  LCALL JIAN1
  MOV 61H,A
  CJNE A,#00H,GADDMINTUE1
  MOV 61H,#59H
GADDMINTUE1:
  MOV 32H,#82H    ;分钟值送人1302
  MOV 31H,61H
  LCALL WRITE
  MOV R0,61H
  LCALL DIVIDE    ;分钟值分离送显示缓存
  MOV 72H,R1
  MOV 42H,R1
  MOV 73H,R2
  MOV 43H,R2
WAITT6:
  LCALL DISPLAY
  JNB P0.2,WAITT6
  JNB P0.3,WAITT6
  AJMP SETG11

SETGOUT:
  LCALL DISPLAY
  JNB P0.1,SETGOUT
  LCALL GENGXIAN
  MOV 32H,#80H
  MOV 31H,#00H     ;1302晶振开始振荡
  LCALL  WRITE
  MOV 32H,#8EH
  MOV 31H,#80H     ;禁止写入1302
  LCALL  WRITE
  CLR 08H
  CLR 09H
  CLR 0AH
  CLR 0BH
  CLR 0CH
  CLR 0DH
  CLR 0EH
  CLR 0FH
  CLR ET1                 ;关闪中断
  CLR TR1
  LJMP MAIN1

;;闪动调时程序~~~~~~~~~~~~~~~~~~~~~~~~~~~
INTT1:
  PUSH ACC
  PUSH PSW
GFLASH:
  CPL 0FH
  JB 0FH,GFLASH1
  MOV 7CH,4CH  ;全部显示
  MOV 7BH,4BH
  MOV 7AH,4AH
  MOV 79H,49H
  MOV 78H,48H
  MOV 77H,47H
  MOV 76H,46H
  MOV 75H,45H
  MOV 74H,44H
  MOV 73H,43H
  MOV 72H,42H
  MOV 71H,41H
  MOV 70H,40H
GFLASHOUT:
  POP PSW
  POP ACC
  RETI
GFLASH1:
  JB 0AH,GFLASH2 ;调年闪
  MOV 7CH,#0FH
  MOV 7BH,#0FH
  AJMP GFLASHOUT
GFLASH2:
  JB 0BH,GFLASH3 ;调月闪
  MOV 7AH,#0FH
  MOV 79H,#0FH
  AJMP GFLASHOUT
GFLASH3:
  JB 0CH,GFLASH4 ;调日闪
  MOV 77H,#0FH
  MOV 76H,#0FH
  AJMP GFLASHOUT
GFLASH4:
  JB 0DH,GFLASH5 ;调星期闪
  MOV 78H,#0FH
  AJMP GFLASHOUT
GFLASH5:
  JB 0EH,GFLASH6 ;调小时闪
  MOV 75H,#0FH
  MOV 74H,#0FH
  AJMP GFLASHOUT
GFLASH6:
  
  MOV 73H,#0FH  ;调分钟闪
  MOV 72H,#0FH
  AJMP GFLASHOUT

;加一程序~~~~~~~~~~~~~~~~~~~~~~~~~

ADD1:
  MOV A,R7
  ADD A,#1
  DA A
  RET
;减一程序~~~~~~~~~~~~~~~~~~~~~~~~~
JIAN1:
  MOV A,R7
  DEC A
  CJNE A,#4FH,KK1
  MOV A,#49H
KK1:
  CJNE A,#3FH,KK2
  MOV A,#39H
KK2:
  CJNE A,#2FH,KK3
  MOV A,#29H
KK3:
  CJNE A,#1FH,KK4
  MOV A,#19H
KK4:
  CJNE A,#0FH,KK5
  MOV A,#09H
KK5:
  RET

;分离程序~~~~~~~~~~~~~~~~~~~~~~~~~

DIVIDE:
  MOV A,R0
  ANL A,#0FH
  MOV R1,A
  MOV A,R0
  SWAP A
  ANL A,#0FH
  MOV R2,A
  RET

;写1302程序~~~~~~~

WRITE:
  CLR SCLK
  NOP
  SETB RST
  NOP
  MOV A,32H
  MOV R4,#8
WRITE1:
  RRC A     ;送地址给1302
  NOP
  NOP
  CLR SCLK
  NOP
  NOP
  NOP
  MOV IO,C
  NOP
  NOP
  NOP
  SETB SCLK
  NOP
  NOP
  DJNZ R4,WRITE1
  CLR SCLK
  NOP
  MOV A,31H
  MOV R4,#8
WRITE2:
  RRC A
  NOP     ;送数据给1302
  CLR SCLK
  NOP
  NOP
  MOV IO,C
  NOP
  NOP
  NOP
  SETB SCLK
  NOP
  NOP
  DJNZ R4,WRITE2
  CLR RST
  RET

;读1302程序~~~~~~~~~~~~~~~~~~~~~~~~~

READ:
  CLR SCLK
  NOP
  NOP
  SETB RST
  NOP
  MOV A,32H
  MOV R4,#8
READ1:
  RRC A    ;送地址给1302
  NOP
  MOV IO,C
  NOP
  NOP
  NOP
  SETB SCLK
  NOP
  NOP
  NOP
  CLR SCLK
  NOP
  NOP
  DJNZ R4,READ1
  MOV R4,#8
READ2:
  CLR SCLK
  NOP    ;从1302中读出数据
  NOP
  NOP
  MOV C,IO
  NOP
  NOP
  NOP
  NOP
  NOP
  RRC A
  NOP
  NOP
  NOP
  NOP
  SETB SCLK
  NOP
  DJNZ R4,READ2
  MOV 31H,A
  CLR RST
  RET
;BCD码转换为10进制程序~~~~~

BCD_10:
  MOV A,R0
  ANL A,#0FH
  MOV R1,A  ;高位×10， 加低位
  MOV A,R0
  SWAP A
  ANL A,#0FH
  MOV B,#10
  MUL AB
  ADD A,R1
  MOV R0,A
  RET

;查一年数据程序~~~~~~~~~~~~~~~~

CHECKMONTH:
  LCALL BCD_10
  MOV A,R0
  MOV B,#04
  MUL AB
  MOV R1,A
  MOV DPTR,#TAB
  MOVC A,@A+DPTR
  MOV R7,A   ;第一字节送R7
  INC R1
  MOV A,R1
  MOVC A,@A+DPTR
  MOV R6,A  ;第二字节送R6
  INC R1
  MOV A,R1
  MOVC A,@A+DPTR
  MOV R5,A   ;第三字节送R6
  INC R1
  MOV A,R1
  MOVC A,@A+DPTR
  MOV R4,A  ;第四字节送R4
  RET



;;;;;自动更新农历;;;
                        ;;;;;;;;;;;;;;;;;;;;
              GENGXIAN:    MOV R2,#00H
	                   MOV R3,#00H
                           MOV A,month
                           CJNE A,#01H,GM2
                           MOV R0,day   ;当前月为一月
                           LCALL BCD_10 ;当前日转换为10进制，送R2
                           MOV A,R0
                           MOV R2,A
                           AJMP TIAOZHENG1
                   GM2:  CJNE A,#02H,GM3
                           MOV R0,day    ;当前月为二月
                           LCALL BCD_10 ;;当前日转换为10进制，
                           MOV A,R0      ;再加31，送R2
                           ADD A,#31
                           MOV R2,A
                           AJMP TIAOZHENG1
                    GM3: CJNE A,#03H,GM4
                           MOV R0,day    ;当前月为三月
                           LCALL BCD_10  ;当前日转换为10进制，
                           MOV A,R0      ;再加59，送R2
                           ADD A,#59
                           MOV R2,A
                           AJMP TIAOZHENG1
                   GM4:  CJNE A,#04H,GM5
                           MOV R0,day     ;当前月为四月
                           LCALL BCD_10   ;;当前日转换为10进制,
                           MOV A,R0       ;再加90，送R2
                           ADD A,#90
                           MOV R2,A
                           AJMP TIAOZHENG1
                    GM5: CJNE A,#05H,GM6
                           MOV R0,day     ;当前月为五月
                           LCALL BCD_10   ;当前日转换为10进制，
                           MOV A,R0       ;再加120，送R2
                           ADD A,#120
                           MOV R2,A
                           AJMP TIAOZHENG1
                    GM6: CJNE A,#06H,GM7
                           MOV R0,day     ;当前月为六月
                           LCALL BCD_10   ;当前日转换为10进制，
                           MOV A,R0       ;再加151，送R2
                           ADD A,#151
                           MOV R2,A
                           AJMP TIAOZHENG1
                    GM7: CJNE A,#07H,GM8
                           MOV R0,day     ;当前月位七月
                           LCALL BCD_10   ;当前日转换为10进制，
                           MOV A,R0       ;再加181，送R2
                           ADD A,#181
                           MOV R2,A
                           AJMP TIAOZHENG1
                     GM8:CJNE A,#08H,GM9
                           MOV R0,day     ;当前月为八月
                           LCALL BCD_10   ;当前日转换为10进制,
                           MOV A,R0       ;再加212，送R2
                           ADD A,#212
                           MOV R2,A
                           AJMP TIAOZHENG1
                     GM9:CJNE A,#09H,GM10
                           MOV R0,day    ;当前月为九月
                           LCALL BCD_10  ;当前日转换为10进制,
                           MOV A,R0      ;再加243
                           CLR C
                           ADD A,#243
                           JC GGG
                           MOV R2,A       ;A没有溢出，送R2
                           AJMP TIAOZHENG1
                   GGG:  MOV R3,#0FFH   ;A溢出，A加一送R2
                           INC A          ;R3中送#0ffh
                           MOV R2,A
                           AJMP TIAOZHENG1
                   GM10: CJNE A,#10H,GM11
                           MOV R0,day    ;当前月为10月
                           LCALL BCD_10   ;当前日转换为10进制,
                           MOV A,R0       ;再加18，送R2
                           ADD A,#18      ;R3中送＃0FFH
                           MOV R2,A
                           MOV R3,#0FFH
                           AJMP TIAOZHENG1
                    GM11:CJNE A,#11H,GM12
                           MOV R0,day    ;当前月为11月
                           LCALL BCD_10  ;当前日转换为10进制,
                           MOV A,R0      ;再加49，送R2
                           ADD A,#49     ;R3中送＃0FFH
                           MOV R2,A
                           MOV R3,#0FFH
                           AJMP TIAOZHENG1
                   GM12: MOV R0,day     ;当前月为12月
                           LCALL BCD_10   ;当前日转换为10进制,
                           MOV A,R0       ;再加79，送R2
                           ADD A,#79      ;R3中送＃0FFH
                           MOV R2,A
                           MOV R3,#0FFH
                           AJMP TIAOZHENG1
            TIAOZHENG1: MOV A,year
                           MOV B,#04
                           DIV AB
                           MOV A,B
                           JNZ GGG1
                           MOV A,65H   ;当前年为闰年
                           CJNE A,#01H,AAAA
                           AJMP GGG1        ;当前月是1
                AAAA:   CJNE A,#02H,BBBB
                           AJMP GGG1       ;当前月是2
                BBBB:   CJNE  R2,#0FFH,GGG2
                           MOV R3,#0FFH   ;当前月不是1和2，
                           MOV R2,#01H    ;R1和R2总和加一
                           AJMP GGG1
                GGG2:   INC R2
                GGG1:   MOV R0,year    ;查一年数据
                           LCALL CHECKMONTH
                           MOV A,R2
                           CLR C
                           SUBB A,R7
                           MOV P2.7,C
                           CJNE A,#01H,GGG3
                           MOV R2,#01H
                           MOV A,R3
                           CJNE A,#00H,NEW1
                           MOV  57H,#01H   ;R2和R3总和减R7
                           MOV  56H,#01H   ;为0，则为春节
                           LJMP S_PLAY
                  GGG3:  CJNE A,#00H,GGG6
                           MOV R2,A
                           AJMP OLD
                  GGG6: JNB P2.7,NEW2
                           MOV A,R7
                           CLR C
                           SUBB A,R2
                           MOV R7,A
                           CJNE R3,#0FFH,GGG5
                           MOV A,R3
                           CLR C
                           SUBB A,R7
                           MOV R2,A
                           MOV R3,#00H
                           AJMP NEW
                  GGG5:  MOV A,R7
                           MOV R2,A
                           AJMP OLD
                   NEW1: MOV R2,#0FFH
                           MOV R3,#01H
                           AJMP NEW
                   NEW2: MOV R2,A
                           MOV A,R3
                           CJNE A,#0FFH,GGG4
                           MOV A,R2
                           MOV R3,A
                           MOV R2,#0FFH
                   GGG4: AJMP NEW

  ;OLD 农历为公历的前一年

                 OLD:    MOV A,year
                           DEC A
                           MOV R0,A
                           LCALL CHECKMONTH
                           MOV A,R2
                           CLR C
                           SUBB A,#29
                           MOV P2.7,C
                           MOV R6,A
                           MOV A,R5
                           JB ACC.0,AAA ;12月为小月，转到AAA
                           MOV A,R2
                           CLR C
                           SUBB A,#30
                           MOV P2.7,C
                           MOV R6,A
                     AAA:MOV A,R6
                           CJNE A,#00H,BBB
                           MOV 56H,#29H ;为0，则为11月最后一天
                           MOV A,R5    ;小月为11月29
                           JB ACC.1,CCC
                           MOV 56H,#30H  ;大月为11月30
                     CCC:MOV 57H,#11H
                           LJMP S_PLAY
                     BBB:JNB P2.7, DDD
                           MOV A,#29  ; CY位置位，位12月
                           CLR C
                           SUBB A,R2
                           MOV R4,A
                           MOV A,R5
                           JB ACC.0,EEE
                           MOV A,#30
                           CLR C
                           SUBB A,R2
                           MOV R4,A
                    EEE: MOV A,R4
                           MOV R0,A
                           LCALL D_BCD
                           MOV 56H,A
                           MOV 57H,#12H
                           LJMP S_PLAY
                    DDD: MOV A,#29 ;CY为0，为11月
                           CLR C
                           SUBB A,R4
                           MOV R1,A
                           MOV A,R5
                           JB ACC.1, FFF
                           MOV A,#30
                           CLR C
                           SUBB A,R4
                           MOV R1,A
                   FFF:   MOV A,R1
                           MOV R0,A
                           LCALL D_BCD
                           MOV 56H,A
                           MOV 57H,#11H
                           LJMP S_PLAY
 ;NEW此时R2中的值为FFH时
 ; R3有值，否则为0
NEW:
  NOP
M1:
  MOV A,R2   ;R2减一月天数
  CLR C
  SUBB A,#29
  MOV R1,A
  MOV A,R6
  JB ACC.6,SM11
  MOV A,R2
  CLR C
  SUBB A,#30
  MOV R1,A
SM11:
  JC SM12
  MOV A,R1  ;R2减1月天数，够减
  MOV R2,A  ;转二月
  AJMP M2
SM12:
  CJNE R3,#00H,M13 ;R2减1月天数
  LJMP Y1           ;不够减，判R3为0否
M13:
  MOV A,R2          ;不为0，R3加到R2中
  ADD A,R3          ;再让一月减
  MOV R2,A          ;还不够，则转Y1
  MOV R3,#00H
  AJMP M1
M2:
  CLR C    ;R2减一月天数，够减
  MOV A,R2 ;转三月
  SUBB A,#29
  MOV R1,A
  MOV A,R6
  JB ACC.5,M21
  MOV A,R2
  CLR C
  SUBB A,#30
  MOV R1,A
M21:
  JC M22
  MOV A,R1  ;R2减2月天数，够减
  MOV R2,A
  AJMP MM2
M22:
  CJNE R3,#00H,M23  ;R2减2月天数
  LJMP Y2         ;不够减，判，R3为0否
M23:
  MOV A,R2        ;不为0，R3加到R2中
  ADD A,R3        ;再让二月减
  MOV R2,A        ;还不够，则转Y2
  MOV R3,#00H
  AJMP M2
MM2:
  LCALL CHECKRE   ;查2月，如果不为闰月
  CJNE A,#02H,M3  ;转3月
RM2:
  MOV A,R4
  ANL A,#0FH
  JNZ RM21
  MOV A,R2
  CLR C
  SUBB A,#30
  MOV R1,A
  AJMP RM22
RM21:
  MOV A,R2
  CLR C
  SUBB A,#29
  MOV R1,A
RM22:
  JC RM23
  MOV A,R1  ;R2减闰2月天数，够减
  MOV R2,A   ;转3月
  AJMP M3
RM23:
  CJNE R3,#00H,RM24 ;R2减闰2月天数
  LJMP RY2          ;不够减，判，R3为0否
RM24:
  MOV A,R2          ;不为0，R3加到R2中
  ADD A,R3          ;再让闰2月减
  MOV R3,#00H       ;还不够，则转RY2
  AJMP RM2
M3:
  MOV A,R2       ;R2减3月天数
  CLR C
  SUBB A,#29
  MOV R1,A
  MOV A,R6
  JB ACC.4,M31
  CLR C
  MOV A,R2
  SUBB A,#30
  MOV R1,A
M31:
  JC M32
  MOV A,R1    ;R2减3月天数，够减
  MOV R2,A
  AJMP MM3
M32:
  CJNE R3,#00H,M33  ;R2减3月天数
  LJMP Y3           ;不够减，判，R3为0否
M33:
  MOV A,R2           ;不为0，R3加到R2中
  ADD A,R3           ;再让3月减
  MOV R2,A            ;还不够，则转Y3
  MOV R3,#00H
  AJMP M3
MM3:
  LCALL CHECKRE    ;查3月，如果不为闰月
  CJNE A,#03H,M4   ;转4月
RM3:
  MOV A,R4
  ANL A,#0FH     ;R2减闰3月天数
  JNZ RM31
  MOV A,R2
  CLR C
  SUBB A,#30
  MOV R1,A
  AJMP RM32
RM31:
  MOV A,R2
  CLR C
  SUBB A,#29
  MOV R1,A
RM32:
  JC RM33
  MOV A,R1  ;R2减闰3月天数，够减
  MOV R2,A  ;转4月
  AJMP M4
RM33:
  CJNE R3,#00H,RM34 ;R2减闰3月天数
  LJMP RY3          ;不够减，判，R3为0否
RM34:
  MOV A,R2          ;不为0，R3加到R2中
  ADD A,R3            ;再让闰3月减
  MOV R2,A           ;还不够，则转RY3
  MOV R3,#00H
  AJMP RM3
M4:
  MOV A,R2
  CLR C           ;R2减4月天数
  SUBB A,#29
  MOV R1,A
  MOV A,R6
  JB ACC.2,M41
  CLR C
  MOV A,R2
  SUBB A,#30
  MOV R1,A
M41:
  JC M42
  MOV A,R1   ;R2减4月天数，够减
  MOV R2,A
  AJMP MM4
M42:
  CJNE R3,#00H,M43  ;R2减4月天数
  LJMP Y4           ;不够减，判，R3为0否
M43:
  MOV A,R2          ;不为0，R3加到R2中
  ADD A,R3            ;再让4月减
  MOV R2,A           ;还不够，则转Y4
  MOV R3,#00H
  AJMP M4
MM4:
  LCALL CHECKRE ;查4月，如果不为闰月
  CJNE A,#04H,M5 ;转5月
RM4:
  MOV A,R4
  ANL A,#0FH    ;R2减闰4月天数
  JNZ RM41
  MOV A,R2
  CLR C
  SUBB A,#30
  MOV R1,A
  AJMP RM42
RM41:
  MOV A,R2
  CLR C
  SUBB A,#29
  MOV R1,A
RM42:
  JC RM43
  MOV A,R1   ;R2减闰4月天数，够减
  MOV R2,A   ;转5月
  AJMP M5
RM43:
  CJNE R3,#00H,RM44  ;R2减闰4月天数
  LJMP RY4           ;不够减，判，R3为0否
RM44:
  MOV A,R2           ;不为0，R3加到R2中
  ADD A,R3           ;再让闰4月减
  MOV R2,A
  MOV R3,#00H        ;还不够，则转Y4
  AJMP RM4
M5:
  MOV A,R2        ;R2减5月天数
  CLR C
  SUBB A,#29
  MOV R1,A
  MOV A,R6
  JB ACC.1,M51
  MOV A,R2
  CLR C
  SUBB A,#30
  MOV R1,A
M51:
  JC M52
  MOV A,R1    ;R2减5月天数，够减
  MOV R2,A
  AJMP MM5
M52:
  CJNE R3,#00H,M53   ;R2减5月天数
  LJMP Y5           ;不够减，判，R3为0否
M53:
  MOV A,R2          ;不为0，R3加到R2中
  ADD A,R3          ;再让5月减
  MOV R2,A          ;还不够，则转Y5
  MOV R3,#00H
  LJMP M5
MM5:
  LCALL CHECKRE  ;查5月，如果不为闰月
  CJNE A,#05H,M6  ;转6月
RM5:
  MOV A,R4       ;R2减闰5月天数
  ANL A,#0FH
  JNZ RM51
  MOV A,R2
  CLR C
  SUBB A,#30
  MOV R1,A
  LJMP RM52
RM51:
  MOV A,R2
  CLR C
  SUBB A,#29
  MOV R1,A
RM52:
  JC RM53
  MOV A,R1   ;R2减闰5月天数，够减
  MOV R2,A   ;转6月
  LJMP M6
RM53:
  CJNE R3,#00H,RM54   ;R2减闰5月天数
  LJMP RY5            ;不够减，判，R3为0否
RM54:
  MOV A,R2            ;不为0，R3加到R2中
  ADD A,R3            ;再让5月减
  MOV R2,A            ;还不够，则转RY5
  MOV R3,#00H
  LJMP RM5
M6:
  MOV A,R2        ;R2减6月天数
  CLR C
  SUBB A,#29
  MOV R1,A
  MOV A,R6
  JB ACC.0,M61
  MOV A,R2
  CLR C
  SUBB A,#30
  MOV R1,A
M61:
  JC M62
  MOV A,R1  ;R2减6月天数，够减
  MOV R2,A
  LJMP MM6
M62:
  CJNE R3,#00H,M63   ;R2减6月天数
  LJMP Y6            ;不够减，判，R3为0否
M63:
  MOV A,R2           ;不为0，R3加到R2中
  ADD A,R3           ;再让6月减
  MOV R2,A           ;还不够，则转Y6
  MOV R3,#00H
  LJMP M6
MM6:
  LCALL CHECKRE   ;查6月，如果不为闰月
  CJNE A,#06H,M7  ;转7月
RM6:
  MOV A,R4
  ANL A,#0FH       ;R2减闰6月天数
  JNZ RM61
  MOV A,R2
  CLR C
  SUBB A,#30
  MOV R1,A
  LJMP RM62
RM61:
  MOV A,R2
  CLR C
  SUBB A,#29
  MOV R1,A
RM62:
  JC RM63
  MOV A,R1   ;R2减闰6月天数，够减
  MOV R2,A    ;转7月
  LJMP M7
RM63:
  CJNE R3,#00H,RM64   ;R2减闰6月天数
  LJMP RY6            ;不够减，判，R3为0否
RM64:
  MOV A,R2            ;不为0，R3加到R2中
  ADD A,R3            ;再让闰6月减
  MOV R2,A            ;还不够，则转RY6
  MOV R3,#00H
  LJMP RM6
M7:
  MOV A,R2      ;R2减7月天数
  CLR C
  SUBB A,#29
  MOV R1,A
  MOV A,R5
  JB ACC.6,M71
  MOV A,R2
  CLR C
  SUBB A,#30
  MOV R1,A
M71:
  JC M72
  MOV A,R1  ;R2减7月天数，够减
  MOV R2,A
  LJMP MM7
M72:
  CJNE R3,#00H,M73   ;R2减7月天数
  LJMP Y7            ;不够减，判，R3为0否
M73:
  MOV A,R2           ;不为0，R3加到R2中
  ADD A,R3           ;再让6月减
  MOV R2,A            ;还不够，则转Y7
  MOV R3,#00H
  LJMP M7
MM7:
  LCALL CHECKRE ;查7月，如果不为闰月
  CJNE A,#07H,M8 ;转8月
RM7:
  MOV A,R4
  ANL A,#0FH     ;R2减闰7月天数
  JNZ RM71
  MOV A,R2
  CLR C
  SUBB A,#30
  MOV R1,A
  LJMP RM72
RM71:
  MOV A,R2
  CLR C
  SUBB A,#29
  MOV R1,A
RM72:
  JC RM73
  MOV A,R1 ;R2减闰7月天数，够减
  MOV R2,A ;转8月
  LJMP M8
RM73:
  CJNE R3,#00H,RM74  ;R2减闰7月天数
  LJMP RY7           ;不够减，判，R3为0否
RM74:
  MOV A,R2           ;不为0，R3加到R2中
  ADD A,R3           ;再让闰7月减
  MOV R2,A            ;还不够，则转RY7
  MOV R3,#00H
  LJMP RM7
M8:
  MOV A,R2         ;R2减8月天数
  CLR C
  SUBB A,#29
  MOV R1,A
  MOV A,R5
  JB ACC.5,M81
  MOV A,R2
  CLR C
  SUBB A,#30
  MOV R1,A
M81:
  JC M82
  MOV A,R1   ;R2减8月天数，够减
  MOV R2,A   ;转9月
  LJMP M9
M82:
  CJNE R3,#00H,M83   ;R2减8月天数
  LJMP Y8            ;不够减，判，R3为0否
M83:
  MOV A,R2           ;不为0，R3加到R2中
  ADD A,R3            ;再让8月减
  MOV R2,A            ;还不够，则转Y8
  MOV R3,#00H
  LJMP M8
M9:
  MOV A,R2      ;R2减9月天数
  CLR C
  SUBB A,#29
  MOV R1,A
  MOV A,R5
  JB ACC.4,M91
  MOV A,R2
  CLR C
  SUBB A,#30
  MOV R1,A
M91:
  JC M92
  MOV A,R1   ;R2减9月天数，够减
  MOV R2,A
  LJMP MM9
M92:
  CJNE R3,#00H,M93   ;R2减9月天数
  LJMP Y9            ;不够减，判，R3为0否
M93:
  MOV A,R2           ;不为0，R3加到R2中
  ADD A,R3           ;再让9月减
  MOV R2,A            ;还不够，则转Y9
  MOV R3,#00H
  LJMP M9
MM9:
  LCALL CHECKRE  ;查9月，如果不为闰月
  CJNE A,#09H,M10  ;转10月
RM9:
  MOV A,R4         ;R2减闰9月天数
  ANL A,#0FH
  JNZ RM91
  MOV A,R2
  CLR C
  SUBB A,#30
  MOV R1,A
  LJMP RM92
RM91:
  MOV A,R2
  CLR C
  SUBB A,#29
  MOV R1,A
RM92:
  JC RM93
  MOV A,R1  ;R2减闰9月天数，够减
  MOV R2,A  ;转10月
  LJMP M10
RM93:
  CJNE R3,#00H,RM94  ;R2减闰9月天数
  LJMP RY9           ;不够减，判，R3为0否
RM94:
  MOV A,R2           ;不为0，R3加到R2中
  ADD A,R3           ;再让闰9月减
  MOV R2,A           ;还不够，则转RY9
  MOV R3,#00H
  LJMP RM9
M10:
  MOV A,R2       ;R2减10月天数
  CLR C
  SUBB A,#29
  MOV R1,A
  MOV A,R5
  JB ACC.2,M101
  MOV A,R2
  CLR C
  SUBB A,#30
  MOV R1,A
M101:
  JC M102
  MOV A,R1  ;R2减10月天数，够减
  MOV R2,A  ;转11月
  LJMP M11
M102:
  CJNE R3,#00H,M103     ;R2减10月天数
  LJMP Y10              ;不够减，判，R3为0否
M103:
  MOV A,R2              ;不为0，R3加到R2中
  ADD A,R3              ;再让10月减
  MOV R2,A              ;还不够，则转Y10
  MOV R3,#00H
  LJMP M10
M11:
  MOV A,R2          ;R2减11月天数
  CLR C
  SUBB A,#29
  MOV R1,A
  MOV A,R5
  JB ACC.1,M111
  MOV A,R2
  CLR C
  SUBB A,#30
  MOV R1,A
M111:
  JC M112
  MOV A,R1  ;R2减11月天数，够减
  MOV R2,A  ;转12月
  LJMP M12
M112:
  CJNE R3,#00H,M113   ;R2减11月天数
  LJMP Y11            ;不够减，判，R3为0否
M113:
  MOV A,R2            ;不为0，R3加到R2中
  ADD A,R3            ;再让11月减
  MOV R2,A            ;还不够，则转Y11
  MOV R3,#00H
  LJMP M11
M12:
  MOV A,R2      ;R2减12月天数
  CLR C
  SUBB A,#29
  MOV R1,A
  MOV A,R5
  JB ACC.0,M121
  CLR C
  MOV A,R2
  SUBB A,#30
  MOV R1,A
M121:
  CJNE R3,#00H,M122  ;R2减12月天数
  LJMP Y12           ;不够减，判，R3为0否
M122:
  MOV A,R2           ;不为0，R3加到R2中
  ADD A,R3           ;再让12月减
  MOV R2,A           ;还不够，则转Y12
  MOV R3,#00H
  LJMP M12
Y1:
  MOV A,R2
  MOV R0,A       ;R2中为日的值
  LCALL D_BCD
  MOV 56H,A
  MOV 57H,#01H
  CLR F0    ;非闰月
  LJMP S_PLAY
Y2:
  CJNE R2,#00H,Y21
  MOV A,R6      ;R2中为0，则为前一个月
  MOV 56H,#29H  ;的的最后一天
  JB ACC.6,Y22
  MOV 56H,#30H
Y22:
  MOV 57H,#01H
  CLR F0
  LJMP S_PLAY
Y21:
  MOV A,R2
  MOV R0,A     ;R2中为日的值
  LCALL D_BCD
  MOV 56H,A
  MOV 57H,#02H
  CLR F0
  LJMP S_PLAY
RY2:
  CJNE R2,#00H,RY21
  MOV 56H,#29H  ;R2中为0，则为前一个月
  MOV A,R6      ;的的最后一天
  JB ACC.5,RY22
  MOV 56H,#30H
RY22:
  MOV 57H,#02H
  CLR F0
  LJMP S_PLAY
RY21:
  MOV A,R2     ;R2中为日的值
  MOV R0,A
  LCALL D_BCD
  MOV 56H,A
  MOV 57H,#02H
  SETB F0    ;闰月
  LJMP S_PLAY
Y3:
  CJNE R2,#00H,Y31
  LCALL CHECKRE     ;查前一个月是否为闰月
  CJNE A,#02H,Y32
  MOV 56H,#29H      ;前一个月是闰月
  MOV A,R4
  ANL A,#0FH         ;R2中为0，则为前一个月
  JNZ Y33            ;的的最后一天
  MOV 56H,#30H
  MOV 57H,#02H
  SETB F0
  LJMP S_PLAY
Y33:
  MOV 57H,#02H
  SETB F0
  LJMP S_PLAY
Y32:
  MOV 56H,#29H  ;前一个月不是闰月
  MOV A,R6
  JB ACC.5,Y34
  MOV 56H,#30H
Y34:
  MOV 57H,#02H
  CLR F0
  LJMP S_PLAY
Y31:
  MOV A,R2
  MOV R0,A      ;R2中为日的值
  LCALL D_BCD
  MOV 56H,A
  MOV 57H,#03H
  CLR F0
  LJMP S_PLAY
RY3:
  CJNE R2,#00H,RY31
  MOV 56H,#29H
  MOV A,R6
  JB ACC.4,RY32   ;R2中为0，则为前一个月
  MOV 56H,#30H    ;的的最后一天
RY32:
  MOV 57H,#03H
  CLR F0
  LJMP S_PLAY
RY31:
  MOV A,R2       ;R2中为日的值
  MOV R0,A
  LCALL D_BCD
  MOV 56H,A
  MOV 57H,#03H
  SETB F0
  LJMP S_PLAY
Y4:
  CJNE R2,#00H,Y41
  LCALL CHECKRE    ;查前一个月是否为闰月
  CJNE A,#03H,Y42
  MOV 56H,#29H     ;前一个月是闰月
  MOV A,R4         ;R2中为0，则为前一个月
  ANL A,#0FH       ;的最后一天
  JNZ Y43
  MOV 56H,#30H
  MOV 57H,#03H
  SETB F0
  LJMP S_PLAY
Y43:
  MOV 57H,#03H
  SETB F0
  LJMP S_PLAY
Y42:
  MOV 56H,#29H  ;前一个月不是闰月
  MOV A,R6
  JB ACC.4,Y44
  MOV 56H,#30H
Y44:
  MOV 57H,#03H
  CLR F0
  LJMP S_PLAY
Y41:
  MOV A,R2       ;R2中为日的值
  MOV R0,A
  LCALL D_BCD
  MOV 56H,A
  MOV 57H,#04H
  CLR F0
  LJMP S_PLAY
RY4:
  CJNE R2,#00H,RY41
  MOV 56H,#29H    ;R2中为0，则为前一个月
  MOV A,R6        ;的的最后一天
  JB ACC.2,RY42
  MOV 56H,#30H
RY42:
  MOV 57H,#04H
  CLR F0
  LJMP S_PLAY
RY41:
  MOV A,R2       ;R2中为日的值
  MOV R0,A
  LCALL D_BCD
  MOV 56H,A
  MOV 57H,#04H
  SETB F0
  LJMP S_PLAY
Y5:
  CJNE R2,#00H,Y51
  LCALL CHECKRE    ;查前一个月是否为闰月
  CJNE A,#04H,Y52
  MOV 56H,#29H       ;前一个月是闰月
  MOV A,R4           ;R2中为0，则为前一个月
  ANL A,#0FH         ;的最后一天
  JNZ Y53
  MOV 56H,#30H
  MOV 57H,#04H
  SETB F0
  LJMP S_PLAY
Y53:
  MOV 57H,#04H
  SETB F0
  LJMP S_PLAY
Y52:
  MOV 56H,#29H   ;前一个月不是闰月
  MOV A,R6
  JB ACC.2,Y54
  MOV 56H,#30H
Y54:
  MOV 57H,#04H
  CLR F0
  LJMP S_PLAY
Y51:
  MOV A,R2       ;R2中为日的值
  MOV R0,A
  LCALL D_BCD
  MOV 56H,A
  MOV 57H,#05H
  CLR F0
  LJMP S_PLAY
RY5:
  CJNE R2,#00H,RY51
  MOV 56H,#29H    ;R2中为0，则为前一个月
  MOV A,R6        ;的最后一天
  JB ACC.1,RY52
  MOV 56H,#30H
RY52:
  MOV 57H,#05H
  CLR F0
  LJMP S_PLAY
RY51:
  MOV A,R2     ;R2中为日的值
  MOV R0,A
  LCALL D_BCD
  MOV 56H,A
  MOV 57H,#05H
  SETB F0
  LJMP S_PLAY
Y6:
  CJNE R2,#00H,Y61
  LCALL CHECKRE   ;查前一个月是否为闰月
  CJNE A,#05H,Y62
  MOV 56H,#29H    ;前一个月是闰月
  MOV A,R4        ;R2中为0，则为前一个月
  ANL A,#0FH      ;的最后一天
  JNZ Y63
  MOV 56H,#30H
  MOV 57H,#05H
  SETB F0
  LJMP S_PLAY
Y63:
  MOV 57H,#05H
  SETB F0
  LJMP S_PLAY
Y62:
  MOV 56H,#29H   ;前一个月不是闰月
  MOV A,R6
  JB ACC.1,Y64
  MOV 56H,#30H
Y64:
  MOV 57H,#05H
  CLR F0
  LJMP S_PLAY
Y61:
  MOV A,R2        ;R2中为日的值
  MOV R0,A
  LCALL D_BCD
  MOV 56H,A
  MOV 57H,#06H
  CLR F0
  LJMP S_PLAY
RY6:
  CJNE R2,#00H,RY61
  MOV 56H,#29H    ;R2中为0，则为前一个月
  MOV A,R6        ;的最后一天
  JB ACC.0,RY62
  MOV 56H,#30H
RY62:
  MOV 57H,#06H
  CLR F0
  LJMP S_PLAY
RY61:
  MOV A,R2     ;R2中为日的值
  MOV R0,A
  LCALL D_BCD
  MOV 56H,A
  MOV 57H,#06H
  SETB F0
  LJMP S_PLAY
Y7:
  CJNE R2,#00H,Y71
  LCALL CHECKRE    ;查前一个月是否为闰月
  CJNE A,#06H,Y72
  MOV 56H,#29H     ;前一个月是闰月
  MOV A,R4         ;R2中为0，则为前一个月
  ANL A,#0FH       ;的最后一天
  JNZ Y73
  MOV 56H,#30H
  MOV 57H,#06H
  SETB F0
  LJMP S_pLAY
Y73:
  MOV 57H,#06H
  SETB F0
  LJMP S_PLAY
Y72:
  MOV 56H,#29H   ;前一个月不是闰月
  MOV A,R6
  JB ACC.0,Y74
  MOV 56H,#30H
Y74:
  MOV 57H,#06H
  CLR F0
  LJMP S_PLAY
Y71:
  MOV A,R2        ;R2中为日的值
  MOV R0,A
  LCALL D_BCD
  MOV 56H,A
  MOV 57H,#07H
  CLR F0
  LJMP S_PLAY
RY7:
  CJNE R2,#00H,RY71
  MOV 56H,#29H    ;R2中为0，则为前一个月
  MOV A,R5        ;的最后一天
  JB ACC.6,RY72
  MOV 56H,#30H
RY72:
  MOV 57H,#07H
  CLR F0
  LJMP S_PLAY
RY71:
  MOV A,R2      ;R2中为日的值
  MOV R0,A
  LCALL D_BCD
  MOV 56H,A
  MOV 57H,#07H
  SETB F0
  LJMP S_PLAY
Y8:
  CJNE R2,#00H,Y81
  LCALL CHECKRE     ;查前一个月是否为闰月
  CJNE A,#07H,Y82
  MOV 56H,#29H     ;前一个月是闰月
  MOV A,R4         ;R2中为0，则为前一个月
  ANL A,#0FH       ;的最后一天
  JNZ Y83
  MOV 56H,#30H
  MOV 57H,#07H
  SETB F0
  LJMP S_PLAY
Y83:
  MOV 57H,#07H
  SETB F0
  LJMP S_PLAY
Y82:
  MOV 56H,#29H  ;前一个月不是闰月
  MOV A,R5
  JB ACC.6,Y84
  MOV 56H,#30H
Y84:
  MOV 57H,#07H
  CLR F0
  LJMP S_PLAY
Y81:
  MOV A,R2     ;R2中为日的值
  MOV R0,A
  LCALL D_BCD
  MOV 56H,A
  MOV 57H,#08H
  CLR F0
  LJMP S_PLAY
Y9:
  CJNE R2,#00H,Y91
  MOV 56H,#29H   ;R2中为0，则为前一个月
  MOV A,R5       ;的最后一天
  JB ACC.5,Y92
  MOV 56H,#30H
Y92:
  MOV 57H,#08H
  CLR F0
  LJMP S_PLAY
Y91:
  MOV A,R2     ;R2中为日的值
  MOV R0,A
  LCALL D_BCD
  MOV 56H,A
  MOV 57H,#09H
  CLR F0
  LJMP S_PLAY
RY9:
  CJNE R2,#00H,RY91
  MOV 56H,#29H    ;R2中为0，则为前一个月
  MOV A,R5        ;的最后一天
  JB ACC.4,RY92
  MOV 56H,#30H
RY92:
  MOV 57H,#09H
  CLR F0
  LJMP S_PLAY
RY91:
  MOV A,R2      ;R2中为日的值
  MOV R0,A
  LCALL D_BCD
  MOV 56H,A
  MOV 57H,#09H
  SETB F0
  LJMP S_PLAY
Y10:
  CJNE R2,#00H,Y101
  LCALL CHECKRE    ;查前一个月是否为闰月
  CJNE A,#09H,Y102
  MOV 56H,#29H     ;前一个月是闰月
  MOV A,R4         ;R2中为0，则为前一个月
  ANL A,#0FH       ;的最后一天
  JNZ Y103
  MOV 56H,#30H
  MOV 57H,#09H
  SETB F0
  LJMP S_PLAY
Y103:
  MOV 57H,#09H
  SETB F0
  LJMP S_PLAY
Y102:
  MOV 56H,#29H    ;前一个月不是闰月
  MOV A,R5
  JB ACC.4,Y104
  MOV 56H,#30H
Y104:
  MOV 57H,#09H
  CLR F0
  LJMP S_PLAY
Y101:
  MOV A,R2       ;R2中为日的值
  MOV R0,A
  LCALL D_BCD
  MOV 56H,A
  MOV 57H,#10H
  CLR F0
  LJMP S_PLAY
Y11:
  CJNE R2,#00H,Y111
  MOV 56H,#29H     ;R2中为0，则为前一个月
  MOV A,R5         ;的最后一天
  JB ACC.2,Y112
  MOV 56H,#30H
Y112:
  MOV 57H,#10H
  CLR F0
  LJMP S_PLAY
Y111:
  MOV A,R2    ;R2中为日的值
  MOV R0,A
  LCALL D_BCD
  MOV 56H,A
  MOV 57H,#11H
  CLR F0
  LJMP S_PLAY
Y12:
  CJNE R2,#00H,Y121
  MOV 56H,#29H     ;R2中为0，则为前一个月
  MOV A,R5          ;的最后一天
  JB ACC.1,Y122
  MOV 56H,#30H
Y122:
  MOV 57H,#11H
  CLR F0
  LJMP S_PLAY
Y121:
  MOV A,R2    ;R2中为日的值
  MOV R0,A
  LCALL D_BCD
  MOV 56H,A
  MOV 57H,#12H
  CLR F0
  LJMP S_PLAY
S_PLAY:
  MOV R0,57H
  LCALL DIVIDE  ;月分离送显示缓存
  MOV 52H,R1
  MOV 53H,R2
  MOV R0,56H
  LCALL DIVIDE  ;日分离送显示缓存
  MOV 50H,R1
  MOV 51H,R2
  RET

;查是否闰月程序;;

CHECKRE:
  MOV A,R4
  SWAP A
  ANL A,#0FH
  RET
;10进制转换为BCD码程序;

D_BCD:
  MOV A,R0
  MOV B,#10
  DIV AB
  SWAP A
  ORL A,B
  RET

;~~~~~闹铃~~~~~~~~~~~~~~
NS:
  MOV A,75H
  SWAP A
  ADD A,74H
  MOV 12H,A
  MOV A,73H
  SWAP A
  ADD A,72H
  MOV 13H,A
  MOV A,71H
  SWAP A
  ADD A,70H
  MOV 14H,A
SH1:
  MOV A,12H
  CJNE A,#07H,XH1
  MOV A,13H
  CJNE A,#50H,XH1
  MOV A,14H
  CJNE A,#00H,XH1
  SETB P0.6
  LCALL MPD
  RET
XH1:
  CLR P0.6
  MOV A,12H
  CJNE A,#08H,SH2
  MOV A,13H
  CJNE A,#30H,SH2
  MOV A,14H
  CJNE A,#00H,SH2
  SETB P0.6
  LCALL MPD
  RET
SH2:
  MOV A,12H
  CJNE A,#08H,XH2
  MOV A,13H
  CJNE A,#40H,XH2
  MOV A,14H
  CJNE A,#00H,XH2
  SETB P0.6
  LCALL MPD
  RET
XH2:
  CLR P0.6
  MOV A,12H
  CJNE A,#09H,SH3
  MOV A,13H
  CJNE A,#20H,SH3
  MOV A,14H
  CJNE A,#00H,SH3
  SETB P0.6
  LCALL MPD
  RET
SH3:
  MOV A,12H
  CJNE A,#09H,XH3
  MOV A,13H
  CJNE A,#40H,XH3
  MOV A,14H
  CJNE A,#00H,XH3
  SETB P0.6
  LCALL MPD
  RET
XH3:
  CLR P0.6
  MOV A,12H
  CJNE A,#10H,SH4
  MOV A,13H
  CJNE A,#20H,SH4
  MOV A,14H
  CJNE A,#00H,SH4
  SETB P0.6
  LCALL MPD
  RET
SH4:
  MOV A,12H
  CJNE A,#10H,XH4
  MOV A,13H
  CJNE A,#30H,XH4
  MOV A,14H
  CJNE A,#00H,XH4
  SETB P0.6
  LCALL MPD
  RET
XH4:
  CLR P0.6
  MOV A,12H
  CJNE A,#11H,SH5
  MOV A,13H
  CJNE A,#10H,SH5
  MOV A,14H
  CJNE A,#00H,SH5
  SETB P0.6
  LCALL MPD
  RET
SH5:
  MOV A,12H
  CJNE A,#11H,XH5
  MOV A,13H
  CJNE A,#20H,XH5
  MOV A,14H
  CJNE A,#00H,XH5
  SETB P0.6
  LCALL MPD
  RET
XH5:
  CLR P0.6
  MOV A,12H
  CJNE A,#12H,XSH1
  MOV A,13H
  CJNE A,#00H,XSH1
  MOV A,14H
  CJNE A,#00H,XSH1
  SETB P0.6
  LCALL MPD
  RET

XSH1:
  MOV A,12H
  CJNE A,#15H,XXH1
  MOV A,13H
  CJNE A,#00H,XXH1
  MOV A,14H
  CJNE A,#00H,XXH1
  SETB P0.6
  LCALL MPD
  RET
XXH1:
  CLR P0.6
  MOV A,12H
  CJNE A,#15H,XSH2
  MOV A,13H
  CJNE A,#40H,XSH2
  MOV A,14H
  CJNE A,#00H,XSH2
  SETB P0.6
  LCALL MPD
  RET
XSH2:
  MOV A,12H
  CJNE A,#15H,XXH2
  MOV A,13H
  CJNE A,#50H,XXH2
  MOV A,14H
  CJNE A,#00H,XXH2
  SETB P0.6
  LCALL MPD
  RET
XXH2:
  CLR P0.6
  MOV A,12H
  CJNE A,#16H,XSH3
  MOV A,13H
  CJNE A,#30H,XSH3
  MOV A,14H
  CJNE A,#00H,XSH3
  SETB P0.6
  LCALL MPD
  RET
XSH3:
  MOV A,12H
  CJNE A,#16H,XXH3
  MOV A,13H
  CJNE A,#40H,XXH3
  MOV A,14H
  CJNE A,#00H,XXH3
  SETB P0.6
  LCALL MPD
  RET
XXH3:
  CLR P0.6
  MOV A,12H
  CJNE A,#17H,ZZ2
  MOV A,13H
  CJNE A,#20H,ZZ2
  MOV A,14H
  CJNE A,#00H,ZZ2
  SETB P0.6
  LCALL MPD
ZZ2:
  RET
MPD:
  MOV A,14H
  CJNE A,#10H,ZZ2
  CLR P0.6
  RET

;;显示程序;;;

DISPLAY:
  MOV A,10H
  ANL A,#00001111B
  MOV 59H,A
  MOV A,76H               ;第八列LED
  ANL A,#00001111B
  SWAP A
  ADD A,59H
  MOV P1,A
  MOV A,70H
  ANL A,#00001111B
  ADD A,#01110000B
  MOV P2,A
  LCALL DL1MS

  MOV A,10H
  ANL A,#11110000B
  SWAP A
  MOV 5AH,A
  MOV A,77H              ;第七列LED
  ANL A,#00001111B
  SWAP A
  ADD A,5AH
  MOV P1,A
  MOV A,71H
  ANL A,#00001111B
  ADD A,#01100000B
  MOV P2,A
  LCALL DL1MS

  MOV A,56H             ;第六列LED
  SWAP A
  ANL A,#11110000B
  ADD A,79H
  SWAP A
  MOV P1,A
  MOV A,72H
  ANL A,#00001111B
  ADD A,#01010000B
  MOV P2,A
  LCALL DL1MS

  MOV A,56H            ;第五列LED
  ANL A,#11110000B
  ADD A,7AH
  SWAP A
  MOV P1,A
  MOV A,73H
  ANL A,#00001111B
  ADD A,#01000000B
  MOV P2,A
  LCALL DL1MS

  MOV A,57H            ;第四列LED
  SWAP A
  ANL A,#11110000B
  ADD A,7BH
  SWAP A
  MOV P1,A
  MOV A,74H
  ANL A,#00001111B
  ADD A,#00110000B
  MOV P2,A
  LCALL DL1MS

  MOV A,57H            ;第三列LED
  ANL A,#11110000B
  ADD A,7CH
  SWAP A
  MOV P1,A
  MOV A,75H
  ANL A,#00001111B
  ADD A,#00100000B
  MOV P2,A
  LCALL DL1MS

  MOV P1,#00001111B
  MOV P2,#00011111B    ;第二列LED
  LCALL DL1MS

  MOV A,78H            ;第一列LED
  ANL A,#00001111B
  ADD A,#00100000B
  MOV P1,A
  MOV P2,#00001111B
  LCALL DL1MS
  MOV P1,#0FFH
  RET
ZJ:
  MOV 01H,#150
ZZZ1:
  MOV P2,#00001000B
  MOV P1,#88H
  LCALL DL1MS
  MOV P2,#00011000B
  MOV P1,#88H
  LCALL DL1MS
  MOV P2,#00101000B
  MOV P1,#88H
  LCALL DL1MS
  MOV P2,#00111000B
  MOV P1,#88H
  LCALL DL1MS
  MOV P2,#01001000B
  MOV P1,#88H
  LCALL DL1MS
  MOV P2,#01011000B
  MOV P1,#88H
  LCALL DL1MS
  MOV P2,#01101000B
  MOV P1,#88H
  LCALL DL1MS
  MOV P2,#01111000B
  MOV P1,#88H
  LCALL DL1MS
  DJNZ 01H,ZZZ1
  MOV P1,#0FFH
  RET

DL1MS:
  MOV R6,#14H
DL1:
  MOV R7,#19H
DL2:
  DJNZ R7,DL2
  DJNZ R6,DL1
  RET

;数据表~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
TAB:
  DB 35,15H,51H,00H,23,11H,52H,41H,42,12H,65H,00H
  DB 31,11H,32H,00H,21,42H,52H,21H,39,52H,25H,00H
  DB 28,25H,04H,71H,48,66H,42H,00H,37,33H,22H,00H
  DB 25,15H,24H,51H,44,05H,52H,00H,33,22H,65H,00H
  DB 22,21H,25H,41H,40,24H,52H,00H,30,52H,42H,91H
  DB 49,55H,05H,00H,38,26H,44H,00H,27,53H,50H,60H
  DB 46,53H,24H,00H,35,25H,54H,00H,24,41H,52H,41H
  DB 42,45H,25H,00H,31,24H,52H,00H,21,51H,12H,21H
  DB 40,55H,11H,00H,28,26H,21H,61H,47,26H,61H,00H
  DB 36,13H,31H,00H,25,05H,31H,51H,43,12H,54H,00H
  DB 33,51H,25H,00H,22,42H,25H,31H,41,32H,22H,00H
  DB 30,55H,02H,71H,49,55H,22H,00H,38,26H,62H,00H
  DB 27,13H,64H,60H,45,13H,32H,00H,34,12H,55H,00H
  DB 23,10H,53H,51H,42,22H,45H,00H,31,52H,22H,00H
  DB 21,52H,44H,21H,40,55H,44H,00H,29,26H,50H,71H
  DB 47,26H,64H,00H,36,25H,32H,00H,25,23H,32H,50H
  DB 44,44H,55H,00H,32,24H,45H,00H,22,55H,11H,30H
  END
