	org 0000h
		jmp start
		org 000bh
		jmp time
		org 30h
start:	mov sp,#5fh		 ;//	小时	分钟	秒
		mov r1,#2		 ;//	r2 r1   r5 r0   r3 r4
		mov r2,#1
		mov r7,#0
		mov r0,#0
		mov r6,#0
		mov r5,#0
		mov 20h,#8		;//20h  日地址					日  	月 		年个位		年十位	 年百位	 年千位
		mov 21h,#6		;//21h	月地址					20h		21h		22h			 23h	  24h	 25h
		mov 22h,#8		;//年个位
		mov 23h,#0		;//年十位
		mov 24h,#0		;//年百位
		mov 25h,#2		;/年千位

		mov 34h,#0		;//闹铃1  秒个位			  时十位	时个位	分十位	分个位	秒十位	秒个位
		mov 35h,#0		;//闹铃1  秒十位
		mov 36h,#1		;//闹铃1  分个位				39h		38h		 37h		36h		35h		34h
		mov 37h,#0		;//闹铃1  分十位
		mov 38h,#0		;//闹铃1  时个位
		mov 39h,#0		;//闹铃1  时十位	 	    时十位	时个位	分十位	分个位	秒十位	秒个位

		mov 49h,#1		;//闹铃2 分个位			 4ch	 4bh	  4ah	 49h	 48h	 47h
		mov 4ah,#0		;//闹铃2 分十位
		mov 4bh,#0		;//闹铃2 时个位
		mov 4ch,#0		;//闹铃2 时十位


                setb p1.5

		mov TMOD,#00000001b
		mov TH0,#3ch		 ;//定时器初值
		mov TL0,#0b0h
		setb EA				 ;//开总中断
		setb ET0			 ;//开定时器一的中断
		mov p1,#0ffh
		setb TR0			 ;//定时器开始工作
k:		mov 12h,r0

		mov 13h,r1

		mov 14h,r2			; //	小时	  分钟	   秒
						;	 //	r2 r1     r5 r0   r3 r4
		mov 15h,r5
						  ; 	// 14h 13h	 15h 12h
loop:	mov r5,15h
		mov r2,14h
		mov r1,13h			;//地址中不是BCD码而是要显示的数字
		mov r0,12h

		mov a,r6		  ; //R6中是秒脉冲个数
		mov b,#10
		div ab
		mov dptr,#tab1	  ; //商存在a中
		movc a,@a+dptr
		mov r3,a

		mov a,b
		movc a,@a+dptr	   ;//余数在b中
		mov r4,a

		mov dptr,#tab1
		mov a,r0
		movc a,@a+dptr	;	//分 个位
		mov r0,a

		mov a,r5
		movc a,@a+dptr		;//分 十位
		mov r5,a;									  //	小时	  分钟	   秒
			;										  //	r2 r1     r5 r0   r3 r4
		mov a,r1 ;
		movc a,@a+dptr		;//时 个位				  //   14h 13h	  15h 12h
		mov r1,a
;													  //   18h 17h	  19h 16h
		mov a,r2			;//时 十位
		movc a,@a+dptr;								  //此时地址中是要显示数字的BCD码
		mov r2,a
		mov 19h,r5
		mov 18h,r2
		mov 17h,r1
		mov 16h,r0
		mov 46h,r6


dsp:
		mov p2,r4
		mov p0,#70h				 ;//p0的高位接74LS138
		lcall delay

		mov p2,r3
		mov p0,#60h
		lcall delay

		mov p2,r0				;//	小时	  分钟	   秒
		mov p0,#40h
		lcall delay			;	//	r2 r1     r5 r0   r3 r4
                                                        ;
		mov p2,r5
		mov p0,#30h
		lcall delay

		mov p2,r1
		mov p0,#10h
		lcall delay


		mov p2,r2
		mov p0,#00h
		lcall delay

		mov p0,#50h				;//在分与秒之间加  "一"
		mov p2,#3fh
		lcall delay

		mov p0,#20h				;//在分与秒之间加  "一"
		mov p2,#3fh
		lcall delay
		jnb p1.1,return1		;//p1.1是年月日调整
		jnb p1.0,jie			;//p1.0是时间调整
		jnb p1.2,goto5			;//p1.2进入闹铃

		mov p3,#0ffh

                call cheak2
                call cheak3

		call zcheak;						//2ah.0为0跳转，不去整点报时
                jb p1.5,out3
                call cheak
