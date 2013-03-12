global start
BITS 32

section .text
start:
	cli
	; Point the stack somewhere
	mov esp, 0x100000

	; Reset eflags
	xor edx, edx
	push edx
	popf

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
	mov eax, PML4
	mov cr3, eax

	;Enable paging
	mov eax, cr0
	or eax, 1 << 31
	xchg bx, bx
	mov cr0, eax

	;Load 64bit gdt
	lgdt [gdt]
	;Jump to long mode
	jmp 8:longmode
longmode:
	mov ax, 16
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	
	jmp $

section .data
align 4096

PML4:
dq PDPTE + 3
PML4_END:
times 4096-(PML4_END-PML4) db 0

PDPTE:
dq PDE + 3
PDPTE_END:
times 4096-(PDPTE_END-PDPTE) db 0

PDE:
dq 0x000083
dq 0x200083
dq 0x400083
dq 0x600083
dq 0x800083
dq 0xA00083
dq 0xC00083
dq 0xE00083
PDE_END:
times 4096-(PDE_END-PDE) db 0

align 8
gdt:
	dw 23
	dq gdt_table
gdt_table:
	dq 0
	dq 0xAF9B000000FFFF
	dq 0xAF93000000FFFF
str1 db "Hello, World!",0

