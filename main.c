#include "print.h"
#include "cpu.h"
#include "apic.h"

void kmain(unsigned int r)
{
	(void)r;
	print("Working in long mode.\n");
	interrupts_init();
	interrupts_enable();

	apic();

	cpu_halt();
}
