            ORG 0000H
             AJMP START
             ORG 0030H
START:       ;MOV 30H,#0A8h
             ;MOV 31H,#61H
             ;MOV 32H,#00H
             ;MOV 33H,#86H
             ;LCALL PUTBIT
ANJIAN:      JNB     P2.0,DOU1
              JNB     P2.1,DOU1
              JNB     P2.2,DOU1
              JNB     P2.3,DOU1
              NOP
              MOV A,33H
              XRL A,#86H
              JZ DD
              AJMP GG
DD:           LCALL DISP1
              AJMP NET
GG:           LCALL DISP2
NET:          LCALL   DELAY
              LJMP    ANJIAN
DOU1:        LCALL    DELAY
              JNB     P2.0,JIAYI0
              JNB     P2.1,JIASHI0
              JNB     P2.2,JIANYI0
              JNB     P2.3,JIANSHI0
              LJMP    ANJIAN
JIAYI0:       AJMP JIAYI
JIASHI0:       AJMP JIASHI
JIANYI0:       AJMP JIANYI
JIANSHI0:        AJMP JIANSHI
JIAYI:        MOV A,33H
             XRL A,#86H
             JZ DD1
             AJMP GG1
DD1:         LCALL DISP1
             LCALL DISP1
             
GG1:         LCALL DISP2
             LCALL DISP2

DCZ1:     MOV A,33H
             XRL A,#86H
             JZ  DIJIAYI
             AJMP GAOJIAYI
DIJIAYI:      MOV A,31H
             CLR C
             SUBB A,#0D2H       ;DIGAO
             JC JIA1
             MOV A,30H
             CLR C
             SUBB A,#0F0H
             JC JIA1
             
             MOV 30H,#08H
             MOV 31H,#070H
             MOV 32H,#00H
             MOV 33H,#80H
             LCALL PUTBIT
             
             AJMP ANJIAN
JIA1:         CLR C
             MOV A,30H
             ADD A,#05H
             MOV 30H,A
             MOV A,31H
             ADDC A,#00H
             MOV 31H,A
             LCALL PUTBIT
            ; LCALL VIICWRITE
             AJMP ANJIAN
GAOJIAYI:   MOV A,31H
             CLR C
             SUBB A,#12H      ;GAOGAO
             JC JIA2
             MOV A,30H
             CLR C
             SUBB A,#0C0H
             JC JIA2
             AJMP ANJIAN
JIA2:        CLR C
             MOV A,30H
             ADD A,#05H
             MOV 30H,A
             MOV A,31H
             ADDC A,#00H
             MOV 31H,A
             LCALL PUTBIT
            ; LCALL VIICWRITE
             AJMP ANJIAN
JIASHI:      MOV A,33H
             XRL A,#86H
             JZ DD2
             AJMP GG2
DD2:         LCALL DISP1
             LCALL DISP1
             
GG2:         LCALL DISP2
             LCALL DISP2


DCZ2:     MOV A,33H
             XRL A,#86H
             JZ  DIJIAYIS
             AJMP GAOJIAYIS
DIJIAYIS:    MOV A,31H
             CLR C
             SUBB A,#0D2H       ;DIGAO
             JC JIA1S
             MOV A,30H
             CLR C
             SUBB A,#0F0H
             JC JIA1S
             
             MOV 30H,#070H
             MOV 31H,#08H
             MOV 32H,#00H
             MOV 33H,#80H
             LCALL PUTBIT
             ;LCALL VIICWRITE
             AJMP ANJIAN
JIA1S:       CLR C
             MOV A,30H
             ADD A,#20
             MOV 30H,A
             MOV A,31H
             ADDC A,#00H
             MOV 31H,A
             LCALL PUTBIT
             ;LCALL VIICWRITE
             AJMP ANJIAN
GAOJIAYIS:      MOV A,31H
             CLR C
             SUBB A,#12H      ;GAOGAO
             JC JIA2S
             MOV A,30H
             CLR C
             SUBB A,#0C0H
             JC JIA2S
             AJMP ANJIAN
JIA2S:       CLR C
             MOV A,30H
             ADD A,#20
             MOV 30H,A
             MOV A,31H
             ADDC A,#00H
             MOV 31H,A
             LCALL PUTBIT
             ;LCALL VIICWRITE
             AJMP ANJIAN
JIANYI:      MOV A,33H
             XRL A,#86H
             JZ DD3
             AJMP GG3
DD3:     LCALL DISP1
              LCALL DISP1
              
GG3:      LCALL DISP2
              LCALL DISP2

