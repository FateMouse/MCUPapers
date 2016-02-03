 #include <reg51.h>
#define uchar unsigned char
sbit P00=P0^0;
//sbit P11=P1^1;
//sbit P12=P1^2;
sbit P01=P0^1;
sbit  in=P3^2;
uchar IRCOM[8];
uchar high,hug;	  //�ߵ�ƽ����
uchar pwm;	  //��ƽ����
uchar cnt,cat;
void key1cnt()
{
	while(IRCOM[5]==0x06)IRCOM[5]=0x00;
	P1= IRCOM[5];
	TR0=1;
	TR1=1;
	if(high!=pwm)
	{
		high++;
		if(high==pwm)
		{
			TR0=0;
			P00=1;	
		}
		else
		{
			if(high==0x09)
			{
				TR0=1;	
			}
		}
	}
}
void key2cnt()
{
	uchar temp;
	while(IRCOM[5]==0x44)IRCOM[5]=0x00;
	P1= IRCOM[5];
	TR0=1;
	TR1=1;
	if(high!=0x01)
	{
		high--;
		temp=pwm;
		temp--;
		if(high==0x01)
		{
			TR0=0;
			P00=0;	
		}
		else
		{
			if(high==temp)
			{
				TR0=1;	
			}
		}
	}
}
void key3cnt()
{
	P00=0;
	P01=0;
	TR0=0;
	TR1=0;
}
void delay(unsigned char x)      //x*0.14MS
{
 unsigned char i ;
  while(x--)
 {
  for (i =0;i<13;i++);
 }
}

void main()
{
	high=0x15;
	hug=0x15;
	pwm=0x30;
	cnt=0x01;
	cat=0x01;
//	cn=0x09;	
	TMOD=0x22;
	ET0=1;
	ET1=1;
	EA=1;
	EX0=1;
	TH0=(65535-20000)/256;
	TL0=(65535-20000)%256;
	TH1=(65535-20000)/256;
	TL1=(65535-20000)%256;
//	TR0=1;
//	TR1=1;
	IT0=1;
	in=1 ;
	P00=0;
	P01=0;
	while(1)
	{
	    //P1= IRCOM[5];
		           /**  0000 0110(0x06) (��) 

0100 0111(0x47)����   0000 0111 (0x07)���У�       0100 0000(0x40)���ң�
                        
						0100 0100(0x44) ���£�**/
		switch(IRCOM[5])
		{
			case 0x06:key1cnt();break;//ǰ��
			case 0x44:key2cnt();break;//����
			case 0x07:key3cnt();break;//ֹͣ 
		}
		/*if(P11==0)
		key1cnt();
		if(P12==0)
		key2cnt();*/
	} 
}
void int0() interrupt 1
{
	IP=0x09;
	TH0=(65535-2000)/256;
	TL0=(65535-2000)%256;
	cnt++;
	if((cnt!=high)&&(cnt==pwm))
	{
		cnt=0x01;
		P00=1;
	}
	else if(cnt==high)
	{
		P00=0;	
	}
		
} 
void int1() interrupt 3
{
	IP=0x03;
	TH1=(65535-2000)/256;
	TL1=(65535-2000)%256;
	cat++;
	if((cat!=hug)&&(cat==pwm))
	{
		cat=0x01;
		P01=1;
	}
	else if(cat==hug)
	{
		P01=0;
	}
		
}



/****�����߽�����򣨿������·��********/
/****��ֵ�͸�P1�ڣ�ֻ��ʶ��16����****/
/****���ⷢ���ǲ���38K����Ƶ����ģ���֪�ź�����Ϊ1/38ms=0.263ms,���ߵ͵�ƽΪ0.1325ms****/

it0() interrupt 0
{
 unsigned char i,j,k,N=0;
 IP=0x0A;
  EA = 0 ;
I1:
  for (i=0;i<10;i++)
   {
    if (in==0) break;
 if (i==9) {EA =1 ;return ;}
   }
  delay(20);
    if (in==1) goto I1;  //ȷ��IR�źų���
  while (!in)            //�� IR ��Ϊ�ߵ�ƽ
    {delay(1) ;}

 for (j=0 ;j<4 ;j++)
 { 
  for (k=0 ;k<8 ;k++)
  {
   while (in)            //�� IR ��Ϊ�͵�ƽ
     {delay(1);}
    while (!in)          //�� IR ��Ϊ�ߵ�ƽ
     {delay(1);}
     while (in)           //����IR�ߵ�ƽʱ��
      {
    delay(1);
    N++ ;           
    if (N>=30) {EA=1 ;return ;}
   }
     IRCOM[j]=IRCOM[j]>>1;
     if (N>=8) {IRCOM[j] = IRCOM[j] | 0x80 ;}
     N=0;
  }
 }
   
   if (IRCOM[2]!=~IRCOM[3]) {EA=1 ;return ;}
   IRCOM[5]=IRCOM[2];
   P1= IRCOM[5];
   delay(100);
   EA = 1 ;
}


