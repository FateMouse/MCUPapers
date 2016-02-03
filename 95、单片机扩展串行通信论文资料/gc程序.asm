      org     0000h
      sjmp    start
      org     0030h
start:mov     30h,#00h
      mov     31h,#00h
      mov     a,30h
      mov     dptr,#ddss
      movc    A,@a+dptr
      cpl     a
      mov     p0,a
      mov     a,31h
      movc    a,@a+dptr
      cpl   a
      mov     p2,a
 main:jb      p1.0,m0
      lcall   dely0
      jb      p1.0,m0
      lcall   dely1
      lcall   z0
   m0:jb      p1.1,m1
      lcall   dely0
      jb      p1.1,m1
      lcall   dely1
      lcall   z1
   m1:jb      p1.2,m2
      lcall   dely0
      jb      p1.2,m2
      lcall   dely1
      lcall   dely1
      lcall   z2
   m2:jb      p1.3,m3
      lcall   dely0
      jb      p1.3,m3
      lcall   dely1
      lcall   z3
   m3:ljmp    main
dely0:mov     r7,#100
 dly0:mov     r6,#98
      nop
 dly1:djnz    r6,dly1
      djnz    r7,dly0
      ret
   z0:inc     30h
      mov     a,30h
      cjne    a,#0ah,abc0
      mov     30h,#00h
 abc0:mov     a,30h
      mov     dptr,#ddss
      movc    a,@a+dptr
      cpl     a
      mov     p0,a
      ret
   z1:inc     31h
      mov     a,31h
      cjne    a,#0ah,abc1
      mov     31h,#00h
 abc1:mov     dptr,#ddss
      mov     a,31h
      movc    a,@a+dptr
      cpl     a
      mov     p2,a
      ret
   z2:mov     r5,#00h
      mov     r4,#0ffh
      mov     dptr,#ddss
  z21:inc     r4
      lcall   dely1
      cjne    r4,#10,z22
      mov     r4,#0
      inc     r5
      cjne    r5,#10,z22
      ret
  z22:mov     a,r5
      movc    a,@a+dptr
      cpl     a
      mov     p2,a  
      mov     a,r4
      movc    a,@a+dptr
      cpl     a
      mov     p0,a 
      ljmp    Z21

   z3:mov     scon,#50h
      mov     tcon,#20h
      mov     th1,#0d9h
      mov     tl1,#0d9h
      setb    t1
      mov     a,30h
      mov     sbuf,a
wait0:jbc     ti,wait1
      sjmp    wait0
wait1:mov     a,31h
      mov     sbuf,a
wait2:jbc     ti,next
      sjmp    wait2
 next:nop
      ret
dely1:mov     r7,#250
 dly2:mov     r6,#250
      nop
 dly3:djnz    r6,dly3
      djnz    r7,dly2
      ret
 ddss:db      3fh,06h,5bh,4fh,66h
      db      6dh,7dh,07h,7fh,6fh
      end





