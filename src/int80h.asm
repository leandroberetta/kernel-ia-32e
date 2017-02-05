;------------------------------------------------------------------------------
; int80h.asm
;
; Autor: Leandro Beretta <lea.beretta@gmail.com> | Agosto 2012
;
; Llamadas al Kernel
;------------------------------------------------------------------------------

EXTERN imprimirTiempo, imprimirFecha, puts, putn, putc, borrarPantallaParcial
EXTERN obtenerTicksTarea, obtenerPrivilegioTarea, obtenerTiempoEjecucionTarea
EXTERN obtenerEsPermanente, obtenerOrdenTarea, obtenerCantidadTareasConPrivilegio

GLOBAL int80h

%include "src/inc/defines.asm"


; Procedimiento: int80h
;
; Parametros: rdi -> Accion
;
; Punto de entrada para llamadas de anillo 3

int80h:
    pushfq
    push rbx
    push rcx
    push rdx

    cmp rdi, IMPRIMIR_TIEMPO
    jz imprimir_tiempo
    cmp rdi, IMPRIMIR_FECHA
    jz imprimir_fecha
    cmp rdi, PS
    jz ps
    cmp rdi, OBTENER_TICKS_TAREA
    jz obtener_ticks_tarea
    cmp rdi, OBTENER_PRIV_TAREA
    jz obtener_priv_tarea
    cmp rdi, OBTENER_ES_PERMANENTE
    jz obtener_es_permanente
    cmp rdi, PUTS_FUNC
    jz puts_func
    cmp rdi, PUTN_FUNC
    jz putn_func
    cmp rdi, PUTC_FUNC
    jz putc_func
    cmp rdi, OBTENER_ORDEN_TAREA
    jz obtener_orden_tarea
    cmp rdi, BORRAR_PANTALLA_PARCIAL
    jz borrar_pantalla_parcial
    cmp rdi, OBTENER_CANTIDAD_TAREAS
    jz obtener_cantidad_tareas
    cmp rdi, OBTENER_TIEMPO_EJECUCION_TAREA
    jz obtener_tiempo_ejecucion_tarea

    imprimir_tiempo:
        call imprimirTiempo
        jmp end_int80h
    imprimir_fecha:
        call imprimirFecha
        jmp end_int80h
    ps:
        jmp end_int80h
    obtener_ticks_tarea:
        mov rdi, rsi
        call obtenerTicksTarea
        jmp end_int80h
    obtener_priv_tarea:
        mov rdi, rsi
        call obtenerPrivilegioTarea
        jmp end_int80h
    obtener_es_permanente:
        mov rdi, rsi
        call obtenerEsPermanente
        jmp end_int80h
    puts_func:
        mov rdi, rbx
        call puts
        jmp end_int80h
    putn_func:
        mov rdi, rbx
        call putn
        jmp end_int80h
    putc_func:
        mov rdi, rbx
        call putc
        jmp end_int80h
    obtener_orden_tarea:
        mov rdi, rsi
        call obtenerOrdenTarea
        jmp end_int80h
    borrar_pantalla_parcial:
        call borrarPantallaParcial
        jmp end_int80h
    obtener_cantidad_tareas:
        mov rdi, rsi
        call obtenerCantidadTareasConPrivilegio
        jmp end_int80h
    obtener_tiempo_ejecucion_tarea:
        mov rdi, rsi
        call obtenerTiempoEjecucionTarea

    end_int80h:
    
    push rax

    mov al, 0x20
    out 0x20, al
    
    pop rax
    pop rdx
    pop rcx
    pop rbx
    popfq
    
    iretq
