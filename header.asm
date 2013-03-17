extern BSS_OFFSET, BSS_LEN, kmain
section .text
jmp kmain
align 8
dd BSS_OFFSET
dd BSS_LEN
dq kmain
