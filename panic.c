#include "print.h"
#include "cpu.h"

void panic(const char *msg)
{
	print(msg);
	cpu_halt();
}
