#include<reg52.h> 
#define unint unsigned int
void delay();

void anjian();
void frun();
void zrun();
code unsigned char runz[8]={ 0x03,0x0b,0x09,0x0d,0x0c,0x0e,0x06,0x07}; //正转动数组
code unsigned char runf[8]={ 0x07,0x06,0x0e,0x0c,0x0d,0x09,0x0b,0x03}; //反转动数组
code unsigned char seg7code[10]={ 0xc0,0xf9,0xa4,0xb0,0x99,0x92,0x82,0xf8,0x80,0x90}; //显示段码 数码管字跟：
unsigned char a,b,s,i,j,k,z,gw,sw,bw,speed,m;
int y=31;//定义转动速度，数值越大电机转速越慢反之则快
sbit P2_0=P2^0;//正转按键
sbit P2_1=P2^1;//反转按键
sbit P2_2=P2^2;//加速按键
sbit P2_3=P2^3;//减速按键	
sbit P1_7=P1^7;


main()
{ P1_7=0;
a=0;
b=0;
while(1)
  {

	 if(P2_0==0)
      {
	  while(!P2_0);	
	  	  b=1;
		  P0=seg7code[1];
      }
       if(P2_1==0)
      {
	  while(!P2_1);
	  b=2;
	  P0=seg7code[2];
       }
	 anjian();  
	  switch(b)
	{
	case 0: break;
	case 1: frun();break;
	case 2: zrun();	break;
	default:break;	
	} 
	switch(y)
	{
	case 7:speed=100;break;
	case 9:speed=99;break;
	case 11:speed=98;break;
	case 13:speed=97;break;
	case 15:speed=96;break;
	case 17:speed=95;break;
	case 19:speed=94;break;
	case 21:speed=93;break;
	case 23:speed=92;break;
	case 25:speed=91;break;
	case 27:speed=90;break;
	case 29:speed=89;break;
	case 31:speed=88;break;
	case 33:speed=87;break;
	case 35:speed=86;break;
	case 37:speed=85;break;
	case 39:speed=84;break;
	case 41:speed=83;break;
	case 43:speed=82;break;
	case 45:speed=81;break;
	case 47:speed=80;break;
	case 49:speed=79;break;
	case 51:speed=78;break;
	case 53:speed=77;break;
	case 55:speed=76;break;
	case 57:speed=75;break;
	case 59:speed=74;break;
	case 61:speed=73;break;
	case 63:speed=72;break;
	case 65:speed=71;break;
	case 67:speed=70;break;
	case 69:speed=69;break;
	case 71:speed=68;break;
    case 73:speed=67;break;
	case 75:speed=66;break;
	case 77:speed=65;break;
	case 79:speed=64;break;
	case 81:speed=63;break;
	case 83:speed=62;break;
	case 85:speed=61;break;
	case 87:speed=60;break;
	case 89:speed=59;break;
	case 91:speed=58;break;
	case 93:speed=57;break;
	case 95:speed=56;break;
	case 97:speed=55;break;
	case 99:speed=54;break;
	case 101:speed=53;break;
	case 103:speed=52;break;
	case 105:speed=51;break;
	case 107:speed=50;break;
	case 109:speed=49;break;
	case 111:speed=48;break;
	case 113:speed=47;break;
	case 115:speed=46;break;
	case 117:speed=45;break;
	case 119:speed=44;break;
	case 121:speed=43;break;
	case 123:speed=42;break;
	case 125:speed=41;break;
	case 127:speed=40;break;
	case 129:speed=39;break;
	case 131:speed=38;break;
	case 133:speed=37;break;
	case 135:speed=36;break;
	case 137:speed=35;break;
	case 139:speed=34;break;
	case 141:speed=33;break;
	case 143:speed=32;break;
	case 145:speed=31;break;
	case 147:speed=30;break;
	case 149:speed=29;break;
	case 151:speed=28;break;
	case 153:speed=27;break;
	case 155:speed=26;break;
	case 157:speed=25;break;

	default:break;
	}
  }
 
   }

void delay(i)//延时函数
  {
      for(j=0;j<i;j++)
   	  for(k=0;k<30;k++);   
	 display();  
  }

  void delay2(m)//延时函数
  {
      for(j=0;j<m;j++);
   	  for(k=0;k<255;k++);   
	  	  
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
{	 P1_7=0;
      if(P2_2==0)
      {
	  
	  if(!P2_2);
	  delay2(255);
	  delay2(255);
	  delay2(255);
	  delay2(255);
	  y--;
	  if(y<=7)y=7;
	   P0=seg7code[3];
	   }
      if(P2_3==0)
      {
	  
	  if(!P2_3);
	  delay2(255);
	  delay2(255);
	  delay2(255);
	  delay2(255);
	  P0=seg7code[4];
	  if((y<46)&&(y>7))y=+2;
	  if((y<157)&&(y>47))y++;
	  if(y>=157)y=157;
       }
  }
	  
 display()
{
bw=speed/100;
sw=speed%100/10;
gw=speed%10;


P2=P2&0x7f; //P2.7 输出低电平，选通千位数
P3=seg7code[0]; //取出千位数，查表，输出。
delay2(8); //延时
P2=P2|0xf0; //销隐
P2=P2&0xbf; //P2.6 输出低电平，选通百位数
P3=seg7code[bw]; //取出百位数，查表，输出。
delay2(8); //延时
P2=P2|0xf0; //销隐
P2=P2&0xdf; //P2.5 输出低电平，选通十位数
P3=seg7code[sw]; //取出十位数，查表，输出。
delay2(8); //延时
P2=P2|0xf0; //销隐
P2=P2&0xef;
P3=seg7code[gw]; //取出个位数，查表，输出。
delay2(8);
P2=P2|0xf0;



}