out3:           jb p1.6,out2
                call cheak1

out2:          	jmp loop

goto6:	mov p3,#150
		ljmp notice
goto5:	lcall  delay1		    ;// 跳往闹铃的按键防抖程序
		jnb p1.2,goto6
		ljmp loop


return5:mov P3,#190
		ljmp showdate
return1:lcall  delay1		    ;/;/ 跳往日期调整的按键防抖程序
		jnb p1.1,return5
		ljmp loop

return8:mov p3,#230
		ljmp dsp1
jie:	lcall delay1		   ;// 跳往时间调整的按键防抖程序
		jnb p1.0,return8
		ljmp loop


;//*************闹铃校对程序************************************************8

cheak:	         mov a,46h
		cjne a,#0,out
		mov a,36h				 ;//闹铃1比对，若成立就给P3口传入#00h
		cjne a,12h,out

								 ; 时十位	时个位	分十位	分个位	秒十位	秒个位
		mov a,37h				 ;;39h		38h		 37h		36h		35h		34h
		cjne a,15h,out

		mov a,38h
		cjne a,13h,out

		mov a,39h
		cjne a,14h,out

                mov a,36h                ;4dh存闹铃1后一分的 分个位
                inc a
                mov 4dh,a
              
                mov 2ah,#20
repeat1:         clr p1.7
                call longdelay1
                setb  p1.7
                call  longdelay1
                djnz  2ah,repeat1
out:	ret

cheak1:	        mov a,46h
		cjne a,#0,out22
		mov a,49h				 ;//闹铃1比对，若成立就给P3口传入#00h
		cjne a,12h,out22
								 ; 时十位	时个位	分十位	分个位	秒十位	秒个位
		mov a,4ah				 ;;39h		38h		 37h		36h		35h		34h
		cjne a,15h,out22                         ; 4ch	 	4bh	 	 4ah		 49h	 48h	 47h

		mov a,4bh
		cjne a,13h,out22

		mov a,4ch
		cjne a,14h,out22
                mov a,49h
                inc a
                mov 4eh,a
		
                mov 2bh,#20
repeat2:         clr p1.7
                call longdelay1
                setb  p1.7
                call  longdelay1
                djnz  2bh,repeat2
out22:         	ret
;***************关闹铃报警******************************************************
;关闹铃一
cheak2:	        mov a,46h
		cjne a,#0,out33
		mov a,4dh				 ;//闹铃1比对，若成立就给P3口传入#00h
		cjne a,12h,out33
								 ; 时十位	时个位	分十位	分个位	秒十位	秒个位
		mov a,37h				 ;;39h		38h		 37h		36h		35h		34h
		cjne a,15h,out33                            ; 4ch	 	4bh	 	 4ah		 49h	 48h	 47h

		mov a,38h
		cjne a,13h,out33

		mov a,39h
		cjne a,14h,out33
		setb p1.7
              
out33:         	ret
;关闹铃二
cheak3:	        mov a,46h
		cjne a,#0,out44
		mov a,4eh				 ;//闹铃1比对，若成立就给P3口传入#00h
		cjne a,12h,out44
								 ; 时十位	时个位	分十位	分个位	秒十位	秒个位
		mov a,4ah				 ;;39h		38h		 37h		36h		35h		34h
		cjne a,15h,out44                            ; 4ch	 	4bh	 	 4ah		 49h	 48h	 47h

		mov a,4bh
		cjne a,13h,out44

		mov a,4ch
		cjne a,14h,out44
		setb p1.7
               
out44:         	ret



;********整点报时校对程序******************************************************************


						  			 ;	小时	  分钟
