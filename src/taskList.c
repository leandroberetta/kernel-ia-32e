/*-----------------------------------------------------------------------------
-- taskList.c
--
-- Autor: Leandro Beretta <lea.beretta@gmail.com> | Agosto 2012
--
-- Lista doblemente enlazada para administrar las tareas
-----------------------------------------------------------------------------*/

#include "inc/defines.h"

extern unsigned long tareaKernel, tareaKernelSize;
extern unsigned long tareaApp, tareaAppSize;

const char mensajeMaxTareas[] = "Se ha alcanzado la maxima cantidad de tareas\0";
const char mensajeSinTareasMovibles[] = "Se ha removido todas las tareas no permanentes\0";
const char mensajeSinTareasMovibles3[] = "Se ha removido todas las tareas no permanentes de privilegio 3\0";
const char mensajeSinTareasMovibles0[] = "Se ha removido todas las tareas no permanentes de privilegio 0\0";

struct tarea {
	struct tarea *next;
	struct tarea *prev;
	unsigned char privilegio;
    unsigned char orden;
	unsigned char ticks;
	unsigned char siempreActiva;
	unsigned int id;
	unsigned long tarea;
	unsigned int contexto;
    unsigned int te;
};

struct tarea vecTareas[MAX_TAREAS];
struct tarea *tareaActual;

unsigned char ordenKernel;
unsigned char ordenApp;

unsigned int ticksTareaActual;

void scheduler() {
    asm("pop %rbp;");

    asm("push %rax;"
        "push %rbx;"
        "push %rcx;"
        "push %rdx;"
        "push %rdi;"
        "push %rsi;"
        "pushfq;");

    if((ticksTareaActual) != 0) {
        ticksTareaActual--;
        tareaActual->te++;
    }
    else {    
        if(tareaActual->next != NULL)
            switchTo(tareaActual->next->contexto, tareaActual->contexto);
        else
            switchTo(vecTareas[TAREA_IDLE].contexto, tareaActual->contexto);
        
        asm("push %rax;"
            "push %rbx;"
            "push %rcx;"
            "push %rdx;"
            "push %rdi;"
            "push %rsi;"
            "pushfq;");
        
        tareaActual = tareaActual->next;

        if(tareaActual == NULL)
            tareaActual = vecTareas;

        ticksTareaActual = tareaActual->ticks;
    }
    
    enviarFinInterrupcion();

    asm("popfq;"
        "pop %rsi;"
        "pop %rdi;"
        "pop %rdx;"
        "pop %rcx;"
        "pop %rbx;"
        "pop %rax;");
    
    asm("iretq;");
}

void inicializarTareas(unsigned int tarea, unsigned int sizeTarea) {
	int i;
    
    ordenKernel = 1;
    ordenApp = 0;
    
	for (i=0; i<MAX_TAREAS; i++) {
		vecTareas[i].next = NULL;
		vecTareas[i].prev = NULL;
		vecTareas[i].tarea = NULL;
	}
	
	vecTareas[TAREA_IDLE].tarea = tarea;
	vecTareas[TAREA_IDLE].id = 0;
	vecTareas[TAREA_IDLE].privilegio = KERNEL_PRIV;
	vecTareas[TAREA_IDLE].orden = ordenKernel;
	vecTareas[TAREA_IDLE].siempreActiva = TRUE;
	vecTareas[TAREA_IDLE].ticks = TIME_FRAME;
    vecTareas[TAREA_IDLE].contexto =  BASE_PML4N + 7*4096;
    vecTareas[TAREA_IDLE].te = 0;
    
    crearPaginacionTarea(TAREA_IDLE, tarea, KERNEL_PRIV,sizeTarea);
    crearContextoTarea(TAREA_IDLE, KERNEL_PRIV);

    ticksTareaActual = vecTareas[TAREA_IDLE].ticks;
	tareaActual = &vecTareas[TAREA_IDLE];
}

unsigned int agregarTarea(unsigned long *tarea, 
                          unsigned int privilegio, 
                          unsigned int siempreActiva,
                          unsigned int ticks,
                          unsigned long *sizeTarea) {
	int idLibre;
    struct tarea *auxTarea;
	
    auxTarea = vecTareas;
	idLibre = buscarEspacioLibre();
	
	if (idLibre > 0) {

        crearPaginacionTarea(idLibre, (unsigned long) tarea, privilegio, (unsigned long) sizeTarea);
        crearContextoTarea(idLibre, privilegio);
        agregarParametrosTarea(idLibre);

		while (auxTarea->next != NULL)
			auxTarea = auxTarea->next;

		auxTarea->next = &vecTareas[idLibre];
    
		vecTareas[idLibre].tarea = (unsigned long) tarea;
		vecTareas[idLibre].prev = auxTarea;
		vecTareas[idLibre].privilegio = privilegio;
		vecTareas[idLibre].siempreActiva = siempreActiva;
		vecTareas[idLibre].id = idLibre;
		vecTareas[idLibre].ticks = ticks;
		vecTareas[idLibre].contexto =  BASE_PML4N + idLibre*8*4096 + 7*4096;
        vecTareas[idLibre].next = NULL;
        vecTareas[idLibre].te = 0;
    
        if(privilegio == KERNEL_PRIV) {
            vecTareas[idLibre].orden = ordenKernel;
            ordenKernel++;
        }
        else {
            vecTareas[idLibre].orden = ordenApp;
            ordenApp++;
        }

        vecTareas[TAREA_IDLE].ticks = calcularTicksTareaIdle();
		
		return TRUE;
	}
	return FALSE;
}

