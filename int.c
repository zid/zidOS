#include "print.h"

void default_interrupt_handler(int n)
{
	char msg[] = "..: Unhandled interrupt\n";
	msg[0] = ((n & 0xF0)>>4)["0123456789ABCDEF"];
	msg[1] = ((n & 0x0F)>>0)["0123456789ABCDEF"];

	print(msg);
}
