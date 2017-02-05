
SECTIONS {
    kernel 0x8000:
    {
        bin/o/kernel.o
        bin/o/video.o
        bin/o/util.o
        bin/o/main.o
        bin/o/taskList.o
        bin/o/int80h.o
        bin/o/time.o
        bin/o/task1.o
        bin/o/task2.o
        bin/o/taskApp.o
        bin/o/taskKernel.o
        bin/o/ps.o
        bin/o/memcheck.o
    }
}
