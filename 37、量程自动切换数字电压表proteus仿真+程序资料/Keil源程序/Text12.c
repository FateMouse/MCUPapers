 #include<reg52.h>
unsigned char code dispbitcode[]={0x3f,0x06,0x5b,0x4f,0x66,0x6d,0x7d,0x07,0x7f,0x6f};
unsigned char dispbuf[4];
unsigned int i;
unsigned int j;
unsigned int getdata;
unsigned int temp;
unsigned int temp1;
unsigned char count;
unsigned char d;
sbit ST=P2^4;
sbit OE=P2^5;
sbit EOC=P2^6;
sbit CLK=P2^7;
sbit ADD_A=P3^4;  //选择AD的输入端
sbit ADD_B=P3^5;
sbit ADD_C=P3^6;
sbit D0=P2^0;  //数码管的位控制端
sbit D1=P2^1;
sbit D2=P2^2;
sbit D3=P2^3;
sbit P17=P1^7;  //确定小数点的位置
sbit s1=P3^2;
sbit s2=P3^3;
#define	 _v0_5 {s1=1;s2=0;}
#define _v10 {s1=0;s2=1;}
 

unsigned char m;

void TimeInitial();
void Delay(unsigned int i);

void TimeInitial()
{ TMOD=0x10;
 TH1=(65536-200)/256;
 TL1=(65536-200)%256;
 EA=1;
 ET1=1;
 TR1=1;
 }
void Delay(unsigned int i)
{
  unsigned int j;
  for(;i>0;i--)
  {
  for(j=0;j<125;j++)
  {;}
  }
}
 
void Display()

{ 
P1=dispbitcode[dispbuf[3]];

 D0=0;	
 D1=1;
 D2=1;
 D3=1;
 Delay(10);
 P1=0x00;

 P1=dispbitcode[dispbuf[2]];
 if(m==2)
 {
 P17=1;
 }
 D0=1;
 D1=0;
 D2=1;
 D3=1;
 Delay(10); 
 P1=0x00;
 P1=dispbitcode[dispbuf[1]];
  if(m==10)
 {
	P17=1;
  }
 D0=1;
 D1=1;
 D2=0;
 D3=1;
 Delay(10);
 P1=0x00;
 P1=dispbitcode[dispbuf[0]]; 
 D0=1;
 D1=1;
 D2=1;
 D3=0;
 Delay(10);
 P1=0x00;
}
void main()
{
TimeInitial();
ADD_A=0;
ADD_B=0;
ADD_C=0;
_v10;
m=2;
while(1)
{  			 


	ST=0;
	OE=0;
	ST=1;
	ST=0;
	while(EOC==0);
	OE=1;
	getdata=P0;
	OE=0;
		 if ((s1==0) && (s2==1) && (getdata<6))
	{ 	
		ADD_A=1;
		_v0_5;

		m=10; 	
	}
	else if	((s1==1)&&(s2==0) && (getdata>254))
	{
		ADD_A=0;
		_v10;
	
		m=2;
	}


	temp=(getdata*1.0/255)*500*m;
	dispbuf[0]=temp%10;
	dispbuf[1]=temp/10%10;
	dispbuf[2]=temp/100%10;
	dispbuf[3]=temp/1000;
	Display();

}
}

void t1(void) interrupt 3 using 0
 {
  TH1=(65536-200)/256;
  TL1=(65536-200)%256;
  CLK=~CLK;
  }