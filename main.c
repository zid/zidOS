#include "print.h"
#include "cpu.h"

void kmain(unsigned int r)
{
	print("Working in long mode.\n");

	cpu_halt();
}