unsigned int removerUltimaTarea() {
    struct tarea *auxTarea;
	
    auxTarea = vecTareas;

	while (auxTarea->next != NULL)
		auxTarea = auxTarea->next;
	
	while (auxTarea->prev != NULL) {
        
		if (auxTarea->siempreActiva == FALSE && auxTarea->id != tareaActual->id) {
            
            if(auxTarea->orden <= 10) {
                if(auxTarea->privilegio == KERNEL_PRIV)
                    borrarPantallaParcial(BASE_X_INFO_TAREAS, BASE_Y_INFO_TAREAS + (auxTarea->orden), 112, 34);
                else
                    borrarPantallaParcial(BASE_X_INFO_TAREAS + 39, BASE_Y_INFO_TAREAS + (auxTarea->orden), 112, 34);
            }
			
            auxTarea->tarea = NULL;
			auxTarea->prev->next = auxTarea->next;
			if (auxTarea->next != NULL)
				auxTarea->next->prev = auxTarea->prev;
			auxTarea->next = NULL;
			auxTarea->prev = NULL;

            if(auxTarea->privilegio == KERNEL_PRIV)
                ordenKernel--;
            else
                ordenApp--;

            vecTareas[TAREA_IDLE].ticks = calcularTicksTareaIdle();
            
//            asm("int $32;");

			return TRUE;
		} else {
			auxTarea = auxTarea->prev;
		}
	}
	
	return FALSE;
}

unsigned int removerUltimaTareaConPrivilegio(unsigned int privilegio) {
    struct tarea *auxTarea;
	
    auxTarea = vecTareas;
	
	while (auxTarea->next != NULL)
		auxTarea = auxTarea->next;
	
	while (auxTarea->prev != NULL) {
		if (   auxTarea->siempreActiva == FALSE 
            && auxTarea->privilegio == privilegio
            && auxTarea->id != tareaActual->id) {

            if(auxTarea->orden <= 10) {
                if(privilegio == KERNEL_PRIV)
                    borrarPantallaParcial(BASE_X_INFO_TAREAS, BASE_Y_INFO_TAREAS + (auxTarea->orden), 112, 34);
                else
                    borrarPantallaParcial(BASE_X_INFO_TAREAS + 39, BASE_Y_INFO_TAREAS + (auxTarea->orden), 112, 34);
            }
			
            auxTarea->tarea = NULL;
			auxTarea->prev->next = auxTarea->next;
			if(auxTarea->next != NULL)
				auxTarea->next->prev = auxTarea->prev;
			auxTarea->next = NULL;
			auxTarea->prev = NULL;
            
            if(auxTarea->privilegio == KERNEL_PRIV)
                ordenKernel--;
            else
                ordenApp--;
            
            vecTareas[TAREA_IDLE].ticks = calcularTicksTareaIdle();
            
//            asm("int $32;");

			return TRUE;
		} else {
			auxTarea = auxTarea->prev;
		}
	}
	
	return FALSE;
}

int buscarEspacioLibre() {
	int idEspacio = -1;
	int i = 0;
    
    for(i=0; i<MAX_TAREAS; i++) {
	// Cuando encuentro una tarea en NULL significa que en esa posicion no hay tarea ubicada
        if(vecTareas[i].tarea == NULL)
            return i;
    }
    
    return idEspacio;
}

int calcularTicksTareaIdle() {
    int ticksTareasTotal = 0;

    struct tarea *auxTarea;

    auxTarea = &vecTareas[1];
    
    while(auxTarea != NULL) {
        ticksTareasTotal += auxTarea->ticks;
        auxTarea = auxTarea->next;
    }

    return (TIME_FRAME - ticksTareasTotal);
}

