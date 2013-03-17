CFLAGS = -W -Wall -nostartfiles -nodefaultlibs -nostdlib -ffreestanding -O3 -g -mno-mmx -mno-sse -mno-sse2 -mno-sse3 -mcmodel=kernel -mno-red-zone -Iinclude/
SRC = $(wildcard *.c)
OBJ = $(SRC:.c=.o)
ASMSRC = $(wildcard *.asm)
ASMOBJ = $(ASMSRC:.asm=.o)

install: kernel.bin boot.bin
	cp boot/boot.bin fs/boot/
	cp kernel.bin fs/boot/
	sync

boot.bin:
	$(MAKE) -C boot/

prep:
	mkdir -p fs
	losetup /dev/loop1 fs.bin
	losetup /dev/loop2 -o 32256 /dev/loop1
	mount /dev/loop2 fs

kernel.bin: $(OBJ) $(ASMOBJ)
	ld -Tlink $(OBJ) $(ASMOBJ) -o kernel.bin -z max-page-size=4096 

%.o : %.asm
	yasm -felf64 $^ -o $@
	
%.o : %.c
	gcc $^ -c -o $@ $(CFLAGS)

run:
	bochs

clean:
	$(MAKE) -C boot clean
	@rm *.o kernel.bin
