//24c01-24c16读写驱动程序，
sbit a0=ACC^0;			//定义ACC的位，利用ACC操作速度最快
sbit a1=ACC^1;
sbit a2=ACC^2;
sbit a3=ACC^3;
sbit a4=ACC^4;
sbit a5=ACC^5;
sbit a6=ACC^6;
sbit a7=ACC^7;

void s24(void) {
	_nop_();scl=0;sda=1;scl=1;_nop_();sda=0;_nop_();scl=0;
}
void s240(void) {
	_nop_();scl0=0;sda0=1;scl0=1;_nop_();sda0=0;_nop_();scl0=0;
}
void p24(void) {
	sda=0;scl=1;_nop_();sda=1;
}
void p240(void) {
	sda0=0;scl0=1;_nop_();sda0=1;
}
unsigned char rd24(void) {
	sda=1;
	scl=1;a7=sda;scl=0;
	scl=1;a6=sda;scl=0;
	scl=1;a5=sda;scl=0;
	scl=1;a4=sda;scl=0;
	scl=1;a3=sda;scl=0;
	scl=1;a2=sda;scl=0;
	scl=1;a1=sda;scl=0;
	scl=1;a0=sda;scl=0;
	sda=1;scl=1;scl=0;
	return(ACC);
}

void wd24(unsigned char dd) {
	ACC=dd;
	sda=a7;scl=1;scl=0;
	sda=a6;scl=1;scl=0;
	sda=a5;scl=1;scl=0;
	sda=a4;scl=1;scl=0;
	sda=a3;scl=1;scl=0;
	sda=a2;scl=1;scl=0;
	sda=a1;scl=1;scl=0;
	sda=a0;scl=1;scl=0;
	sda=1;scl=1;
}

unsigned char read(unsigned int address){
	unsigned char dd;
	dd=((address&0x7ff)/256)<<1;
	s24();wd24(0xa0|dd);scl=0;wd24(address);scl=0;
	s24();wd24(0xa1|dd);scl=0;dd=rd24();p24();return(dd);
}

void write(unsigned int address,unsigned char dd){
	unsigned char ddd;
	ddd=((address&0x7ff)/256)<<1;
	s24();wd24(0xa0|ddd);scl=0;wd24(address);scl=0;wd24(dd);scl=0;p24();
	time=0;					//time为定时器时间参考，time增加1代表1ms,如果没有用定时器，取消该行
	while (1) {
		s24();
		wd24(0xa0|ddd);
		sda=1;
		if (sda==0) break;
		if (time>10) break;	//此行防止由于eeprom器件损坏后的死循环
		scl=0;
	}
}