void evaluarCambiosTarea(int idKey, int shiftApretado) {
    int idTarea;
    int idAccion = MANTENER;
    int resultado;
    struct tarea *auxTarea;

    auxTarea = vecTareas;

    if(shiftApretado == TRUE) {
        if(idKey == 4) {
            resultado = removerUltimaTareaConPrivilegio(APP_PRIV);
            if(resultado == FALSE)
                imprimirMensaje(mensajeSinTareasMovibles3,COLOR_TAREA_1_2, 3, 20);
        }
        else if(idKey == 13) {
            resultado = removerUltimaTareaConPrivilegio(KERNEL_PRIV);
            if(resultado == FALSE)
                imprimirMensaje(mensajeSinTareasMovibles0,COLOR_TAREA_1_2, 3, 20);
        }
        else if(idKey == 45) {
            resultado = removerUltimaTarea();
            if(resultado == FALSE)
                imprimirMensaje(mensajeSinTareasMovibles,COLOR_TAREA_1_2, 3, 20);
        }
    } else if(shiftApretado == FALSE) {
        if(idKey == 4) {
            resultado = agregarTarea(&tareaApp,APP_PRIV,REMOVIBLE,2,&tareaAppSize);
            if(resultado == FALSE)
                imprimirMensaje(mensajeMaxTareas,COLOR_TAREA_IDLE, 3, 20);
        }
        else if(idKey == 11) {
            resultado = agregarTarea(&tareaKernel,KERNEL_PRIV,REMOVIBLE,2,&tareaKernelSize);
            if(resultado == FALSE) 
                imprimirMensaje(mensajeMaxTareas,COLOR_TAREA_IDLE, 3, 20);
        }
        
        switch (idKey) {
            case 59:
                idTarea = TAREA_1;
                idAccion = AUMENTAR;
                break;
            case 60:
                idTarea = TAREA_2;
                idAccion = AUMENTAR;
                break;
            case 61:
                idTarea = TAREA_1;
                idAccion = DISMINUIR;
                break;
            case 62:
                idTarea = TAREA_2;
                idAccion = DISMINUIR;
                break;
            default:
                return;
        }
    
        if(idAccion != MANTENER) {
            while(auxTarea->next != NULL && auxTarea->id != idTarea)
                auxTarea = auxTarea->next;
         
            if (auxTarea != NULL && auxTarea->id == idTarea) {
                if (idAccion == AUMENTAR && auxTarea->ticks < MAX_TICKS) 
                    auxTarea->ticks++;
                else if (idAccion == DISMINUIR && auxTarea->ticks > MIN_TICKS) 
                    auxTarea->ticks--;
            
                vecTareas[TAREA_IDLE].ticks = calcularTicksTareaIdle();
            }
        }
    }
}

long obtenerTiempoEjecucionTarea(unsigned int id) {
    struct tarea *auxTarea;
    int te = -1;

    auxTarea = vecTareas;
    
    while(auxTarea != NULL) {
        if(auxTarea->id == id)
            te = auxTarea->te;
        auxTarea = auxTarea->next;
    }

    return te;
}

long obtenerPrivilegioTarea(unsigned int id) {
    struct tarea *auxTarea;
    int privilegio = -1;

    auxTarea = vecTareas;
    
    while(auxTarea != NULL) {
        if(auxTarea->id == id)
            privilegio = auxTarea->privilegio;
        auxTarea = auxTarea->next;
    }

    return privilegio;
}

long obtenerTicksTarea(unsigned int id) {
    struct tarea *auxTarea;
    int ticks = -1;
    
    auxTarea = vecTareas;

    while(auxTarea != NULL) {
        if(auxTarea->id == id)
            ticks = auxTarea->ticks;
        auxTarea = auxTarea->next;
    }

    return ticks;
}

long obtenerEsPermanente(unsigned int id) {
    struct tarea *auxTarea;
    int siempreActiva = -1;
    
    auxTarea = vecTareas;
    
    while(auxTarea != NULL) {
        if(auxTarea->id == id)
            siempreActiva = auxTarea->siempreActiva;
        auxTarea = auxTarea->next;
    }

    return siempreActiva;
}

long obtenerOrdenTarea(unsigned int id) {
    struct tarea *auxTarea;
    int orden = -1;
    int ordenRelativo = -1;
    int div = 0;
    
    auxTarea = vecTareas;
    
    while(auxTarea != NULL) {
        if(auxTarea->id == id) {
            orden = auxTarea->orden;
        }
        auxTarea = auxTarea->next;
    }

    if(orden != -1) {
        div = orden/10;
        ordenRelativo = orden - div*10;
    }

    return ordenRelativo;
}

unsigned int obtenerCantidadTareasConPrivilegio(unsigned int privilegio) {
    struct tarea *auxTarea;
    int cantTareas = 0;

    auxTarea = vecTareas;

    while(auxTarea != NULL) {
        if(auxTarea->privilegio == privilegio)
            cantTareas++;
        auxTarea = auxTarea->next;
    }

    return cantTareas;
}

long esListaTareasCompleta() {
    return buscarEspacioLibre();
}

long obtenerTicksTareasTotal() {
    int ticksTareasTotal = 0;

    struct tarea *auxTarea;

    auxTarea = &vecTareas[0];
    
    while(auxTarea != NULL) {
        ticksTareasTotal += auxTarea->ticks;
        auxTarea = auxTarea->next;
    }

    return ticksTareasTotal;
}

long obtenerTiempoEjecucionTareasTotal() {
    int tiempoTotal = 0;

    struct tarea *auxTarea;

    auxTarea = vecTareas;

    while(auxTarea != NULL) {
        tiempoTotal += auxTarea->te;
        auxTarea = auxTarea->next;
    }
    
    return tiempoTotal;
}

