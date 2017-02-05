;------------------------------------------------------------------------------
; taskApp.asm
;
; Autor: Leandro Beretta <lea.beretta@gmail.com> | Agosto 2012
;
; Tarea generica con privilegios de aplicacion
;------------------------------------------------------------------------------

GLOBAL tareaApp, tareaAppSize

%include "src/inc/defines.asm"

tareaApp:
    xor r9, r9
    mov rsi, qword[rsp]
    mov rdi, OBTENER_ORDEN_TAREA
    int 80h
    
    cmp rax, 0
    jl tareaApp

    mov r9, rax
    add r9, BASE_Y_INFO_TAREA
 
    mov rsi, qword[rsp]
    mov rdi, OBTENER_PRIV_TAREA
    int 80h
    
    cmp rax, 0
    jl tareaApp
    
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
    mov rsi, 112
    mov rdx, r11
    mov rcx, r9
    mov rdi, PUTS_FUNC
    int 80h
    
    mov rbx, qword[rsp]
    mov rsi, 112
    mov rdx, r11
    add rdx, 6
    mov rcx, r9
    mov r8, 2
    mov rdi, PUTN_FUNC
    int 80h
    
    mov rbx, pipe
    mov rsi, 112
    mov rdx, r11
    add rdx, 8
    mov rcx, r9
    mov rdi, PUTC_FUNC
    int 80h

    mov rbx, priv
    mov rsi, 112
    mov rdx, r11
    add rdx, 10
    mov rcx, r9
    mov rdi, PUTS_FUNC
    int 80h

    mov rsi, qword[rsp]
    mov rdi, OBTENER_PRIV_TAREA
    int 80h
    
    cmp rax, 0
    jl tareaApp

    cmp rax, 3
    jz kernel_priv
    mov rbx, app
    jmp priv_end
    kernel_priv:
        mov rbx, kernel
    priv_end:

    mov rsi, 112
    mov rdx, r11
    add rdx, 13
    mov rcx, r9
    mov rdi, PUTC_FUNC
    int 80h

    mov rbx, pipe
    mov rsi, 112
    mov rdx, r11
    add rdx, 15
    mov rcx, r9
    mov rdi, PUTC_FUNC
    int 80h

    mov rbx, te
    mov rsi, 112
    mov rdx, r11
    add rdx, 17
    mov rcx, r9
    mov rdi, PUTS_FUNC
    int 80h

    mov rsi, qword[rsp]
    mov rdi, OBTENER_TIEMPO_EJECUCION_TAREA
    int 80h
    
    cmp rax, 0
    jl tareaApp

    mov rbx, rax
    mov rsi, 112
    mov rdx, r11
    add rdx, 25
    mov rcx, r9
    mov r8, 5
    mov rdi, PUTN_FUNC
    int 80h

    mov rbx, pipe
    mov rsi, 112
    mov rdx, r11
    add rdx, 27
    mov rcx, r9
    mov rdi, PUTC_FUNC
    int 80h

    mov rbx, ticks
    mov rsi, 112
    mov rdx, r11
    add rdx, 29
    mov rcx, r9
    mov rdi, PUTS_FUNC
    int 80h

    mov rsi, qword[rsp]
    mov rdi, OBTENER_TICKS_TAREA
    int 80h
    
    cmp rax, 0
    jl tareaApp

    mov rbx, rax
    mov rsi, 112
    mov rdx, r11
    add rdx, 33
    mov rcx, r9
    mov r8, 2
    mov rdi, PUTN_FUNC
    int 80h

    jmp tareaApp
tareaAppSize equ $ - tareaApp
