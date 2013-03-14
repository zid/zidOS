CFLAGS = -W -Wall -nostartfiles -nodefaultlibs -nostdlib -fno-builtin -ffreestanding -O3 -g -mno-mmx -mno-sse -mno-sse2 -mno-sse3
SRC = $(wildcard *.c)
OBJ = $(SRC:.c=.o)
ASMSRC = $(wildcard *.asm)
ASMOBJ = $(ASMSRC:.asm=.o)

install: os.bin
	cp os.bin fs/boot/
	sync

prep:
	mkdir -p fs
	losetup /dev/loop1 fs.bin
	losetup /dev/loop2 -o 32256 /dev/loop1
	mount /dev/loop2 fs

os.bin: $(OBJ) $(ASMOBJ)
	ld -Tlink $(OBJ) $(ASMOBJ) -o os.bin -z max-page-size=4096

%.o : %.asm
	yasm -felf64 $^ -o $@
	
%.o : %.c
	gcc $^ -c -o $@ $(CFLAGS)

run:
	bochs

clean:
	@rm *.o os.bin
