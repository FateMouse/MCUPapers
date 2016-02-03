#include <reg52.h>
#define uchar unsigned char
#define uint  unsigned  int	
uchar duan[11]={0xff,0xc0,0Xf9,0xa4,0xb0,0x99,0x92,0x82,0xf8,0x80,0x90};	 //����Ķε�λ��
//uchar wei[6]={0X7f,0Xbf,0Xdf,0Xef,0xf7,0xfb};    //λ�Ŀ��ƶ�	(������)
uchar wei[6]={0X80,0X40,0X20,0X10,0x08,0x04};      //λ�Ŀ��ƶ�	(����)
uchar aj[6]={0xbf,0Xbf,0xbf,0xbf,0xbf,0xbf};
uchar z,x,c,v,b,n;	//������������
uchar  count;
uchar  pwflag;//�����Ƿ���ȷ�ı�־λ
uchar m[6]={8,8,8,8,8,8}; //��ʼ����
uchar CLK;
static uchar mbuf[6];///���������
sbit fmq=P3^7;
uchar QX;

/******************************************************************

��ʱ����

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

��ʱ����

******************************************************************/
void delay1(uchar t)
{
 unsigned char i,j,k;
for(i=t;i>0;i--)
for(j=20;j>0;j--)
for(k=248;k>0;k--);

}
/**********************************************************************
                ����ܶ�̬ɨ��
*********************************************************************/
void xianshi()
 { 
 /*****************����ת��*****************************/ 
      
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
                                ����Դ��ж�	
**************************************************************************/
bit pwcmp(void)
{
	bit flag;
	uchar i;
	for (i=0;i<6;i++)
	{
		if (m[i]==mbuf[i])flag = 1;   //*������ȷ*/
		else  {	flag = 0;i=6; } //*�������*/
	}
	return(flag);
}
/*************************************************************************
                                ȡ��ֵ	
**************************************************************************/
uchar getkey(void)///�õ���ֵ
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
                              ���ڷ�������
**************************************************************************/
/*void disp(void)
{
uchar i;
for(i=6;i>=0;i--)
{
SBUF=mbuf[i];
while(!TI);
TI=0;
}
}
/*************************************************************************
                              �ָ���ʼֵ
**************************************************************************/
void chushiz(void)
{	  count=0;
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
                                �жϼ�ֵ	
**************************************************************************/
void Getch (uchar i)
{

switch (i) //�жϼ�ֵ����һ�������£�
{
case 0xe7: if (count<6) { mbuf[count]=1; count++;SBUF=65;while(!TI);TI=0;}break;
case 0xd7: if (count<6) { mbuf[count]=2; count++;SBUF=66;while(!TI);TI=0;}break;
case 0xb7: if (count<6) { mbuf[count]=3; count++;SBUF=67;while(!TI);TI=0;}break;
case 0x77: if (count<6) { mbuf[count]=4; count++;SBUF=68;while(!TI);TI=0;}break;
case 0xeb: if (count<6) { mbuf[count]=5; count++;SBUF=69;while(!TI);TI=0;}break;
case 0xdb: if (count<6) { mbuf[count]=6; count++;SBUF=70;while(!TI);TI=0;}break;
case 0xbb: if (count<6) { mbuf[count]=7; count++;SBUF=71;while(!TI);TI=0;}break;
case 0x7b: if (count<6) { mbuf[count]=8; count++;SBUF=72;while(!TI);TI=0;}break;
case 0xed: if (count<6) { mbuf[count]=9; count++;SBUF=73;while(!TI);TI=0;}break;
case 0xdd: if (count<6) { mbuf[count]=10;count++;SBUF=74;while(!TI);TI=0;}break;
case 0xbd: if (count==6) {pwflag = pwcmp();if(pwflag==1){fmq=1;}}break; 
case 0x7d: if (count<=6) {count=0;QX=1;}break;

} } 

/*************************************************************************
                     ���ڳ�ʼ��,������9600����ʽ1
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

void timer0(void) interrupt 1
{
 TH0=0xdc;
 TL0=0x32;
 xianshi();

}

/*************************************************************************
                                ������	
**************************************************************************/
 void main()
{ 

 
uchar key;
initTimer();
initUart();
TR0=1;
ET0=1;
count=0;
QX=0;
//P0=0x00;
fmq=0;
while(1)
	{
P1=0x0f;
if(P1!=0x0f)  
 {
  delay(400);
   
  key=getkey(); 
  Getch(key);
  delay(400); 
  
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
P0=0X00;
xianshi();
QX=0;
count=0;
}  

}
}		