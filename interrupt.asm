global interrupts_init
global interrupts_enable
extern default_interrupt_handler


interrupts_init:
	mov rax, int_handlers
	xor rcx, rcx

.loop:
	call install_interrupt
	add rax, 16
	inc cl
	jnz .loop

	lidt [IDT_info]
	ret

interrupts_enable:
	sti
	ret

install_interrupt:
	push rdi
	push rax
	push rcx

	mov rdi, IDT
	shl rcx, 4
	add rdi, rcx
	
	mov word [rdi], ax
	mov ax, cs
	mov word [rdi+2], ax
	mov word [rdi+4], 0x8000 | (0xE << 8)
	shr rax, 16
	mov word [rdi+6], ax
	shr rax, 16
	mov dword [rdi+8], eax
	mov dword [rdi+12], 0

	pop rcx
	pop rax
	pop rdi
	ret

%macro int_handler 1
	mov edi, %1
	xor eax, eax
	call default_interrupt_handler
	iretq
%endmacro 
align 16
int_handlers:


%assign i 0
%rep 256
	align 16
	int_handler i
%assign i i+1
%endrep

align 16

IDT_info:
dw 4095
dq IDT

align 4096
IDT:
times 4096 db 0
