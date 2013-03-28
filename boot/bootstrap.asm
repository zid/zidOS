bits 32
global start

multiboot:
.magic dd 0x1BADB002
.flags dd 3
.checksum dd 0 - 0x1BADB002 - 3

create_pde:
	mov [esi], eax
	mov [edi], eax
	add esi, 8
	add edi, 8
	add eax, 0x200000
	dec ecx
	jnz create_pde
	ret

start:
	cli


	;Load stack pointer to top of lomem
	mov eax, [ebx+4]
	shl eax, 10
	mov esp, eax

	push 0
	push ebx


	mov edi, [ebx+24] ;Module table
	mov eax, [edi]    ;First module start
	mov ebx, [edi+4]  ;First module length
	push 0
	push eax          ;Save 64bit module start
	mov ecx, [eax+12] ;Length of bss
	add eax, [eax+8]  ;Start of bss

	push eax

	;Clear the bss
	mov edi, eax
	xor eax, eax
	rep stosd

	;Clear the screen
	mov edi, 0xB8000
	xor eax, eax
	mov ecx, 80*25*5
	rep stosd

	;Enable PAE
	mov eax, cr4
	or eax, 1 << 5
	mov cr4, eax

	;EFER.LM
	mov ecx, 0xC0000080
	rdmsr
	or eax, 1 << 8
	wrmsr

	pop edx

	;Create map from 0-2G twice
	mov esi, edx      ;PDE
	mov edi, edx      ;HIGH_PDE
	add edi, 4096 
	mov eax, 0x83     ;Flags
	mov ecx, 512      ;Number of entries
	call create_pde

	mov esi, edx
	add esi, (4096*2) ;PDPTE
	mov eax, edx
	add eax, 3        ;PDE + 3
	mov [esi], eax

	mov esi, edx
	add esi, (4096*3)+4080 ;HIGH_PDPTE
	mov eax, edx
	add eax, 3+4096   ;HIGH_PDE + 3
	mov [esi], eax

	mov esi, edx
	add esi, (4096*4) ;PML4
	mov eax, edx
	add eax, (4096*2)+3 ;PDPTE +3
	mov [esi], eax

	add esi, 4088
	mov eax, edx
	add eax, (4096*3)+3 ;HIGH_PDPTE + 3
	mov [esi], eax

	mov eax, edx
	add eax, (4096*4)
	mov cr3, eax
	
	;Enable paging
	mov eax, cr0
	or eax, 1<<31
	mov cr0, eax

	;Load 64bit GDT
	lgdt [gdt]

	;Reload segments
	jmp 8:longmode

bits 64
longmode:
	mov ax, 16
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax

	;Load stack pointer into 64bit space
	xor rax, rax
	mov eax, esp
	mov rbx, 0xFFFFFFFF80000000
	or rax, rbx
	mov rsp, rax

	pop rdx		 ;header.o
	mov rax, [rdx+16];kmain symbol

	pop rdi		 ;e820
	or rdi, rbx
	jmp rax

	jmp $

align 16
gdt:
	dw 23
	dd gdt + 16
	dd 0

align 16
gdt_table:
	dq 0
	dq 0xAF9B000000FFFF
	dq 0xAF93000000FFFF
