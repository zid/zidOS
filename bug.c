#include "bug.h"
#include "print.h"
#include "cpu.h"

void bug(const char *msg)
{
	clear_screen(GREEN);
	print(msg);
	cpu_halt();
}