DCZ3:      MOV A,33H
             XRL A,#80H
             JZ  GAOJIANYI
             AJMP DIJIANYI
GAOJIANYI:  MOV A,31H
             SUBB A,#08H
             JZ PANDI
             AJMP JIAN1
PANDI:       MOV A,30H
             SUBB A,#070H
             JNC JIAN1
             MOV 30H,#0F0H
             MOV 31H,#0D2H
             MOV 32H,#00H
             MOV 33H,#86H
             
             LCALL PUTBIT
             
             AJMP ANJIAN
JIAN1:       CLR C
             MOV A,30H
             SUBB A,#05H
             MOV 30H,A
             MOV A,31H
             SUBB A,#00H
             MOV 31H,A
             LCALL PUTBIT
            ; LCALL VIICWRITE
             AJMP ANJIAN
DIJIANYI:        MOV A,31H
             SUBB A,#61H
             JZ PAND2
             AJMP JIAN2
PAND2:          MOV A,30H
             SUBB A,#0A0H
             JNC JIAN2
             AJMP ANJIAN

JIAN2:       CLR C
             MOV A,30H
             SUBB A,#05H
             MOV 30H,A
             MOV A,31H
             SUBB A,#00H
             MOV 31H,A
             LCALL PUTBIT
           
             AJMP ANJIAN
JIANSHI:     MOV A,33H
             XRL A,#86H
             JZ DD4
             AJMP GG4
DD4:         LCALL DISP1
             LCALL DISP1
             
GG4:         LCALL DISP2
             LCALL DISP2

DCZ4:       MOV A,33H
             XRL A,#80H
             JZ  GAOJIANYIS
             AJMP DIJIANYIS
GAOJIANYIS: MOV A,31H
             SUBB A,#08H
             JZ PANDIS
             AJMP JIAN1S
PANDIS:      MOV A,30H
             SUBB A,#070H
             JNC JIAN1S
             MOV 30H,#0F0H
             MOV 31H,#0D2H
             MOV 32H,#00H
             MOV 33H,#86H
             
              LCALL PUTBIT
              
              AJMP ANJIAN
JIAN1S:       CLR C
              MOV A,30H
              SUBB A,#20
              MOV 30H,A
               MOV A,31H
              SUBB A,#00H
               MOV 31H,A
               LCALL PUTBIT
              ; LCALL VIICWRITE
               AJMP ANJIAN
DIJIANYIS:     MOV A,31H
               SUBB A,#61H
               JZ PAND2S
               AJMP JIAN2S
PAND2S:       MOV A,30H
               SUBB A,#0A0H
               JNC JIAN2S
               AJMP ANJIAN
JIAN2S:        CLR C
               MOV A,30H
               SUBB A,#20
               MOV 30H,A
               MOV A,31H
              SUBB A,#00H
               MOV 31H,A
               LCALL PUTBIT
             
               AJMP ANJIAN
DISP1:     MOV 35H,31H
               MOV 34H,30H
               MOV 36H,#00H
         
               NOP
               NOP
 RET
DISP2:     MOV 35H,31H
               MOV 34H,30H
MOV 36H,#00H
               MOV 37H,#00H
               MOV 38H,#00H
               MOV R7,#25
KLK :      CLR C
                MOV A,36H
                ADD A,34H
                MOV 36H,A
                MOV A,37H
                ADDC A,35H
                MOV 37H,A
                MOV A,38H
                ADDC A,#00H
                MOV 38H,A
                DJNZ R7,KLK
                MOV 34H,36H
                MOV 35H,37H
                MOV 36H,38H

                NOP
                RET             
PUTBIT:      SETB P1.0
              LCALL DELAY1
              MOV A,30H
              LCALL PUT
              MOV A,31H
              LCALL PUT
              MOV A,32H
              LCALL PUT
              MOV A,33H
               LCALL PUT
              CLR P1.0
               CLR P1.1
               CLR P1.2
               RET
PUT:       MOV R3,#08H
               CLR C
PUT1:      RRC A
                MOV P1.2,C
                LCALL DELAY1
                SETB P1.1
                LCALL DELAY1
                CLR P1.1
                DJNZ R3,PUT1
                RET
DELAY1:          MOV R7,#09H
D1:         MOV R6,# 01FH
D2:         DJNZ R6,D2
                DJNZ R7,D1
                RET
DELAY:       MOV R7,#02H
D11:          MOV R6,#0F0H
D21:          DJNZ R6,D21
                DJNZ R7,D11
                RET
