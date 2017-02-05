;------------------------------------------------------------------------------
; handlers.asm
;
; Autor: Leandro Beretta <lea.beretta@gmail.com> | Agosto 2012
;
; Handlers para las interrupciones externas y las excepciones
;------------------------------------------------------------------------------

mensaje_exc_00          db      "Excepcion Nro: 00 | #DE | Divide Error"
                        db      0
mensaje_exc_01          db      "Excepcion Nro: 01 | #DB | RESERVED"
                        db      0
mensaje_exc_03          db      "Excepcion Nro: 03 | #BP | Breakpoint"
                        db      0
mensaje_exc_04          db      "Excepcion Nro: 04 | #OF | Overflow"
                        db      0
mensaje_exc_05          db      "Excepcion Nro: 05 | #BR | BOUND Range Exceeded"
                        db      0
mensaje_exc_06          db      "Excepcion Nro: 06 | #UD | Invalid Opcode"
                        db      0
mensaje_exc_07          db      "Excepcion Nro: 07 | #NM | Device Not Available"
                        db      0
mensaje_exc_08          db      "Excepcion Nro: 08 | #DF | Double Fault"
                        db      0
mensaje_exc_09          db      "Excepcion Nro: 09 |     | Coprocessor Segment Overrun"
                        db      0
mensaje_exc_10          db      "Excepcion Nro: 10 | #TS | Invalid TSS"
                        db      0
mensaje_exc_11          db      "Excepcion Nro: 11 | #NP | Segment Not Present"
                        db      0
mensaje_exc_12          db      "Excepcion Nro: 12 | #SS | Stack-Segment Fault"
                        db      0
mensaje_exc_13          db      "Excepcion Nro: 13 | #GP | General Protection"
                        db      0
mensaje_exc_14          db      "Excepcion Nro: 14 | #PF | Page Fault"
                        db      0
mensaje_exc_16          db      "Excepcion Nro: 16 | #MF | x87 FPU Floating-Point Error"
                        db      0
mensaje_exc_17          db      "Excepcion Nro: 17 | #AC | Alignment Check"
                        db      0
mensaje_exc_18          db      "Excepcion Nro: 18 | #MC | Machine Check"
                        db      0
mensaje_exc_19          db      "Excepcion Nro: 19 | #XM | SIMD Floating-Point Exception"
                        db      0

shiftPushed     dq      1 
key             dq      0

__00_exc:
    mov rdi, mensaje_exc_00
    mov rsi, 11110000b
    mov rdx, 1
    mov rcx, 1
    call imprimirMensaje
    jmp $

__01_exc:
    mov rdi, mensaje_exc_01
    mov rsi, 11110000b
    mov rdx, 1
    mov rcx, 1
    call imprimirMensaje
    jmp $

__03_exc:
    mov rdi, mensaje_exc_03
    mov rsi, 11110000b
    mov rdx, 1
    mov rcx, 1
    call imprimirMensaje
    jmp $

__04_exc:
    mov rdi, mensaje_exc_04
    mov rsi, 11110000b
    mov rdx, 1
    mov rcx, 1
    call imprimirMensaje
    jmp $

__05_exc:
    mov rdi, mensaje_exc_05
    mov rsi, 11110000b
    mov rdx, 1
    mov rcx, 1
    call imprimirMensaje
    jmp $

__06_exc:
    mov rdi, mensaje_exc_06
    mov rsi, 11110000b
    mov rdx, 1
    mov rcx, 1
    call imprimirMensaje
    jmp $
    
__07_exc:

    push rax
    push rbx
    push rcx

    mov rbx, cr0
    and ebx, TS_OFF
    mov cr0, rbx
    
    mov rcx, BASE_PML4N
    add rcx, 7*4096
    
    ; Contexto = BASE_PML4N + 4Kb * 7 + id * 8 * 4Kb  
    ; Cargo los xmm en el contexto del cr3 actual

    mov rax, qword[idMemcheck]
    mov rbx, 8*4096
    mul rbx
    
    add rax, rcx

    movups xmm0, [rax+XMM0]
    movups xmm1, [rax+XMM1]
    movups xmm2, [rax+XMM2]
    movups xmm3, [rax+XMM3]
    movups xmm4, [rax+XMM4]
    movups xmm5, [rax+XMM5]
    movups xmm6, [rax+XMM6]
    movups xmm7, [rax+XMM7]

    pop rcx
    pop rbx
    pop rax

    iretq

__08_exc:
    mov rdi, mensaje_exc_08
    mov rsi, 11110000b
    mov rdx, 1
    mov rcx, 1
    call imprimirMensaje
    jmp $

__09_exc:
    mov rdi, mensaje_exc_09
    mov rsi, 11110000b
    mov rdx, 1
    mov rcx, 1
    call imprimirMensaje
    jmp $

__10_exc:
    mov rdi, mensaje_exc_10
    mov rsi, 11110000b
    mov rdx, 1
    mov rcx, 1
    call imprimirMensaje
    jmp $

__11_exc:
    mov rdi, mensaje_exc_11
    mov rsi, 11110000b
    mov rdx, 1
    mov rcx, 1
    call imprimirMensaje
    jmp $

__12_exc:
    mov rdi, mensaje_exc_12
    mov rsi, 11110000b
    mov rdx, 1
    mov rcx, 1
    call imprimirMensaje
    jmp $

__13_exc:
    mov rdi, mensaje_exc_13
    mov rsi, 11110000b
    mov rdx, 1
    mov rcx, 1
    call imprimirMensaje
    jmp $

__14_exc:
    mov rdi, mensaje_exc_14
    mov rsi, 11110000b
    mov rdx, 1
    mov rcx, 1
    call imprimirMensaje
    jmp $

__16_exc:
    mov rdi, mensaje_exc_16
    mov rsi, 11110000b
    mov rdx, 1
    mov rcx, 1
    call imprimirMensaje
    jmp $

__17_exc:
    mov rdi, mensaje_exc_17
    mov rsi, 11110000b
    mov rdx, 1
    mov rcx, 1
    call imprimirMensaje
    jmp $

__18_exc:
    mov rdi, mensaje_exc_18
    mov rsi, 11110000b
    mov rdx, 1
    mov rcx, 1
    call imprimirMensaje
    jmp $

__19_exc:
    mov rdi, mensaje_exc_19
    mov rsi, 11110000b
    mov rdx, 1
    mov rcx, 1
    call imprimirMensaje
    jmp $

handlerTeclado:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push r8
    push r9
    push r10
    push r11
    push r12
    push rdi
    
    mov rax, cr3
    push rax
    mov rax, BASE_PML4T
    mov cr3, rax
    
    mov eax, gdt_64_data
    mov ds, eax
    mov ss, eax
    
    xor rax, rax
    in al, 0x60                     ; Leo el scancode
    
    cmp al, 35
    jz menu
    cmp al, 42
    jz shift_on
    cmp al, 170
    jz shift_off
    cmp al, 50
    jz guardarKey
    cmp al, 25
    jz guardarKey

    jmp continuar
    
    menu:
        call imprimirMenu
        jmp continuar
    guardarKey:
        mov qword[key], rax
        jmp continuar
    shift_on:
        mov qword[shiftPushed], 0
        jmp continuar
    shift_off:
        mov qword[shiftPushed], 1
        
    continuar:

    mov rdi, rax
    mov rsi, qword[shiftPushed]
    call evaluarCambiosTarea
    
    mov al, 0x20                    ; Aviso el fin de la interrupcion 		
	out 0x20, al

    pop rax
    mov cr3, rax
    pop rdi
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax

    iretq

