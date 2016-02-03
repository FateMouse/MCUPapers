////////////////////////汇诚科技////////////////////
//////////////////http://www.ourhc.cn///////////////
///////////////////步进电机按键实现正反转调试程序/////////////

#include<reg52.h> 
#define ZERO 0XC0; 
#define ONE  0XF9;
#define TWO  0XA4;
#define THREE 0XB0;
#define FOUR  0X99;
#define FIVE  0X92;
#define SIX   0X82;
#define SEVEN 0XF8;
#define EIGHT 0X80;
#define NINE  0x90
#define unint unsigned int
 
code unsigned char runz[8]={ 0x03,0x0b,0x09,0x0d,0x0c,0x0e,0x06,0x07}; //正转动数组
code unsigned char runf[8]={ 0x07,0x06,0x0e,0x0c,0x0d,0x09,0x0b,0x03}; //反转动数组

unsigned char a,b,s,i,j,k,z;

int y=5;//定义转动速度，数值越大电机转速越慢反之则快

sbit P2_0=P2^0;//正转按键
sbit P2_1=P2^1;//反转按键
sbit P2_2=P2^2;//加速按键
sbit P2_3=P2^3;//减速按键
sbit P2_4=P2^4;//加减速使能端

void delay(i)//延时函数
  {
      for(j=0;j<i;j++)
      for(k=0;k<250;k++);
  }


void frun()// 反转运行
 {
     for(z=0;z<8;z++)
        {
            P1=runf[z];
            delay(y);
         }
}
void zrun()// 正转运行
{

   for(z=0;z<8;z++)
       { 
         P1=runz[z];
         delay(y);
       }
}
void anjian()
{	if(P2_4==0)
    {  
      if(P2_2==0)
      {
	  delay(2);
	  while(!P2_2);
	  a++;
	  if(a>=9)a=9;
      }
       if(P2_3==0)
      {
	  delay(2);
	  while(!P2_3);
	  a--;
	  if(a<=0)a=0;
       }
	 }
}

/*void timer0( ) interrupt 1 //定时器0工作方式1
{
anjian();
TH0=(65536-2)/256;	  //重装计数初值
TL0=(65536-2)%256;	  //重装计数初值
} */
main()
{
a=5;
b=0;
/*TMOD=0X01;			  //定时器中断0

TH0=(65536-2)/256;	  //定时时间高八位初值
TL0=(65536-2)%256;	  //定时时间低八位初值
EA=1;				  //开CPU中断
ET0=1;				  //开T/C0中断
TR0=1; */
   while(1)
    { 
	 if(P2_0==0)
      {
	  while(!P2_0);	
	  	  b=1;
      }
       if(P2_1==0)
      {
	  while(!P2_1);
	  b=2;
       }
	 anjian();  
	   switch(b)
	{
	case 0: break;
	case 1: frun();break;
	case 2: zrun();	break;
	default:break;	
	} 
		switch(a)
	{
	case 0:y=100; P3=ZERO;break;
	case 1:y=75; P3=ONE;	break;
	case 2:y=60; P3=TWO;	break;
	case 3:y=45; P3=THREE;break;
	case 4:y=35; P3=FOUR; break;
	case 5:y=25; P3=FIVE; break;
	case 6:y=20; P3=SIX;	break;
	case 7:y=15; P3=SEVEN;break;
	case 8:y=10; P3=EIGHT; break;
	case 9:y=5; P3=NINE; break;
	default:break;	
	}
      
   }
}