#include <reg52.h>
#define uchar unsigned char
#define uint  unsigned  int	
uchar duan[11]={0xbf,0xc0,0Xf9,0xa4,0xb0,0x99,0x92,0x82,0xf8,0x80,0x90};	 //所需的段的位码
uchar wei[6]={0X7f,0Xbf,0Xdf,0Xef,0xf7,0xfb};    //位的控制端	(开发板)
//uchar wei[6]={0X80,0X40,0X20,0X10,0x08,0x04};      //位的控制端	(仿真)
uchar aj[6]={0xbf,0Xbf,0xbf,0xbf,0xbf,0xbf};
uchar z,x,c,v,b,n;	//定义数据类型
uchar  count;
uchar  pwflag;//密码是否正确的标志位
uchar m[6]={8,8,8,8,8,8}; //初始密码
uchar CLK;
uchar mbuf[6];///输入的密码
uchar cunzhi;
sbit xhd=P3^7;	 //信号灯
sbit cesi=P3^5;
uchar QX;
uchar shuju;
uchar chuli;

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
                                密码对错判断	
**************************************************************************/
bit pwcmp(void)
{
	bit flag;
	uchar i;
	for (i=0;i<6;i++)
	{
		if (m[i]==mbuf[i])flag = 1;   //*密码正确*/
		else  {	flag = 0;i=6; } //*密码错误*/
	}
	return(flag);
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
                              串口接收数据
**************************************************************************/
void disp(void)
{
uchar i;
//for(i=6;i>=0;i--)
//{
if(RI==1)
{
shuju=SBUF;
chuli=shuju;
if(chuli==0x00)
{
mbuf[i]=1;
}
if(chuli==0x01)
{
mbuf[i]=2;
}
if(chuli==0x02)
{
mbuf[i]=3;
}
if(chuli==0x03)
{
mbuf[i]=4;
}
if(chuli==0x04)
{
mbuf[i]=5;
}
if(chuli==0x05)
{
mbuf[i]=6;
}
if(chuli==0x06)
{
mbuf[i]=7;
}
if(chuli==0x07)
{
mbuf[i]=8;
}
if(chuli==0x08)
{
mbuf[i]=9;
}
if(chuli==0x09)
{
mbuf[i]=10;
}
if(chuli==0x75)
{
pwflag = pwcmp();if(pwflag==1){cesi=0;}
}

RI=0;
i++;
//}
}
}

/*************************************************************************
                                判断键值	
**************************************************************************/
void Getch (uchar i)
{

switch (i) //判断键值（那一个键按下）
{
case 0xe7: if (count<6) { mbuf[count]=1; xianshi();count++;}break;
case 0xd7: if (count<6) { mbuf[count]=2; xianshi();count++;}break;
case 0xb7: if (count<6) { mbuf[count]=3; xianshi();count++;}break;
case 0x77: if (count<6) { mbuf[count]=4; xianshi();count++;}break;
case 0xeb: if (count<6) { mbuf[count]=5; xianshi();count++;}break;
case 0xdb: if (count<6) { mbuf[count]=6; xianshi();count++;}break;
case 0xbb: if (count<6) { mbuf[count]=7; xianshi();count++;}break;
case 0x7b: if (count<6) { mbuf[count]=8; xianshi();count++;}break;
case 0xed: if (count<6) { mbuf[count]=9; xianshi();count++;}break;
case 0xdd: if (count<6) { mbuf[count]=10;xianshi();count++;}break;
case 0xbd: if (count==6) {pwflag = pwcmp();if(pwflag==1){xhd=0;}}break; 
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
disp();
P2=0XAA;
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