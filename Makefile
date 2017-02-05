#------------------------------------------------------------------------------
# Makefile
#
# Autor: Leandro Beretta <lea.beretta@gmail.com> | Agosto 2012
#------------------------------------------------------------------------------

# Paths
path_src=src/
path_bin=bin/
path_lst=bin/lst/
path_o=bin/o/

ld_flags=-m elf_x86_64 -b elf64-x86-64 -Tdata=0x5000 -T links.ld --oformat binary

all: bootloader video util kernel task1 task2 taskApp taskKernel ps int80h time memcheck main taskList

	ld $(ld_flags) -o $(path_bin)kernel.bin
	dd bs=512 count=2880 if=/dev/zero of=disk.img
	sudo mkfs.msdos -F 12 disk.img
	dd if=bin/bootloader.bin of=disk.img count=1 seek=0 conv=notrunc
	dd if=bin/kernel.bin of=disk.img seek=1 conv=notrunc

bootloader: $(path_src)bootloader.asm
	nasm -f bin $(path_src)bootloader.asm -o $(path_bin)bootloader.bin -DKERNEL_START=0x8000 -DKERNEL_SECTORS=60

video: $(path_src)video.asm
	nasm -f elf64 $(path_src)video.asm -o $(path_o)video.o -l $(path_lst)video.lst

util: $(path_src)util.asm
	nasm -f elf64 $(path_src)util.asm -o $(path_o)util.o

kernel: $(path_src)kernel.asm
	nasm -f elf64 $(path_src)kernel.asm -o $(path_o)kernel.o -l $(path_lst)kernel.lst

task1: $(path_src)tasks/task1.asm
	nasm -f elf64 $(path_src)tasks/task1.asm -o $(path_o)task1.o -l $(path_lst)task1.lst

task2: $(path_src)tasks/task2.asm
	nasm -f elf64 $(path_src)tasks/task2.asm -o $(path_o)task2.o -l $(path_lst)task2.lst

taskApp: $(path_src)tasks/taskApp.asm
	nasm -f elf64 $(path_src)tasks/taskApp.asm -o $(path_o)taskApp.o -l $(path_lst)taskApp.lst

taskKernel: $(path_src)tasks/taskKernel.asm
	nasm -f elf64 $(path_src)tasks/taskKernel.asm -o $(path_o)taskKernel.o -l $(path_lst)taskKernel.lst

ps: $(path_src)tasks/ps.asm
	nasm -f elf64 $(path_src)tasks/ps.asm -o $(path_o)ps.o -l $(path_lst)ps.lst

int80h: $(path_src)int80h.asm
	nasm -f elf64 $(path_src)int80h.asm -o $(path_o)int80h.o -l $(path_lst)int80h.lst

time: $(path_src)time.asm
	nasm -f elf64 $(path_src)time.asm -o $(path_o)time.o

memcheck: $(path_src)tasks/memcheck.asm
	nasm -f elf64 $(path_src)tasks/memcheck.asm -o $(path_o)memcheck.o

main: $(path_src)main.c
	gcc $(path_src)main.c -o $(path_o)main.o -c -m64

taskList: $(path_src)taskList.c
	gcc $(path_src)taskList.c -o $(path_o)taskList.o -c -m64

clean:   
	rm -f $(path_o)*.o $(path_bin)*.bin disk.img $(path_lst)*.lst *~ *.*~
