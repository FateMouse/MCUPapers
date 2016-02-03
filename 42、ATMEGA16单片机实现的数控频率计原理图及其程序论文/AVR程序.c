//��������ͷ�ļ�
#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/signal.h>


/*------�궨��------*/
#define uchar	unsigned char
#define uint	unsigned int
#define ulong   unsigned long

//��������ͱ���Ӧ0�� 1�� 2��  3��  4��  5��  6��  7��  8��   9//
uchar Table[10]={0x3f,0x06,0x5b,0x4f,0x66,0x6d,0x7d,0x07,0x7f,0x6f};
uchar Data[4]={0,0,0,0};       //��ʾ��ʼֵ��0 0 0 0 
uint data=0;
uint CNT=0;
uchar fanwei=1;
unsigned long Load;

//��ʱ����
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

//��̬��ʾ����
void Display(uchar *p)         //����pΪ����ʾ��������
{uchar i,sel=0x01;           
 for(i=0;i<4;i++)
  {
   PORTA=Table[p[i]];          //��������
   PORTD=~sel;
   delay_us(500);              //��ʾ��ʱ    
   sel=sel<<1;                 //��λ����ʾǰһλ
  }
}

//����ֵ������
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
    fanwei=1;       //��λΪ1Hz
  	
  if((PINB&0X20)==0)
    fanwei=2;       //��λΪ1KHz
  if(fanwei==1)
    PORTC=0X01;
  if(fanwei==2)
    PORTC=0X02;		
}
//�˿ڳ�ʼ��
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


//��ʱT1��ʼ��
void timer1_init(void)
{
 TCCR1B = 0x00;//ֹͣ��ʱ��
 TIMSK |= 0x04;//�ж�����
 
 TCNT1H = 0x00;
 TCNT1L = 0x00;//��ʼֵ
 OCR1AH = 0xFF;
 OCR1AL = 0xFF;//ƥ��Aֵ
 OCR1BH = 0xFF;
 OCR1BL = 0xFF;//ƥ��Bֵ
 ICR1H  = 0xFF;
 ICR1L  = 0xFF;//���벶׽ƥ��ֵ
 TCCR1A = 0x00;
 TCCR1B = 0x07;//������ʱ��
}

//��ʱ��T1����жϷ������
#pragma interrupt_handler timer1_ovf_isr:9
void timer1_ovf_isr(void)
{
 CNT++;
 TCNT1H = 0x00; //��װֵ��λ
 TCNT1L = 0x00; //��װֵ��λ
}

//��ʱ��T2��ʼ��
void timer2_init(void)
{
 PORTC =0X01;
 TCCR2  = 0x00;//ֹͣ��ʱ��
 ASSR   = 0x08;//�첽ʱ��ģʽ  AS2=1
 TCNT2  = 0xFF;//��ʼֵ
 OCR2   = 0xFE;//ƥ��ֵ
 TIMSK |= 0x40;//�ж�����
 TCCR2  = 0x05;//������ʱ��    PCK/128
}


//T2����жϷ������
#pragma interrupt_handler timer2_ovf_isr:5
void timer2_ovf_isr(void)
{
 PORTC=0X02;
 TCCR1B = 0x00;                  //�رռ��� 
 //��ȡ����ֵ
 Load=CNT*65536+TCNT1;           //����Ƶ��ֵ
 TCNT1 = 0X00;                   //�������ֵ
 CNT=0;
 
 TCCR1B = 0x07;                  //��ʼ����
}


void init_devices(void)
{
 cli(); //��ֹ�����ж�
 MCUCR  = 0x00;
 MCUCSR = 0x80;//��ֹJTAG
 GICR   = 0x00;
 port_init();
 timer1_init();
 timer2_init();
 sei();//��ȫ���ж�
}
//������
void main(void)
{
init_devices();
 while(1)
 {
  xuanze();
  Process(Load,Data);    //����ֵ����
  Display(Data);        //��̬ɨ����ʾ
 }

 
}


