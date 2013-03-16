global start
extern kmain, BSS_START, BSS_LEN
BITS 32

section .text
start:
	cli
	cld

	; clear bss
	xor eax, eax
	mov ecx, BSS_LEN
	mov edi, BSS_START
	rep stosd

	mov ecx, ebx
	
	; Grab the size of lomem
	add ebx, 4
	mov eax, dword [ebx]
	shl eax, 10
	mov esp, eax

	; Save the multiboot information
	push 0
	push ecx

	;Clear video
	mov edi, 0xB8000
	xor eax, eax
	mov ecx, (80*25*2)/4
	rep stosd


	;Print message
	mov esi, str1
	mov edi, 0xB8000
	xor eax, eax
	mov ah, 0xF
.loop:
	mov al, byte [esi]
	test al, al
	jz .out
	mov [edi], ax
	inc edi
	inc edi
	inc esi
	jmp .loop
.out:

	;Enable PAE
	mov eax, cr4
	or eax, 1 << 5
	mov cr4, eax

	;EFER.LM
	mov ecx, 0xC0000080
	rdmsr
	or eax, 1 << 8
	wrmsr

	;Set up page tables

	;Create mapping from 0 to 2GB twice
	mov esi, PDE
	mov edi, HIGH_PDE
	mov eax, 0x83
	mov ecx, 512
	call create_pde

	;First 1GB
	mov eax, PDPTE
	mov dword [eax], PDE + 3

	;Penultimate 1GB
	mov eax, HIGH_PDPTE
	add eax, 4080
	mov dword [eax], HIGH_PDE + 3

	;First 512GB
	mov eax, PML4
	mov edi, eax
	mov dword [edi], PDPTE + 3

	;Final 512GB
	add edi, 4088
	mov dword [edi], HIGH_PDPTE + 3

	mov cr3, eax

	;Enable paging
	mov eax, cr0
	or eax, 1 << 31
	mov cr0, eax

	;Load 64bit gdt
	lgdt [gdt]

	;Jump to long mode
	jmp 8:longmode

create_pde:
	mov [esi], eax
	mov [edi], eax
	add esi, 8
	add edi, 8
	add eax, 0x200000
	dec ecx
	jnz create_pde
	ret



[bits 64]
longmode:
	mov ax, 16
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax

	; Convert RSP to the highmem stack
	mov rbx, 0xFFFFFFFF80000000
	mov eax, esp
	mov ebx, eax
	mov rax, rbx
	mov rsp, rax

	xchg bx, bx
	pop rdi

	; Switch execution to highmem
	mov rax, 0xFFFFFFFF80000000
	add rax, kmain
	jmp rax

	cli
	hlt
	jmp $

section .data
align 8
gdt:
	dw 23
	dq gdt_table
gdt_table:
	dq 0
	dq 0xAF9B000000FFFF
	dq 0xAF93000000FFFF
str1 db "Hello, World!",0

section .bss
align 4096

     PML4  resb 4096
     PDPTE resb 4096
HIGH_PDPTE resb 4096
     PDE   resb 4096
HIGH_PDE   resb 4096
