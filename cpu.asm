global cpu_halt

cpu_halt:
	cli
	hlt
	jmp $
