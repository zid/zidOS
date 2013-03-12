CFLAGS = -W -Wall -nostartfiles -nodefaultlibs -nostdlib -ffreestanding -Os -g

install: os.bin
	cp os.bin fs/boot/
	sync

os.bin: header.o bootstrap.o main.o
	ld -Tlink header.o bootstrap.o main.o -o os.bin -z max-page-size=4096

header.o: header.asm
	yasm -felf64 header.asm -o header.o

bootstrap.o: bootstrap.asm
	yasm -felf64 bootstrap.asm -o bootstrap.o

main.o: main.c
	gcc -c main.c $(CFLAGS)

run:
	bochs

clean:
	@rm *.o os.bin