zcheak:	        mov a,46h
		cjne a,#0,out
		mov a,12h					;   14h 13h	  15h 12h
		cjne a,#0,out
		mov a,15h
		cjne a,#0,out
		mov a,14h	   				;将原来存在13h,14h的小时转为一个值存在a中
		mov b,#10
		mul ab
		add a,13h


		cjne a,#1,play1
		mov p3,#0

		jmp out1
play1:	cjne a,#2,play2
		mov p3,#10

		jmp out1
play2:		cjne a,#3,play3
		mov p3,#20

		jmp out1
play3:		cjne a,#4,play4
		mov p3,#30

		jmp out1
play4:		cjne a,#5,play5
		mov p3,#40

		jmp out1

play5:		cjne a,#6,play6
		mov p3,#50

		jmp out1

play6:		cjne a,#7,play7
		mov p3,#60

		jmp out1
play7:		cjne a,#8,play8
		mov p3,#70

		jmp out1
play8:		cjne a,#9,play9
		mov p3,#80

		jmp out1
play9:		cjne a,#10,play10
		mov p3,#90

		jmp out1
play10:		cjne a,#11,play11
		 mov p3,#100

		jmp out1
play11:		cjne a,#12,play12
		mov p3,#110

		jmp out1
play12:		cjne a,#13,play13
		mov p3,#120

		jmp out1
play13:		cjne a,#14,play14
		mov p3,#130

		jmp out1
play14:		cjne a,#15,play15
		mov p3,#140

		jmp out1
play15:		cjne a,#16,play16
		mov p3,#150

		jmp out1
play16:		cjne a,#17,play17
		mov p3,#160

		jmp out1
play17:		cjne a,#18,play18
		mov p3,#170

		jmp out1
play18:		cjne a,#19,play19
		mov p3,#180

		jmp out1

play19:		cjne a,#20,play20
		mov p3,#190

		jmp out1
play20:		cjne a,#21,play21
		mov p3,#200

		jmp out1
play21:		cjne a,#22,play22
		mov p3,#210

		jmp out1
play22:		cjne a,#23,play23
		mov p3,#220

		jmp out1
play23:	cjne a,#24,out1
		mov p3,#230


out1:	ret


									  ;闹铃调整
notice:	mov dptr,#tab1
		mov a,34h
		movc a,@a+dptr						;	  时十位	时个位	分十位	分个位	秒十位	秒个位
		mov 45h,a
											;	  39h		38h		 37h		36h		35h		34h
										;BCD码	  40h		41h		 42h		43h		44h		45h
		mov a,35h
		movc a,@a+dptr					    ;   14h 		13h	 	15h 		12h
		mov 44h,a

		mov a,36h
		movc a,@a+dptr
		mov 43h,a

		mov a,37h
		movc a,@a+dptr
		mov 42h,a

		mov a,38h
		movc a,@a+dptr
		mov 41h,a

		mov a,39h
		movc a,@a+dptr
		mov 40h,a

		mov p2,45h
		mov p0,#70h			;显示时间
		lcall delay

		mov p2,44h
		mov p0,#60h
		lcall delay

		mov p2,43h
		mov p0,#40h
		lcall delay

		mov p2,42h
		mov p0,#30h
		lcall delay								;	  40h		41h		 42h		43h		44h		45h


		mov p2,41h
		mov p0,#10h
		lcall delay

		mov p2,40h
		mov p0,#00h
		lcall delay

		mov p0,#50h
		mov p2,#3fh
		lcall delay

		mov p0,#20h
		mov p2,#3fh
		lcall delay
		jnb p1.2,goto7	; p1.2跳回
		jnb p1.1,addfen		;p1.1分调整
		jnb p1.0,addshi	   ;时调整
                jnb p1.3,light     ;开启或关闭闹铃
		mov p3,#0ffh
		jmp notice


goto8:	mov p3,#170
		jmp notice1
goto7:	lcall delay1
		jnb p1.2,goto8
		ljmp notice
light:  lcall delay1
        lcall delay1
        cpl p1.5
        ljmp notice

