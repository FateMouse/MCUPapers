//包含所需头文件
#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/signal.h>


/*------宏定义------*/
#define uchar	unsigned char
#define uint	unsigned int
#define ulong   unsigned long

//数码管字型表，对应0， 1， 2，  3，  4，  5，  6，  7，  8，   9//
uchar Table[10]={0x3f,0x06,0x5b,0x4f,0x66,0x6d,0x7d,0x07,0x7f,0x6f};
uchar Data[4]={0,0,0,0};       //显示初始值：0 0 0 0 
uint data=0;
uint CNT=0;
uchar fanwei=1;
unsigned long Load;

//延时函数
void delay_us( int t)     //us
{
 do
 t--;
 while(t>1);
}
void delay_ms(unsigned int t)   //ms
{
 while(t!=0)
 {
  delay_us(1142);
  t--;
 }
}

//动态显示函数
void Display(uchar *p)         //参数p为待显示的数组名
{uchar i,sel=0x01;           
 for(i=0;i<4;i++)
  {
   PORTA=Table[p[i]];          //送字型码
   PORTD=~sel;
   delay_us(500);              //显示延时    
   sel=sel<<1;                 //移位以显示前一位
  }
}

//计数值处理函数
void Process(unsigned long i,uchar *p) 
{
 if(fanwei==2)
   i=i/1000;
 if(fanwei==1)
 {
   if(i>9999)
    i=9999;
 }	  
 p[0]=i/1000;
 i=i%1000;
 p[1]=i/100;
 i=i%100;
 p[2]=i/10;
 p[3]=i%10;
}

void xuanze (void)
{
  if((PINB&0X10)==0)
    fanwei=1;       //单位为1Hz
  	
  if((PINB&0X20)==0)
    fanwei=2;       //单位为1KHz
  if(fanwei==1)
    PORTC=0X01;
  if(fanwei==2)
    PORTC=0X02;		
}
//端口初始化
void port_init(void)
{
 PORTA = 0xFF;
 DDRA  = 0xFF;
 PORTB = 0xFF;
 DDRB  = 0x00;
 PORTC = 0xFF;
 DDRC  = 0xFF;
 PORTD = 0xFF;
 DDRD  = 0xFF;
}


//定时T1初始化
void timer1_init(void)
{
 TCCR1B = 0x00;//停止定时器
 TIMSK |= 0x04;//中断允许
 
 TCNT1H = 0x00;
 TCNT1L = 0x00;//初始值
 OCR1AH = 0xFF;
 OCR1AL = 0xFF;//匹配A值
 OCR1BH = 0xFF;
 OCR1BL = 0xFF;//匹配B值
 ICR1H  = 0xFF;
 ICR1L  = 0xFF;//输入捕捉匹配值
 TCCR1A = 0x00;
 TCCR1B = 0x07;//启动定时器
}

//定时器T1溢出中断服务程序
#pragma interrupt_handler timer1_ovf_isr:9
void timer1_ovf_isr(void)
{
 CNT++;
 TCNT1H = 0x00; //重装值高位
 TCNT1L = 0x00; //重装值低位
}

//定时器T2初始化
void timer2_init(void)
{
 PORTC =0X01;
 TCCR2  = 0x00;//停止定时器
 ASSR   = 0x08;//异步时钟模式  AS2=1
 TCNT2  = 0xFF;//初始值
 OCR2   = 0xFE;//匹配值
 TIMSK |= 0x40;//中断允许
 TCCR2  = 0x05;//启动定时器    PCK/128
}


//T2溢出中断服务程序
#pragma interrupt_handler timer2_ovf_isr:5
void timer2_ovf_isr(void)
{
 PORTC=0X02;
 TCCR1B = 0x00;                  //关闭计数 
 //读取计数值
 Load=CNT*65536+TCNT1;           //计算频率值
 TCNT1 = 0X00;                   //清除计数值
 CNT=0;
 
 TCCR1B = 0x07;                  //开始计数
}


void init_devices(void)
{
 cli(); //禁止所有中断
 MCUCR  = 0x00;
 MCUCSR = 0x80;//禁止JTAG
 GICR   = 0x00;
 port_init();
 timer1_init();
 timer2_init();
 sei();//开全局中断
}
//主函数
void main(void)
{
init_devices();
 while(1)
 {
  xuanze();
  Process(Load,Data);    //计数值处理
  Display(Data);        //动态扫描显示
 }

 
}


