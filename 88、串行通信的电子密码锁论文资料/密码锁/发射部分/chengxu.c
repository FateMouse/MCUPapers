#include <reg52.h>
#define uchar unsigned char
#define uint  unsigned  int	
uchar duan[11]={0xbf,0xc0,0Xf9,0xa4,0xb0,0x99,0x92,0x82,0xf8,0x80,0x90};	 //所需的段的位码
//uchar wei[6]={0X80,0X40,0X20,0X10,0x08,0x04};      //位的控制端	(仿真)
uchar wei[6]={0X7f,0Xbf,0Xdf,0Xef,0xf7,0xfb};    //位的控制端	(开发板)
uchar mbuf[6];//密码位
uchar  count;
uchar CLK;
sbit fmq=P3^7;
uchar QX;

/******************************************************************

延时函数

******************************************************************/
void delay(uchar t)
{
  uchar i,j;
   for(i=0;i<t;i++)
   {
   	 for(j=1000;j>0;j--);
	 { ;
	 }
   }
}
/******************************************************************

延时函数

******************************************************************/
void delay1(uchar p)
{
 unsigned char i,j,k;
for(i=p;i>0;i--)
for(j=20;j>0;j--)
for(k=248;k>0;k--);

}

/**********************************************************************
                数码管动态扫描
*********************************************************************/
void xianshi()
 { 
 /*****************数据转换*****************************/ 
      
	  P2=wei[0];
	  P0=duan[mbuf[0]];
	  delay(1);  
  	  P2=wei[1];
      P0=duan[mbuf[1]];
	  delay(1);  
   	  P2=wei[2];
      P0=duan[mbuf[2]];
	  delay(1);  
      P2=wei[3];
      P0=duan[mbuf[3]];
	  delay(1); 
	  P2=wei[4];
      P0=duan[mbuf[4]];
	  delay(1);
	  P2=wei[5];
      P0=duan[mbuf[5]];
	  delay(1); 
}

/*************************************************************************
                                取键值	
**************************************************************************/
uchar getkey(void)///得到键值
{
uchar h,l,k;
while(P1!=0x0f)
  {
   h=P1&0x0f;
   P1=0xf0;
   l=P1&0xf0;
   k=h|l;
   return(k);
  }
}

/*************************************************************************
                                判断键值	
**************************************************************************/
void Getch (uchar i)
{

switch (i) //判断键值（那一个键按下）
{
case 0xe7: if (count<6) { mbuf[count]=1; count++;SBUF=0x55;while(!TI);TI=0;}break;
case 0xd7: if (count<6) { mbuf[count]=2; count++;SBUF=0Xf9;while(!TI);TI=0;}break;
case 0xb7: if (count<6) { mbuf[count]=3; count++;SBUF=0xa4;while(!TI);TI=0;}break;
case 0x77: if (count<6) { mbuf[count]=4; count++;SBUF=0xb0;while(!TI);TI=0;}break;
case 0xeb: if (count<6) { mbuf[count]=5; count++;SBUF=0x99;while(!TI);TI=0;}break;
case 0xdb: if (count<6) { mbuf[count]=6; count++;SBUF=0Xf9;while(!TI);TI=0;}break;
case 0xbb: if (count<6) { mbuf[count]=7; count++;SBUF=0x82;while(!TI);TI=0;}break;
case 0x7b: if (count<6) { mbuf[count]=8; count++;SBUF=0xf8;while(!TI);TI=0;}break;
case 0xed: if (count<6) { mbuf[count]=9; count++;SBUF=0x80;while(!TI);TI=0;}break;
case 0xdd: if (count<6) { mbuf[count]=10;count++;SBUF=0x90;while(!TI);TI=0;}break;
case 0xbd: if (count==6) {SBUF=75;while(!TI);TI=0;}break; 
case 0x7d: if (count<=6) {count=0;QX=1;}break;

} } 

/*************************************************************************
                     串口初始化,波特率9600，方式1
**************************************************************************/

void initTimer(void)
{
 TMOD=0x1;
 TH0=0xdc;
 TL0=0x32;
}

void initUart(void)
{
 TMOD|=0x20;
 SCON=0x50;
 TH1=0xfd;
 TL1=0xfd;
 TR1=1;
}

/*************************************************************************
                                主函数	
**************************************************************************/
 void main()
{ 
uchar key;
initTimer();
initUart();
count=0;
P1=0X0F;
while(1)
{
if(P1!=0X0F)
{
key=getkey(); //取键值
Getch(key);	//求值
delay1(20);
P1=0X0F;

}
xianshi();
if(QX==1)
{
mbuf[count]=0; count++;
mbuf[count]=0; count++;
mbuf[count]=0; count++;
mbuf[count]=0; count++;
mbuf[count]=0; count++;
mbuf[count]=0; 
xianshi();
QX=0;
count=0;
}  
}
}		