addfen:	call delay1
		lcall delay1
		mov r5,37h					  	;	  39h		38h		 37h		36h		35h		34h
		mov r2,39h
		mov r1,38h
		mov r0,36h
		inc r0						  ;	小时	  分钟	   秒
		cjne r0,#10,to				  ;	r2 r1     r5 r0   r3 r4
		mov r0,#0
		inc r5						  ; 14h 13h	 15h 12h
		cjne r5,#6,to
		mov r5,#0
		inc r1
		cjne r1,#10,tiao
		mov r1,#0
		inc r2
tiao:	cjne r2,#2,to
		cjne r1,#4,to
		mov r2,#0
		mov r1,#0
to:		mov 36h,r0

		mov 38h,r1

		mov 39h,r2

		mov 37h,r5

		ljmp notice




addshi:	call delay1
		lcall delay1
		mov r5,37h					  	;	  39h		38h		 37h		36h		35h		34h
		mov r2,39h
		mov r1,38h
		mov r0,36h
		inc r1
		cjne r1,#10,tiao1
		mov r1,#0
		inc r2
tiao1:	cjne r2,#2,to1
		cjne r1,#4,to1
		mov r2,#0
		mov r1,#0
to1:	mov 36h,r0

		mov 38h,r1

		mov 39h,r2

		mov 37h,r5

		ljmp notice

					  ;闹铃二设定

notice1:mov dptr,#tab1
		mov a,34h
		movc a,@a+dptr						;	  时十位	时个位	分十位	分个位	秒十位	秒个位
		mov 45h,a
											;	  39h		38h		 37h		36h		35h		34h
											;	  4ch	 	4bh	 	 4ah		 49h	 48h	 47h
										;BCD码	  40h		41h		 42h		43h		44h		45h
		mov a,35h
		movc a,@a+dptr					    ;   14h 		13h	 	15h 		12h
		mov 44h,a

		mov a,49h
		movc a,@a+dptr
		mov 43h,a

		mov a,4ah
		movc a,@a+dptr
		mov 42h,a

		mov a,4bh
		movc a,@a+dptr
		mov 41h,a

		mov a,4ch
		movc a,@a+dptr
		mov 40h,a

		mov p2,45h
		mov p0,#70h			;显示时间
		lcall delay

		mov p2,44h
		mov p0,#60h
		lcall delay

		mov p2,43h
		mov p0,#40h
		lcall delay

		mov p2,42h
		mov p0,#30h
		lcall delay						;	  40h		41h		 42h		43h		44h		45h


		mov p2,41h
		mov p0,#10h
		lcall delay

		mov p2,40h
		mov p0,#00h
		lcall delay

		mov p0,#50h
		mov p2,#3fh
		lcall delay

		mov p0,#20h
		mov p2,#3fh
		lcall delay
		jnb p1.2,goto9	; p1.2跳回
		jnb p1.1,addfen1		;p1.1分调整
		jnb p1.0,addshi1	   ;时调整
                jnb p1.3,light1
		mov p3,#0ffh
		jmp notice1


goto10:	mov p3,#240
		jmp loop
goto9:	lcall delay1
		jnb p1.2,goto10
		ljmp notice1
light1: lcall delay1
        lcall delay1
        cpl p1.6
        jmp notice1

addfen1:call delay1
		lcall delay1
		mov r5,4ah					  	;	  39h		38h		 37h		36h		35h		34h
		mov r2,4ch					   ;	  4ch		 4bh	  4ah		 49h	 48h	 47h
		mov r1,4bh
		mov r0,49h
		inc r0						  ;	小时	  分钟	   秒
		cjne r0,#10,to3				  ;	r2 r1     r5 r0   r3 r4
		mov r0,#0
		inc r5						  ; 14h 13h	 15h 12h
		cjne r5,#6,to3
		mov r5,#0
		inc r1
		cjne r1,#10,tiao3
		mov r1,#0
		inc r2
tiao3:	cjne r2,#2,to3
		cjne r1,#4,to3
		mov r2,#0
		mov r1,#0
