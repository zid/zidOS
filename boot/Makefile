boot.bin: bootstrap.o
	ld bootstrap.o -melf_i386 -Tlinker.ld -o boot.bin


bootstrap.o: bootstrap.asm
	yasm bootstrap.asm -felf32

clean:
	@rm *.o boot.bin
