;------------------------------------------------------------------------------
; memcheck.asm
;
; Autor: Leandro Beretta <lea.beretta@gmail.com> | Agosto 2012
;
; Tarea que verifica la memoria 
;------------------------------------------------------------------------------

EXTERN obtenerOrdenTarea, obtenerPrivilegioTarea, obtenerTiempoEjecucionTarea, obtenerTicksTarea
EXTERN puts, putn, putc, obtenerTicksTareasTotal, obtenerTiempoEjecucionTareasTotal
EXTERN key

GLOBAL memcheck, memcheckSize, idMemcheck

%include "src/inc/defines.asm"

idMemcheck dq 0
tiempoCheck dd 0

memcheck:
    xor r9, r9

;    xchg bx,bx   
;    mov rdi, qword[rsp]
;    mov r15, obtenerOrdenTarea
;    call r15

    xor r9, r9
    mov rsi, qword[rsp]
    mov rdi, OBTENER_ORDEN_TAREA
    int 80h
    
    cmp rax, 0
    jl memcheck

    mov r9, rax
    add r9, BASE_Y_INFO_TAREA
 
    mov rdi, qword[rsp]
    mov r15, obtenerPrivilegioTarea
    call r15

;     mov rsi, qword[rsp]
;     mov rdi, OBTENER_PRIV_TAREA
;     int 80h
    
    cmp rax, 0
    jl memcheck    
    
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

    mov rdi, qword[rsp]
    mov r15, obtenerPrivilegioTarea
    call r15

;    mov rsi, qword[rsp]
;    mov rdi, OBTENER_PRIV_TAREA
;    int 80h
    
    cmp rax, 0
    jl memcheck

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

    mov rdi, qword[rsp]
    mov r15, obtenerTiempoEjecucionTarea
    call r15

;    mov rsi, qword[rsp]
;    mov rdi, OBTENER_TIEMPO_EJECUCION_TAREA
;    int 80h
    
    cmp rax, 0
    jl memcheck

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

    mov rdi, qword[rsp]
    mov r15, obtenerTicksTarea
    call r15

;    mov rsi, qword[rsp]
;    mov rdi, OBTENER_TICKS_TAREA
;    int 80h
    
    cmp rax, 0
    jl memcheck

    mov rbx, rax
    mov rsi, 112
    mov rdx, r11
    add rdx, 33
    mov rcx, r9
    mov r8, 2
    mov rdi, PUTN_FUNC
    int 80h

    
    ; Verificacion de memoria

    cmp qword[key], 50
    jz verificar_mem
    jmp memcheck

    verificar_mem:
        mov rdi, mem_start
        mov rsi, COLOR_KERNEL_4
        mov rdx, 0
        mov rcx, 23
        mov r15, puts
        call r15
        
        mov qword[key], 0

        mov rax, qword[rsp]
        mov qword[idMemcheck], rax

        mov rax, BASE_PML4T
        mov cr3, rax

        movups xmm1, [check_55]
        movups xmm2, [check_AA]

        mov rsi, 0x400000
        mov rcx, 0x1FFFFF

        mov r15, obtenerTiempoEjecucionTareasTotal
        call r15
        mov qword[tiempoCheck], rax
    
        loop_check:
            movups xmm0, [rsi]
            movups [rsi], xmm1
            ptest xmm1, [rsi]
            jz error_memoria
            movups [rsi], xmm2
            ptest xmm2, [rsi]
            jz error_memoria
            movups [rsi], xmm0
            add rsi, 16
            loop loop_check
            jmp ok_memoria
    
        error_memoria:
            mov rdi, mem_error
            mov rsi, COLOR_KERNEL_3
            mov rdx, 0
            mov rcx, 23
            mov r15, puts
            call r15
            jmp memcheck

        ok_memoria:
        
            mov rdi, mem_ok
            mov rsi, COLOR_KERNEL_4
            mov rdx, 0
            mov rcx, 23
            mov r15, puts
            call r15
            
            mov r15, obtenerTiempoEjecucionTareasTotal
            call r15
            
            sub rax, qword[tiempoCheck]

            mov rdi, rax
            mov rsi, COLOR_KERNEL_4
            mov rdx, 60
            mov rcx, 23
            mov r8, 6
            mov r15, putn
            call r15

    jmp memcheck
memcheckSize equ $ - memcheck