to3:	mov 49h,r0

		mov 4bh,r1

		mov 4ch,r2

		mov 4ah,r5

		ljmp notice1




addshi1:call delay1
		lcall delay1
		mov r5,4ah					  	;	  39h		38h		 37h		36h		35h		34h
		mov r2,4ch						;		4ch		 4bh	  4ah		 49h	 48h	 47h
		mov r1,4bh
		mov r0,49h
		inc r1
		cjne r1,#10,tiao4
		mov r1,#0
		inc r2
tiao4:	cjne r2,#2,to4
		cjne r1,#4,to4
		mov r2,#0
		mov r1,#0
to4:	mov 49h,r0

		mov 4bh,r1

		mov 4ch,r2

		mov 4ah,r5

		ljmp notice1









dsp1:
		mov r5,15h			    ;	小时	  分钟	   秒
		mov r2,14h			   ;   14h 13h	  15h 12h
		mov r1,13h
		mov r0,12h

;/*		mov a,r6 ;
;		mov b,#10
;		div ab
;		mov dptr,#tab1			 ;	r2 r1     r5 r0   r3 r4
;		movc a,@a+dptr
;		mov r3,a
  ;
;		mov a,b
;		movc a,@a+dptr
;		mov r4,a
;				   */
		mov dptr,#tab1
		mov a,r0
		movc a,@a+dptr		 ;计算BCD码
		mov r0,a

		mov a,r5
		movc a,@a+dptr
		mov r5,a

		mov a,r1
		movc a,@a+dptr
		mov r1,a

		mov a,r2
		movc a,@a+dptr
		mov r2,a


		mov p2,r4
		mov p0,#70h			;显示时间
		lcall delay

		mov p2,r3
		mov p0,#60h
		lcall delay

		mov p2,r0
		mov p0,#40h
		lcall delay

		mov p2,r5
		mov p0,#30h
		lcall delay


		mov p2,r1
		mov p0,#10h
		lcall delay

		mov p2,r2
		mov p0,#00h
		lcall delay

		mov p0,#50h
		mov p2,#3fh
		lcall delay

		mov p0,#20h
		mov p2,#3fh
		lcall delay
		lcall delay
		lcall delay
		lcall delay
		lcall delay
		jnb p1.0,return2	; p1.0跳回
		jnb p1.1,fen	;p1.1分调整
		jnb p1.2,shi
                jnb p1.3,mon
		mov p3,#0ffh
		ljmp dsp1

return9:mov p3,#240;
		jmp loop
return2:lcall delay1
		jnb p1.0,return9
		jmp dsp1

mon:            mov p3,#222
                call delay1
                jmp dsp1

fen:	call delay1
		lcall delay1
		mov r5,15h
		mov r2,14h
		mov r1,13h
		mov r0,12h
		inc r0						  ;	小时	  分钟	   秒
		cjne r0,#10,q				  ;	r2 r1     r5 r0   r3 r4
		mov r0,#0
		inc r5
		cjne r5,#6,q
		mov r5,#0
		inc r1
		cjne r1,#10,next2
		mov r1,#0
		inc r2
next2:	cjne r2,#2,q
		cjne r1,#4,q
		mov r2,#0
		mov r1,#0
q:		mov 12h,r0

		mov 13h,r1

		mov 14h,r2

		mov 15h,r5

		ljmp dsp1
shi:	call delay1
		lcall delay1
		mov r5,15h
		mov r2,14h					   ;	小时	  分钟	   秒
		mov r1,13h					   ;	r2 r1     r5 r0   r3 r4
		mov r0,12h
		inc r1
		cjne r1,#10,next3
		mov r1,#0
		inc r2
next3:	cjne r2,#2,pq
		cjne r1,#4,pq
		mov r2,#0
		mov r1,#0
pq:		mov 12h,r0

		mov 13h,r1

		mov 14h,r2

		mov 15h,r5

		ljmp dsp1


