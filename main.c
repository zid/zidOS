
static void print(unsigned short *d, const char *s)
{
	while(*s)
		*d++ = *s++ | 0xF00;
}

void kmain(unsigned int r)
{
	unsigned short *video = (unsigned short *)0xB80A0;
	const char msg[] = "Working in long mode.";

	r = 0;
	print(video+r, msg);
	while(1)
	;
}
