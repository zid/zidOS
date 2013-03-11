os.bin: header.o bootstrap.o
	ld -Tlink header.o bootstrap.o -o os.bin -z max-page-size=4096

header.o: header.asm
	nasm -felf64 header.asm -o header.o

bootstrap.o: bootstrap.asm
	nasm -felf64 bootstrap.asm -o bootstrap.o

install: os.bin
	cp os.bin fs/boot/
	sync

run:
	bochs

clean:
	@rm *.o os.bin