showdate:mov a,20h		; 日  	月 		年个位		年十位	 年百位	 年千位
		mov b,#10	   ; 20h	21h		22h			 23h	  24h	 25h
		div ab
		mov dptr,#tab1
		movc a,@a+dptr
		mov 26h,a		  ;转化出来的BCD码
		mov a,b				;	  	日个位		日十位
		movc a,@a+dptr		;		 27h		 26h
		mov 27h,a


		mov a,21h
		mov b,#10
		div ab				  ;	月个位		月十位
		movc a,@a+dptr
		mov 28h,a			;		 29h		28h
		mov a,b
		movc a,@a+dptr
		mov 29h,a


		mov a,22h
		movc a,@a+dptr		  ; 		年个位		年十位	 年百位	 年千位
		mov 30h,a			  ;		22h			 23h	  24h	 25h
							  ;BCD码	30h			 31h	  32h	 33h
		mov a,23h
		movc a,@a+dptr
		mov 31h,a

		mov a,24h
		movc a,@a+dptr
		mov 32h,a


		mov a,25h
		movc a,@a+dptr
		mov 33h,a
		jnb p1.1,goto2
		jnb p1.2,goto4
		mov p3,#0ffh

dsp5:	mov p2,27h
		mov p0,#70h			;年月日的BCD码
		lcall delay		   ;日个位		日十位	月个位		月十位 	年个位		年十位	 年百位	 年千位
						   ;27h		 26h	 29h		28h		30h			 31h	  32h	 33h
		mov p2,26h
		mov p0,#60h
		lcall delay

		mov p2,28h
		mov p0,#40h
		lcall delay

		mov p2,30h
		mov p0,#30h
		lcall delay

		mov p2,32h
		mov p0,#10h
		lcall delay

		mov p2,33h
		mov p0,#00h
		lcall delay

		mov p0,#50h
		mov p2,29h
		lcall delay

		mov p0,#20h
		mov p2,31h
		lcall delay

		jmp showdate

goto3:	mov p3,#200
		jmp date			   ;跳转到日期设置中

goto2: 	lcall delay1
		jnb p1.1,goto3
 		ljmp showdate

goto4:	lcall delay1
		jmp loop






date:	mov a,20h		; 日  	月 		年个位		年十位	 年百位	 年千位
		mov b,#10	   ; 20h	21h		22h			 23h	  24h	 25h
		div ab
		mov dptr,#tab1
		movc a,@a+dptr
		mov 26h,a		  ;转化出来的BCD码
		mov a,b				;	  	日个位		日十位
		movc a,@a+dptr		;		 27h		 26h
		mov 27h,a


		mov a,21h
		mov b,#10
		div ab				  ;	月个位		月十位
		movc a,@a+dptr
		mov 28h,a			;		 29h		28h
		mov a,b
		movc a,@a+dptr
		mov 29h,a


		mov a,22h
		movc a,@a+dptr		  ; 		年个位		年十位	 年百位	 年千位
		mov 30h,a			  ;		22h			 23h	  24h	 25h
							  ;BCD码	30h			 31h	  32h	 33h
		mov a,23h
		movc a,@a+dptr
		mov 31h,a

		mov a,24h
		movc a,@a+dptr
		mov 32h,a


		mov a,25h
		movc a,@a+dptr
		mov 33h,a
		jnb p1.1,return
		jnb p1.0,adddate
		jnb p1.2,decdate
		mov p3,#0ffh
dsp2:	mov p2,27h
		mov p0,#70h			;年月日的BCD码
		lcall delay		   ;日个位		日十位	月个位		月十位 	年个位		年十位	 年百位	 年千位
						   ;27h		 26h	 29h		28h		30h			 31h	  32h	 33h
		mov p2,26h
		mov p0,#60h
		lcall delay

		mov p2,28h
		mov p0,#40h
		lcall delay

		mov p2,30h
		mov p0,#30h
		lcall delay

		mov p2,32h
		mov p0,#10h
		lcall delay

		mov p2,33h
		mov p0,#00h
		lcall delay

		mov p0,#50h
		mov p2,29h
		lcall delay

		mov p0,#20h
		mov p2,31h
		lcall delay

		jmp date
