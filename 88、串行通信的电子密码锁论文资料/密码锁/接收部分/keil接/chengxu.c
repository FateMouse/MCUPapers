#include <reg52.h>
#define uchar unsigned char
#define uint  unsigned  int	
uchar duan[11]={0xbf,0xc0,0Xf9,0xa4,0xb0,0x99,0x92,0x82,0xf8,0x80,0x90};	 //����Ķε�λ��
uchar wei[6]={0X7f,0Xbf,0Xdf,0Xef,0xf7,0xfb};    //λ�Ŀ��ƶ�	(������)
//uchar wei[6]={0X80,0X40,0X20,0X10,0x08,0x04};      //λ�Ŀ��ƶ�	(����)
uchar aj[6]={0xbf,0Xbf,0xbf,0xbf,0xbf,0xbf};
uchar z,x,c,v,b,n;	//������������
uchar  count;
uchar  pwflag;//�����Ƿ���ȷ�ı�־λ
uchar m[6]={8,8,8,8,8,8}; //��ʼ����
static uchar mbuf[6];///���������
sbit fmq=P3^7;
uchar shuju;
uchar chuli;
sbit cesi=P3^5;
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
                              ���ڽ�������
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
pwflag = pwcmp();if(pwflag==1){fmq=1;}
}

RI=0;
i++;
//}
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
case 0xe7: if (count<6) { m[count]=1;mbuf[count]=1; count++;}break;
case 0xd7: if (count<6) { m[count]=2;mbuf[count]=2; count++;}break;
case 0xb7: if (count<6) { m[count]=3;mbuf[count]=3; count++;}break;
case 0x77: if (count<6) { m[count]=4;mbuf[count]=4; count++;}break;
case 0xeb: if (count<6) { m[count]=5;mbuf[count]=5; count++;}break;
case 0xdb: if (count<6) { m[count]=6;mbuf[count]=6; count++;}break;
case 0xbb: if (count<6) { m[count]=7;mbuf[count]=7; count++;}break;
case 0x7b: if (count<6) { m[count]=8;mbuf[count]=8; count++;}break;
case 0xed: if (count<6) { m[count]=9;mbuf[count]=9; count++;}break;
case 0xdd: if (count<6) { m[count]=10;mbuf[count]=10;count++;}break;
case 0xbd: if (count==6) {pwflag = pwcmp();if(pwflag==1){fmq=1;}}break; 
case 0x7d: if (count<=6) {count=0;QX=1;}break;

} } 

/*************************************************************************
                     ���ڳ�ʼ��,������9600����ʽ1
**************************************************************************/
void Init_Com(void)
{
TMOD = 0x20;
PCON = 0x00;
SCON = 0x50;
TH1 = 0xFd;
TL1 = 0xFd;
TR1 = 1;
}

/*************************************************************************
                                ������	
**************************************************************************/
 void main()
{ 

uchar key;
Init_Com();//���ڳ�ʼ��
count=0;
P0=0xbf;
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
  disp();
  if(cesi==0){{pwflag = pwcmp();if(pwflag==1){fmq=1;}}}
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