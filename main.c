#include "print.h"
#include "cpu.h"
#include "apic.h"
#include "mem.h"

void kmain(unsigned int *e820)
{
	int i;
	print("Working in long mode.\n");
	interrupts_init();
	interrupts_enable();

	mem_init(e820);

	cpu_halt();
}
