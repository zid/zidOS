global start
BITS 32

section .text
start:
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

	xchg bx, bx

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

	jmp $

section .data
str1 db "Hello, World!",0

