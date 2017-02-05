;------------------------------------------------------------------------------
; tarea2.asm
;
; Autor: Leandro Beretta <lea.beretta@gmail.com> | Agosto 2012
;
; Tarea 2 - Muestra la fecha en la pantalla
;------------------------------------------------------------------------------

GLOBAL tarea2, tarea2Size

%include "src/inc/defines.asm"

tarea2:

    xor r9, r9
    pop rsi

    mov rdi, OBTENER_ORDEN_TAREA
    int 80h

    mov r9, rax
    add r9, BASE_Y_INFO_TAREA
 
    mov rdi, OBTENER_PRIV_TAREA
    int 80h
    push rsi

    xor r11, r11
    add r11, BASE_X_INFO_TAREA


    cmp rax, 7
    jz app_task
    add r11, 0
    jmp end_list_x
    app_task:
        add r11, 39
    end_list_x:

    mov rbx, pid
    mov rsi, COLOR_TAREA_1_2
    mov rdx, r11
    mov rcx, r9
    mov rdi, PUTS_FUNC
    int 80h
    
    pop rax
    mov rbx, rax
    push rax
    mov rsi, COLOR_TAREA_1_2
    mov rdx, r11
    add rdx, 6
    mov rcx, r9
    mov r8, 2
    mov rdi, PUTN_FUNC
    int 80h
    
    mov rbx, pipe
    mov rsi, COLOR_TAREA_1_2
    mov rdx, r11
    add rdx, 8
    mov rcx, r9
    mov rdi, PUTC_FUNC
    int 80h

    mov rbx, priv
    mov rsi, COLOR_TAREA_1_2
    mov rdx, r11
    add rdx, 10
    mov rcx, r9
    mov rdi, PUTS_FUNC
    int 80h

    pop rsi
    mov rdi, OBTENER_PRIV_TAREA
    int 80h
    push rsi

    cmp rax, 3
    jz kernel_priv
    mov rbx, app
    jmp priv_end
    kernel_priv:
        mov rbx, kernel
    priv_end:

    mov rsi, COLOR_TAREA_1_2
    mov rdx, r11
    add rdx, 13
    mov rcx, r9
    mov rdi, PUTC_FUNC
    int 80h

    mov rbx, pipe
    mov rsi, COLOR_TAREA_1_2
    mov rdx, r11
    add rdx, 15
    mov rcx, r9
    mov rdi, PUTC_FUNC
    int 80h

    mov rbx, te
    mov rsi, COLOR_TAREA_1_2
    mov rdx, r11
    add rdx, 17
    mov rcx, r9
    mov rdi, PUTS_FUNC
    int 80h

    mov rsi, qword[rsp]
    mov rdi, OBTENER_TIEMPO_EJECUCION_TAREA
    int 80h
    
    mov rbx, rax
    mov rsi, COLOR_TAREA_1_2
    mov rdx, r11
    add rdx, 25
    mov rcx, r9
    mov r8, 5
    mov rdi, PUTN_FUNC
    int 80h

    mov rbx, pipe
    mov rsi, COLOR_TAREA_1_2
    mov rdx, r11
    add rdx, 27
    mov rcx, r9
    mov rdi, PUTC_FUNC
    int 80h

    mov rbx, ticks
    mov rsi, COLOR_TAREA_1_2
    mov rdx, r11
    add rdx, 29
    mov rcx, r9
    mov rdi, PUTS_FUNC
    int 80h

    pop rsi
    mov rdi, OBTENER_TICKS_TAREA
    int 80h
    push rsi

    mov rbx, rax
    mov rsi, COLOR_TAREA_1_2
    mov rdx, r11
    add rdx, 33
    mov rcx, r9
    mov r8, 2
    mov rdi, PUTN_FUNC
    int 80h

    mov rsi, COLOR_KERNEL_2
    mov rdx, 58
    mov rcx, 0
    mov rdi, IMPRIMIR_FECHA
    int 0x80
    
    jmp tarea2
tarea2Size equ $ - tarea2
