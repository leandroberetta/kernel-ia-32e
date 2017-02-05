;------------------------------------------------------------------------------
; ps.asm
;
; Autor: Leandro Beretta <lea.beretta@gmail.com> | Agosto 2012
;
; Tarea que muestra el estado del procesador
;------------------------------------------------------------------------------

EXTERN key, esListaTareasCompleta, puts

GLOBAL ps, psSize

%include "src/inc/defines.asm"

ps:
    xor r9, r9
    mov rsi, qword[rsp]
    mov rdi, OBTENER_ORDEN_TAREA
    int 80h
    cmp rax, 0
    jl ps

    mov r9, rax
    add r9, BASE_Y_INFO_TAREA
 
    mov rsi, qword[rsp]
    mov rdi, OBTENER_PRIV_TAREA
    int 80h
    
    cmp rax, 0
    jl ps
    
    xor r11, r11
    cmp rax, 7
    jz app_task
    add r11, 0
    jmp end_list_x
    app_task:
        add r11, 39
    end_list_x:
    
    add r11, BASE_X_INFO_TAREA

    mov rbx, pid
    mov rsi, COLOR_TAREA_PS
    mov rdx, r11
    mov rcx, r9
    mov rdi, PUTS_FUNC
    int 80h
    
    mov rbx, qword[rsp]
    mov rsi, COLOR_TAREA_PS
    mov rdx, r11
    add rdx, 6
    mov rcx, r9
    mov r8, 2
    mov rdi, PUTN_FUNC
    int 80h
    
    mov rbx, pipe
    mov rsi, COLOR_TAREA_PS
    mov rdx, r11
    add rdx, 8
    mov rcx, r9
    mov rdi, PUTC_FUNC
    int 80h

    mov rbx, priv
    mov rsi, COLOR_TAREA_PS
    mov rdx, r11
    add rdx, 10
    mov rcx, r9
    mov rdi, PUTS_FUNC
    int 80h

    mov rsi, qword[rsp]
    mov rdi, OBTENER_PRIV_TAREA
    int 80h
    cmp rax, 0
    jl ps

    cmp rax, 3
    jz kernel_priv
    mov rbx, app
    jmp priv_end
    kernel_priv:
        mov rbx, kernel
    priv_end:

    mov rsi, COLOR_TAREA_PS
    mov rdx, r11
    add rdx, 13
    mov rcx, r9
    mov rdi, PUTC_FUNC
    int 80h

    mov rbx, pipe
    mov rsi, COLOR_TAREA_PS
    mov rdx, r11
    add rdx, 15
    mov rcx, r9
    mov rdi, PUTC_FUNC
    int 80h

    mov rbx, te
    mov rsi, COLOR_TAREA_PS
    mov rdx, r11
    add rdx, 17
    mov rcx, r9
    mov rdi, PUTS_FUNC
    int 80h

    mov rsi, qword[rsp]
    mov rdi, OBTENER_TIEMPO_EJECUCION_TAREA
    int 80h
    
    cmp rax, 0
    jl ps

    mov rbx, rax
    mov rsi, COLOR_TAREA_PS
    mov rdx, r11
    add rdx, 25
    mov rcx, r9
    mov r8, 5
    mov rdi, PUTN_FUNC
    int 80h

    mov rbx, pipe
    mov rsi, COLOR_TAREA_PS
    mov rdx, r11
    add rdx, 27
    mov rcx, r9
    mov rdi, PUTC_FUNC
    int 80h

    mov rbx, ticks
    mov rsi, COLOR_TAREA_PS
    mov rdx, r11
    add rdx, 29
    mov rcx, r9
    mov rdi, PUTS_FUNC
    int 80h

    mov rsi, qword[rsp]
    mov rdi, OBTENER_TICKS_TAREA
    int 80h
    cmp rax, 0
    jl ps

    mov rbx, rax
    mov rsi, COLOR_TAREA_PS
    mov rdx, r11
    add rdx, 33
    mov rcx, r9
    mov r8, 2
    mov rdi, PUTN_FUNC
    int 80h
    
    mov r15, esListaTareasCompleta
    call r15

    cmp rax, 0
    jl continuar
    
    mov rdi, lempty
    mov rsi, COLOR_KERNEL
    mov rdx, 0
    mov rcx, 18
    mov r15, puts
    call r15
    
    mov rdi, lempty
    mov rsi, COLOR_KERNEL
    mov rdx, 0
    mov rcx, 19
    mov r15, puts
    call r15 

    mov rdi, lempty
    mov rsi, COLOR_KERNEL
    mov rdx, 0
    mov rcx, 20
    mov r15, puts
    call r15
    
    mov rdi, lempty
    mov rsi, COLOR_KERNEL
    mov rdx, 0
    mov rcx, 21
    mov r15, puts
    call r15
    
    mov rdi, lempty
    mov rsi, COLOR_KERNEL
    mov rdx, 0
    mov rcx, 22
    mov r15, puts
    call r15

    continuar:

    cmp qword[key], 25
    jz informar_ps
    jmp ps

    informar_ps:

        mov qword[key], 0

        mov rbx, ps_back
        mov rsi, COLOR_KERNEL_3
        mov rdx, 0
        mov rcx, 23
        mov rdi, PUTS_FUNC
        int 80h

        mov rsi, KERNEL_PRIV
        mov rdi, OBTENER_CANTIDAD_TAREAS
        int 80h

        mov rbx, rax
        mov rsi, COLOR_KERNEL_3
        mov rdx, 11
        mov rcx, 23
        mov r8, 2
        mov rdi, PUTN_FUNC
        int 80h

        mov rsi, APP_PRIV
        mov rdi, OBTENER_CANTIDAD_TAREAS
        int 80h

        mov rbx, rax
        mov rsi, COLOR_KERNEL_3
        mov rdx, 19
        mov rcx, 23
        mov r8, 2
        mov rdi, PUTN_FUNC
        int 80h

    jmp ps
psSize equ $ - ps
