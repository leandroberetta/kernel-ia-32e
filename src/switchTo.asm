;------------------------------------------------------------------------------
; switchTo.asm
;
; Autor: Leandro Beretta <lea.beretta@gmail.com> | Agosto 2012
;
; switchTo
;------------------------------------------------------------------------------

EXTERN imprimirDeltaConmutacion

; Procedimiento: switchTo
;
; Parametros: rdi -> Tarea siguiente
;             rsi -> Tarea actual
;

auxRip dq 0
tiempo dq 0

switchTo:
    ; Resguardo el rip de retorno
    pop qword[auxRip]

    push rax
    push rdx
    cpuid
    rdtsc
    mov qword[tiempo], rax
    pop rdx
    pop rax

    ; Guardo el contexto de la tarea que va a dejar de ejecutarse
    
    pop qword[rsi+RFLAGS]
    pop qword[rsi+RSI]
    pop qword[rsi+RDI]
    pop qword[rsi+RDX]
    pop qword[rsi+RCX]
    pop qword[rsi+RBX]
    pop qword[rsi+RAX]

    pop qword[rsi+RIP]
    pop qword[rsi+CS]
    pop qword[rsi+RFLAGS]
    pop qword[rsi+RSP]
    pop qword[rsi+SS]
    
    mov qword[rsi+RSP0], rsp
    mov word[rsi+SS0], ss

    mov qword[rsi+R8], r8
    mov qword[rsi+R9], r9
    mov qword[rsi+R10], r10
    mov qword[rsi+R11], r11
    mov qword[rsi+R12], r12
    mov qword[rsi+R13], r13
    mov qword[rsi+R14], r14
    mov qword[rsi+R15], r15

    mov qword[rsi+RBP], rbp
    
    push rax
    ; Guardo el cr3
    mov rax, cr3
    mov qword[rsi+CR3], rax
    pop rax

    mov word[rsi+ES], es
    mov word[rsi+DS], ds
    mov word[rsi+FS], fs
    mov word[rsi+GS], gs

    push rax
    xor rax, rax
    mov rax, cr0
    test eax, TS_ON
    jz guardarSIMD
    jmp seguir

    guardarSIMD:
        movups [rsi+XMM0], xmm0
        movups [rsi+XMM1], xmm1
        movups [rsi+XMM2], xmm2
        movups [rsi+XMM3], xmm3
        movups [rsi+XMM4], xmm4
        movups [rsi+XMM5], xmm5
        movups [rsi+XMM6], xmm6
        movups [rsi+XMM7], xmm7
        
        mov rax, cr0
        or rax, TS_ON
        mov cr0, rax    
    
    seguir:

        pop rax

    ; Cargo el contexto de la tarea a ejecutar
    
    mov ss, word[rdi+SS0]

    mov rbp, qword[rdi+RBP]

    mov rax, qword[rdi+RAX]
    mov rbx, qword[rdi+RBX]
    mov rcx, qword[rdi+RCX]

    mov r8, qword[rdi+R8]
    mov r9, qword[rdi+R9]
    mov r10, qword[rdi+R10]
    mov r11, qword[rdi+R11]
    mov r12, qword[rdi+R12]
    mov r13, qword[rdi+R13]
    mov r14, qword[rdi+R14]
    mov r15, qword[rdi+R15]

    mov rdx, qword[rdi+RDX]
    mov rsi, qword[rdi+RSI]
    
    push rax
    ; Cargo el cr3
    mov rax, qword[rdi+CR3]
    mov cr3, rax
    ; Cargo la pila de nivel 0 en la tss
    mov rax, qword[rdi+RSP0]
    mov qword[TSS+tss.RSP_0], rax
    pop rax
    
    mov es, word[rdi+ES]
    mov fs, word[rdi+FS]
    mov gs, word[rdi+GS]
    mov ds, word[rdi+DS]

    push qword[rdi+SS]    
    push qword[rdi+RSP]
    push qword[rdi+RFLAGS]
    push qword[rdi+CS]
    push qword[rdi+RIP]

    mov rdi, qword[rdi+RDI]
    
    push rax
    push rbx
    push rdx
    push rdi
    push rsi
    push rcx
    push r8

    cpuid
    rdtsc
    sub rax, qword[tiempo]
    
    mov rdi, rax
    mov rsi, COLOR_KERNEL_2
    mov rdx, 33
    mov rcx, 0
    mov r8, 3
    call imprimirDeltaConmutacion
    
    pop r8
    pop rcx
    pop rsi
    pop rdi
    pop rdx
    pop rbx
    pop rax    

    push qword[auxRip]
    
    ret

