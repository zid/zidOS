global cpu_halt, read_msr

cpu_halt:
	cli
	hlt
	jmp $

read_msr:
	mov ecx, edi
	xor rax, rax
	rdmsr
	shl rdx, 32
	or rax, rdx
	ret