adddate:lcall delay1
		lcall delay1		  ;日加一
		inc 20h
		mov a,20h
		cjne a,#32,over
		mov 20h,#0

over:	ljmp date

decdate:lcall delay1		 ;日减一
		lcall delay1
		dec 20h
		mov a,20h
		cjne a,#-1,over
		mov 20h,#31
		jmp over



return6:mov p3,#210
		jmp r			   ;跳转到日

return:         lcall delay1
                mov p3,#230
		jnb p1.1,return6
 		ljmp date

r:		mov a,20h
		mov b,#10					 ;日  		月 		年个位		年十位	 年百位	 年千位
		div ab						;20h		21h		22h			 23h	  24h	 25h
		mov dptr,#tab1
		movc a,@a+dptr
		mov 26h,a
		mov a,b
		movc a,@a+dptr
		mov 27h,a


		mov a,21h
		mov b,#10
		div ab
		movc a,@a+dptr
		mov 28h,a
		mov a,b
		movc a,@a+dptr
		mov 29h,a


		mov a,22h
		movc a,@a+dptr
		mov 30h,a

		mov a,23h
		movc a,@a+dptr
		mov 31h,a

		mov a,24h
		movc a,@a+dptr
		mov 32h,a


		mov a,25h
		movc a,@a+dptr
		mov 33h,a
		jnb p1.1,back1
		jnb p1.0,addri
		jnb p1.2,decri
		mov p3,#0ffh
dsp3:	mov p2,27h
		mov p0,#70h
		lcall delay

		mov p2,26h
		mov p0,#60h
		lcall delay

		mov p2,28h
		mov p0,#40h
		lcall delay

		mov p2,30h
		mov p0,#30h
		lcall delay

		mov p2,32h
		mov p0,#10h
		lcall delay

		mov p2,33h
		mov p0,#00h
		lcall delay

		mov p0,#50h
		mov p2,29h
		lcall delay

		mov p0,#20h
		mov p2,31h
		lcall delay

		jmp r
addri:	lcall delay1
		lcall delay1
		inc 21h
		mov a,21h
		cjne a,#13,over1
		mov 21h,#1

over1:	ljmp r

decri:	lcall delay1
		lcall delay1
		dec 21h
		mov a,21h
		cjne a,#0,over1
		mov 21h,#12
		jmp over1

back:	mov P3,#220			 ;跳转年调整，此俩个back 为按键防抖
		jmp nian

back1: 	lcall delay1
		jnb p1.1,back
 		ljmp dsp3



nian:	mov a,20h		; 日  	月 		年个位		年十位	 年百位	 年千位
		mov b,#10	   ; 20h	21h		22h			 23h	  24h	 25h
		div ab
		mov dptr,#tab1
		movc a,@a+dptr
		mov 26h,a		  ;转化出来的BCD码
		mov a,b				;	  	日个位		日十位
		movc a,@a+dptr		;		 27h		 26h
		mov 27h,a


		mov a,21h
		mov b,#10
		div ab				  ;	月个位		月十位
		movc a,@a+dptr
		mov 28h,a			;		 29h		28h
		mov a,b
		movc a,@a+dptr
		mov 29h,a


		mov a,22h
		movc a,@a+dptr		  ; 		年个位		年十位	 年百位	 年千位
		mov 30h,a			  ;		22h			 23h	  24h	 25h
							  ;BCD码	30h			 31h	  32h	 33h
		mov a,23h
		movc a,@a+dptr
		mov 31h,a

		mov a,24h
		movc a,@a+dptr
		mov 32h,a


		mov a,25h
		movc a,@a+dptr
		mov 33h,a


