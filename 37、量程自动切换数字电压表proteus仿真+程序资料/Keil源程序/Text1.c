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
sbit ST=P3^0;
sbit OE=P3^1;
sbit EOC=P3^2;
sbit CLK=P3^3;
sbit P34=P3^4;
sbit P35=P3^5;
sbit P36=P3^6;
sbit P20=P2^0;
sbit P21=P2^1;
sbit P22=P2^2;
sbit P23=P2^3;
sbit P17=P1^7;
//sbit s3=P2^7;  //位定义，控制模拟开关
sbit s2=P2^6;
sbit s1=P2^5;
#define	 _v10 {s1=1;s2=0;}
#define	 _v20 {s1=0;s2=1;}
 

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
 P20=0;
 P21=1;
 P22=1;
 P23=1;
 Delay(10);
 P1=0x00;
 P1=dispbitcode[dispbuf[2]];
 P17=1;
 P20=1;
 P21=0;
 P22=1;
 P23=1;
 Delay(10); 
 P1=0x00;
 P1=dispbitcode[dispbuf[1]];
 P20=1;
 P21=1;
 P22=0;
 P23=1;
 Delay(10);
 P1=0x00;
 P1=dispbitcode[dispbuf[0]];
 P20=1;
 P21=1;
 P22=1;
 P23=0;
 Delay(10);
 P1=0x00;
}
void main()
{
TimeInitial();
P34=0;
P35=0;
P36=0;
_v20;
m=4;
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

	if ( s1==0&&s2==1 && getdata<128)
	{ 	
		_v10;
		m=2;
		
      	
	}
	else if( s1==1&&s2==0&&	 getdata>254)
	{
		_v20;
		m=4;

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
