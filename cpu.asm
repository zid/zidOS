global cpu_halt, read_msr, reload_page_table

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

reload_page_table:
	mov rax, rdi
	mov rbx, 0xFFFFFFFF80000000
	sub rax, rbx
	mov cr3, rax
	ret
