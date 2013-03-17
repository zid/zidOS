#include "apic.h"
#include "cpu.h"
#include "print.h"

#define APIC_BASE_MSR (0x1B)

void apic(void)
{
	unsigned long apic_base;

	apic_base = read_msr(APIC_BASE_MSR);
	print("APIC base: %lx\n", apic_base);
}
