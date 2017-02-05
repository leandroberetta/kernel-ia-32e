/*-----------------------------------------------------------------------------
-- main.c
--
-- Autor: Leandro Beretta <lea.beretta@gmail.com> | Agosto 2012
--
-- Funcion principal del kernel
-----------------------------------------------------------------------------*/

#include "inc/defines.h"

const char mensajeKernel[] = " Kernel                                                                         \0";
const char mensajeBottom[] = " Leandro Beretta <lea.beretta@gmail.com> | Septiembre 2012           | Menu <h> \0";

extern unsigned long tarea0, tarea1, tarea2, ps, memcheck;
extern unsigned long tarea0Size, tarea1Size, tarea2Size, psSize, memcheckSize;

void main() {
    puts(mensajeKernel,COLOR_KERNEL_2,0,0);
    puts(mensajeBottom,COLOR_KERNEL_2,0,24);
    
    inicializarTareas(&tarea0,&tarea0Size);
    agregarTarea(&tarea1,APP_PRIV,PERMANENTE,TICKS_DFLT, &tarea1Size);
    agregarTarea(&tarea2,APP_PRIV,PERMANENTE,TICKS_DFLT, &tarea2Size);
    agregarTarea(&ps,KERNEL_PRIV,PERMANENTE,TICKS_DFLT, &psSize);
    agregarTarea(&memcheck,KERNEL_PRIV,PERMANENTE,TICKS_DFLT, &memcheckSize);

}

unsigned int convertirDec(unsigned int numHexa) {
    int numDec = 0;
    if(numHexa > 0x9 && numHexa <= 0x19) 
        numDec = numHexa - 6;
    else if(numHexa > 0x19 && numHexa <= 0x29)
        numDec = numHexa - 12;
    else if(numHexa > 0x29 && numHexa <= 0x39)
        numDec = numHexa - 18;
    else if(numHexa > 0x39 && numHexa <= 0x49)
        numDec = numHexa - 24;
    else if(numHexa > 0x49 && numHexa <= 0x59)
        numDec = numHexa - 30;
    else 
        numDec = numHexa;
    
    return numDec;
}

void imprimirMenu() {
    puts("0 - Agregar tarea (P0) | Shift + 0 - Remover tarea (P0)\0", COLOR_KERNEL, 1,18);
    puts("3 - Agregar tarea (P3) | Shift + 3 - Remover tarea (P3)\0", COLOR_KERNEL, 1,19);
    puts("p - PS                 | Shift + x - Remover ultima tarea (P0/P3)\0", COLOR_KERNEL, 1, 20);
    puts("m - Verificar memoria  | F1 - T1++ | F2 - T2++ | F3 - T1-- | F4 - T2--\0", COLOR_KERNEL,1,21);
}
