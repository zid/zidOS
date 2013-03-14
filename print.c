#include "print.h"
#include "stdlib.h"

static unsigned short *vmem = (unsigned short *)0xB8000;

void clear_screen(colour c)
{
	unsigned char colour;
	unsigned int i;

	switch(c)
	{
		case GREEN:
			colour = 0xAA;
		break;
		default:
			colour = 0xFF;
		break;
	}

	vmem = (unsigned short *)0xB8000;

	for(i = 0; i < 80*25; i++)
	{
		vmem[i] = colour<<8;
	}
}

static void putchar(unsigned char c)
{
	if(vmem >= (unsigned short *)(0xB8000 + (80 * 25 * 2)))
	{
		vmem -= 80;
		memmove((void *)0xB8000, (void *)0xB8000 + 160, 80 * 24 * 2);
		memset( (void *)0xB8F00, 0, 160);
	}

	*vmem++ = 0xF00 | c;
}

static void newline(void)
{
	long p = (long)vmem;

	p = p - ((p - 0xB8000) % 160);
	p += 160;

	vmem = (unsigned short *)p;
}

void print(const char *msg)
{
	unsigned char c;

	while(1)
	{
		c = *msg++;

		switch(c)
		{
			case 0:
				return;
			break;
			case '\n':
				newline();
				continue;
			break;
			case '%':
			break;
		}

		putchar(c);
	}
}