dsp4:	mov p2,27h
		mov p0,#70h			;年月日的BCD码
		lcall delay		   ;日个位		日十位	月个位		月十位 	年个位		年十位	 年百位	 年千位
						   ;27h		 26h	 29h		28h		30h			 31h	  32h	 33h
		mov p2,26h
		mov p0,#60h
		lcall delay

		mov p2,28h
		mov p0,#40h
		lcall delay

		mov p2,30h
		mov p0,#30h
		lcall delay

		mov p2,32h
		mov p0,#10h
		lcall delay

		mov p2,33h
		mov p0,#00h
		lcall delay

		mov p0,#50h
		mov p2,29h
		lcall delay

		mov p0,#20h
		mov p2,31h
		lcall delay

		jnb p1.1,goto
		jnb p1.0,addnian
		jnb p1.2,decnian
		mov p3,0ffh
		jmp nian
addnian:lcall delay1
		lcall delay1		  ;年个位		年十位	 年百位	 年千位
		inc 22h				 ;22h			 23h	  24h	 25h
		mov a,22h
		cjne a,#10,over4
		mov 22h,#0
		inc 23h
		mov a,23h
		cjne a,#10,over4
		mov 23h,#0
		inc 24h
		mov a,24h
		cjne a,#10,over4
		mov 24h,#0
		inc 25h
		mov a,25h
		cjne a,#10,over4
		mov 25h,#0

over4:	jmp nian

decnian:lcall delay1
		lcall delay1		  ;年个位		年十位	 年百位	 年千位
		dec 22h				 ;22h			 23h	  24h	 25h
		mov a,22h
		cjne a,#-1,over4
		mov 22h,#0
		dec 23h
		mov a,23h
		cjne a,#-1,over4
		mov 23h,#0
		dec 24h
		mov a,24h
		cjne a,#-1,over4
		mov 24h,#0
		dec 25h
		mov a,25h
		cjne a,#-1,over4
		mov 25h,#0
		jmp over4


goto1:	mov p3,#240
		jmp loop			   ;跳转到日

goto:	 lcall delay1
		jnb p1.1,goto1
 		ljmp nian



time:	mov r5,15h
		mov r2,14h					;秒脉冲得到后，软件计算时间
		mov r1,13h
		mov r0,12h

		inc r7
		mov a,r7
		cjne a,#20,T_ret
		inc r6
		cjne r6,#60,t
		mov r6,#0
		inc r0
		cjne r0,#10,t
		mov r0,#0
		inc r5
		cjne r5,#6,t
		mov r5,#0
		inc r1
		cjne r1,#10,next1
		mov r1,#0
		inc r2
next1:	cjne r2,#2,t
		cjne r1,#4,t
		mov r2,#0
		mov r1,#0
		inc 20h
                mov p3,#222
                call delay1
                mov a ,20h
                cjne a,#32,t
                mov 20h,#1

                inc 21h
                mov a,21h
                cjne a,#13,t
                mov 21h,#1
                inc 22h





;/*		cjne r1,#24,ask
;		mov r1,#0
;ask:	mov dptr,#tab1
;		mov a,r1
;		mov b,#10
;		div ab
;		movc a,@a+dptr
;		add a,r2
;		mov r2,a
;		mov a,b
;		movc a,@a+dptr
;		add a,r1
;		mov r1,a */
t:		mov r7,#0
T_ret:	mov TH0,#03ch
		mov TL0,#0b0h
		mov 12h,r0

		mov 13h,r1
										;将算出来的时间赋回地址中
		mov 14h,r2						;	小时	  分钟	   秒
										;	r2 r1     r5 r0   r3 r4
		mov 15h,r5
		reti
delay:         	mov 10h,#4
d3:		mov 11h,#5
d4:		djnz 11h,d4
		djnz 10h,d3
		ret

delay1:	mov 10h,#0bfh
d1:		mov 11h,#0ffh
d2:		djnz 11h,d2
		djnz 10h,d1
		ret
tab1:	db 0c0h,0f9h,0a4h,0b0h,99h,92h,82h,0f8h,00h,90h
   		    
longdelay1:
              mov  5ah,#50
           dl1:
              mov 5bh,#20
           dl2:
              mov  5ch,#248
              djnz 5ch,$
              djnz  5bh,dl2
              djnz  5ah,dl1
              ret
end
    
      


