#include "print.h"
#include "cpu.h"

void kmain(unsigned int r)
{
	print("Working in long mode.\n");
	interrupts_init();
	interrupts_enable();

	__asm("int $37");

	cpu_halt();
}
