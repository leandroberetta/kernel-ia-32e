;------------------------------------------------------------------------------
; util.asm
;
; Autor: Leandro Beretta <lea.beretta@gmail.com> | Agosto 2012
;
; Procedimientos utiles
;------------------------------------------------------------------------------

EXTERN gdt_64_code, gdt_64_data, gdt_64_code_a3, gdt_64_data_a3

GLOBAL configurarPIC, configurarTimertick, enviarFinInterrupcion, verificar64bits, verificarSSE
GLOBAL crearTablasPaginacion, crearPaginacionTarea, crearContextoTarea, agregarParametrosTarea
GLOBAL breakpoint, moverMemoria, binToAscii, configurarSSE, inicializarGateA20

%include "src/inc/defines.asm"

auxRbp          dq      0
dirRetorno      dq      0
idTarea         dq      0
tarea           dq      0
auxPML4         dq      0
privTarea       dq      0
descCodeTarea   dq      0
descDataTarea   dq      0
sizeTarea       dq      0

vecDigitos: times 8 db 0

[BITS 16]

; Procedimiento: inicializarGateA20
;
; Verifica si el procesador tiene habilitado el pin A20, si esta deshabilitado, lo habilita

inicializarGateA20:
    mov ax, 0xFFFF
    mov es, ax

    cmp word[es:0x7E0E], 0xAA55
    je gateA20_dis
    rol word[0x7DFE], 1
    cmp word[es:0x7E0E], 0x55AA
    je gateA20_dis
    mov word[0x7DFE], 0xAA55
    jmp end_gateA20

    gateA20_dis:
        call gateA20_en

    end_gateA20:
        ret
 
 gateA20_en:
    call wait_input
    mov al,0xAD
    out 0x64, al
    call wait_input

    mov al, 0xD0
    out 0x64, al
    call wait_output

    in al, 0x60
    push eax		
    call wait_input

    mov al, 0xD1
    out 0x64, al
    call wait_input

    pop eax
    or al, 2	
    out 0x60, al		
    call wait_input
    mov al, 0xAE		
    out 0x64 ,al

    call    wait_input
    
    ret

wait_input:
    in al, 0x64
    test al, 2
    jnz wait_input
    ret

wait_output:
    in al, 0x64
    test al, 1
    jz wait_output
    ret

[BITS 64]

; Procedimiento: configurarSSE
;
; Habilita el uso de instrucciones SSE

configurarSSE:
    push rax
    
    mov rax, cr0

;    and eax, CM_OFF
    or eax, MP_ON
    or eax, TS_ON

    mov cr0, rax

    mov rax, cr4

    or eax, OSFXSR_ON
    or eax, OSXMMEXCPT_ON

    mov cr4, rax

    pop rax

    ret

; Procedimiento: verificarSSE
;
; Verifica si el procesador tiene las instrucciones SSE

verificarSSE:
    
    push rax
    push rdx
    
    xor rax, rax
    xor rdx, rdx

    mov eax, 1
    cpuid

    test edx, SSE_EDX
    jz not_sse
    test eax, SSE_EAX
    jz not_sse

    pop rdx
    pop rax

    ret

    not_sse:
        jmp $

; Procedimiento: enviarFinInterrupcion
;
; Envia el fin de interrupcion

enviarFinInterrupcion:
    mov al, 0x20                     ; Aviso el fin de la interrupcion 		
	out 0x20, al
    ret

; Procedimiento: breakpoint
;
; Breakpoint

breakpoint:
    xchg bx,bx
    ret

; Procedimiento: agregarParametrosTarea
;
; Argumentos: rdi -> Id 
;            
; Agrega el id de la tarea en la pila de nivel 3 de la respectiva tarea

agregarParametrosTarea:

    ; RSP = BASE_PML4N + id * 8Kb + 5Kb + 4088
    mov rax, 8*4096
    mov rbx, rdi
    mul rbx
    add rax, BASE_PML4N + 5*4096 + 4088

    mov qword[rax], rdi

    ret

; Procedimiento: crearContextoTarea
;
; Recibe: rdi -> Id Tarea
;         rsi -> Privilegio de la tarea
;   
; Crea el contexto de cada tarea

crearContextoTarea:
    
    push rax
    push rbx

    ; Resguardo los parametros 

    mov qword[idTarea], rdi

    cmp rsi, 3
    jz kernel_priv
        mov qword[descCodeTarea], gdt_64_code_a3 + 3
        mov qword[descDataTarea], gdt_64_data_a3 + 3
        jmp next_step
    kernel_priv:
        mov qword[descCodeTarea], gdt_64_code
        mov qword[descDataTarea], gdt_64_data

    next_step:
    
    ; Calculo base del contexto
    ; Contexto = BASE_PML4N + (8Kb * id) + 4Kb * 7   
       
    mov rax, 8*4096
    mov rbx, qword[idTarea]
    mul rbx
    mov rbx, BASE_PML4N + 7*4096
    add rax, rbx
    ; Guardo en rdi la direccion base del contexto de la tarea
    mov rdi, rax
    
    ; Cargo los valores iniciales del contexto de la tarea
    
    mov rax, 8*4096
    mov rbx, qword[idTarea]
    mul rbx
    add rax, BASE_PML4N + 4088
    ; RSPO = BASE_PML4N + id * 7Kb + 4095
    mov qword[rdi+RSP0], rax

    mov rax, 8*4096
    mov rbx, qword[idTarea]
    mul rbx
    add rax, BASE_PML4N
    ; CR3 = BASE_PML4N + id * 8Kb
    mov qword[rdi+CR3], rax
    
    mov rax, 8*4096
    mov rbx, qword[idTarea]
    mul rbx
    add rax, BASE_PML4N + 4*4096
    ; RIP = BASE_PML4N + id * 8Kb + 4Kb
    mov qword[rdi+RIP], rax

    mov qword[rdi+RFLAGS], 0x202

    mov rax, 8*4096
    mov rbx, qword[idTarea]
    mul rbx
    add rax, BASE_PML4N + 5*4096 + 4088
    ; RSP = BASE_PML4N + id * 8Kb + 5Kb + 4095
    mov qword[rdi+RSP], rax
    
    mov rax, qword[descDataTarea]
    mov qword[rdi+ES], rax
    mov qword[rdi+SS], rax
    mov qword[rdi+DS], rax
    mov qword[rdi+FS], rax
    mov qword[rdi+GS], rax
    mov rax, qword[descCodeTarea]
    mov qword[rdi+CS], rax
    
    pop rbx
    pop rax

    ret

; Procedimiento: crearPaginacionTarea
;
; Recibe: rdi -> Id Tarea
;         rsi -> Tarea
;         rdx -> Privilegio de la tarea
;         rcx  -> Tamaño de la tarea  
;   
; Crear las tablas de paginacion para cada tarea

crearPaginacionTarea:
    
    push rax
    push rbx
    push rcx
    
    ; Resguardo los parametros 
    mov qword[idTarea], rdi
    mov qword[tarea], rsi
    mov qword[privTarea], rdx
    mov qword[sizeTarea], rcx

    ; Calculo de la PML4n
    ; PML4n = BASE_PML4N + (8Kb * id)

    mov rax, 8*4096
    mov rbx, qword[idTarea]
    ; rax = rax * rbx -> rax = 8*4096*id
    mul rbx
    mov rbx, BASE_PML4N
    ; rax = rax + rbx
    add rax, rbx
    
    ; Resguardo la direccion base del PML4 de la tarea
    mov qword[auxPML4], rax

    ; Base de la PML4n
    mov rdi, rax
    
    ; PDPTEn
    ; rax = rax + 4Kb + Privilegios de usuario | PDPTEn = rax + 4Kb
    add rax, 4096
    add rax, qword[privTarea]
    mov qword[rdi], rax 
    ; Completo los 511 siguientes en 0    
    mov rax, qword[auxPML4]
    add rax, 8
    mov rdi, rax
    mov rcx, 511
    mov rax, 0

    loop_pml4t_tarea:
        stosd
        add rdi, 4
        loop loop_pml4t_tarea

    ; Base de la PDPTEn
    mov rax, qword[auxPML4]
    add rax, 4096
    mov rdi, rax

    ; PDTEn
    ; rax = rax + 4Kb + Privilegios de usuario | PDTn = rax + 4Kb
    add rax, 4096
    add rax, qword[privTarea]
    mov qword[rdi], rax
    ; Completo los 511 siguientes en 0
    mov rax, qword[auxPML4]
    add rax, 8
    mov rdi, rax
    mov rcx, 511
    mov rax, 0

    loop_pdpt_tarea:
        stosd
        add rdi, 4
        loop loop_pdpt_tarea

    ; Base de la PDTn
    ; Base PDTn = BASE_PML4N + 2*4096
    mov rax, qword[auxPML4]
    add rax, 2*4096
    mov rdi, rax

    ; PDEn 2Mb
    mov rax, 0 + 131
    mov qword[rdi], rax
    ; PT0 que mapea las demás paginas de 4 Kb
    mov rax, qword[auxPML4]
    add rax, 3*4096
    add rax, qword[privTarea]
    mov qword[rdi+8], rax
    ; Completo las siguientes 510 entradas de la PDT con 0
    mov rax, qword[auxPML4]
    add rax, 2*4096
    add rax, 16
    mov rdi, rax
    mov rcx, 510
    mov rax, 0
    
    loop_pdt_tarea:
        stosd
        add edi, 4
        loop loop_pdt_tarea
    
    ; Base de la PT0n
    ; Base PT0n = BASE_PML4N + 4*4096
    mov rax, qword[auxPML4]
    add rax, 3*4096
    mov rdi, rax
    
    ; Completo 512 paginas de 4Kb en anillo 0
    mov rax, 0x200000
    add rax, 3
    mov rcx, 512

    loop_pt0_tarea:
        stosd
        add rax, 4096
        add rdi, 4
        loop loop_pt0_tarea


    ; Pagina 4Kb para codigo en anillo 3
    mov rax, qword[idTarea]
    mov rbx, 8*8
    mul rbx
    ; rax = id*8*7
    add rax, 8*4
    ; rax = id*8*7 + 8*4
    add rax, 4096*3
    ; rax = id*8*7 + 8*4 + 4*4096
    add rax, qword[auxPML4]
    ; rax = id*8*7 + 8*4 + 4*4096 + BASE_TAREA
    mov rdi, rax
    
    ; Si hago esto debo luego mover el codigo a la pagina
    mov rax, qword[idTarea]
    mov rbx, 4096*8
    mul rbx
    ;rax = id*7*4096
    add rax, 4*4096 + BASE_PML4N
    
    ; Apunto a la tarea sin moverla
;    mov rax, qword[tarea]
    add rax, qword[privTarea]
    mov qword[rdi], rax
    
    ; Pagina 4Kb para pila en anillo 3
    mov rax, qword[idTarea]
    mov rbx, 8*8
    mul rbx
    ; rax = id*8*7
    add rax, 8*5
    ; rax = id*8*7 + 8*5
    add rax, 4096*3
    ; rax = id*8*7 + 8*5 + 4*4096
    add rax, qword[auxPML4]
    ; rax = id*8*7 + 8*5 + 4*4096 + BASE_TAREA
    mov rdi, rax
    
    mov rax, qword[idTarea]
    mov rbx, 4096*8
    mul rbx
    ; rax = id*7*4096
    add rax, 5*4096 + BASE_PML4N
    ; Esto lo hago si la apunto por paginacion
    ;mov rax, qword[tarea]
    add rax, qword[privTarea]
    mov qword[rdi], rax

    ; Pagina 4Kb para pila en anillo 0
    mov rax, qword[idTarea]
    mov rbx, 8*8
    mul rbx
    ; rax = id*8*7
    add rax, 8*6
    ; rax = id*8*7 + 8*6
    add rax, 4096*3
    ; rax = id*8*7 + 8*6 + 4*4096
    add rax, qword[auxPML4]
    ; rax = id*8*7 + 8*6 + 4*4096 + BASE_TAREA
    mov rdi, rax
    
    mov rax, qword[idTarea]
    mov rbx, 4096*8
    mul rbx
    ; rax = id*7*4096
    add rax, 6*4096 + BASE_PML4N
    add rax, 3
    mov qword[rdi], rax

    ; Pagina 4Kb para el contexto de la tarea
    mov rax, qword[idTarea]
    mov rbx, 8*8
    mul rbx
    ; rax = id*8*7
    add rax, 8*7
    ; rax = id*8*7 + 8*6
    add rax, 4096*3
    ; rax = id*8*7 + 8*6 + 4*4096
    add rax, qword[auxPML4]
    ; rax = id*8*7 + 8*6 + 4*4096 + BASE_TAREA
    mov rdi, rax
    
    mov rax, qword[idTarea]
    mov rbx, 4096*8
    mul rbx
    ; rax = id*7*4096
    add rax, 7*4096 + BASE_PML4N
    add rax, 3
    mov qword[rdi], rax

    mov rax, qword[auxPML4]
    add rax, 4*4096
    
    mov rsi, qword[tarea]
    mov rdi, rax
    mov rcx, qword[sizeTarea]
    call moverMemoria

    pop rcx
    pop rbx
    pop rax

    ret


; Procedimiento: binToAscii
; 
; Recibe: rax -> Digito binario
; 
; Devuelve: rax -> Buffer donde estan los digitos

binToAscii:

    push rbx
    push rcx
    push rdx
    push rsi

    mov rcx, rax
    
    ; rax = rax / 100000
    ; rax = n si en esa posicion no es 0
    mov rdx, 0
    mov rbx, 100000
    div rbx
    ; Resguardo el valor
    push rax

    ; rax = rax - n * 100000
    mul rbx
    sub rcx, rax
    mov rax, rcx

    mov rdx, 0
    mov rbx, 10000
    div rbx
    push rax
    
    mul rbx
    sub rcx, rax
    mov rax, rcx

    mov rdx, 0
    mov rbx, 1000
    div rbx
    push rax

    mul rbx
    sub rcx, rax
    mov rax, rcx
    
    mov rdx, 0
    mov rbx, 100
    div rbx
    push rax

    mul rbx
    sub rcx, rax
    mov rax, rcx

    mov rdx, 0
    mov rbx, 10
    div rbx
    push rax

    mul rbx
    sub rcx, rax
    mov rax, rcx
    
    push rax
    
    mov rsi, vecDigitos

    ; Unidades
    pop rcx
    add cl, 0x30
;    mov al, cl
    mov byte[rsi], cl
    ; Decenas
    pop rcx
    add cl, 0x30
;    mov ah, cl
    mov byte[rsi+1], cl
    ; Centenas
    pop rcx
    add cl, 0x30
;    mov bl, cl
    mov byte[rsi+2], cl
    ; Miles
    pop rcx
    add cl, 0x30
;    mov bh, cl
    mov byte[rsi+3], cl
    ; 10 Miles
    pop rcx
    add cl, 0x30
;    mov dl, cl
    mov byte[rsi+4], cl
    ; 100 Miles
    pop rcx
    add cl, 0x30
;    mov dh, cl
    mov byte[rsi+5], cl

    mov rax, vecDigitos

    pop rsi
    pop rdx
    pop rcx
    pop rbx

    ret

[BITS 32]

; Procedimiento: configurarTimertick
;
; Configura el timertick a 1 ms

configurarTimertick:
    mov eax, 0x3a68
    out	0x40, al
    mov ah,al
	out 0x40, al
    
    ret

; Procedimiento: configurarPIC
;
; Configura el PIC1 y PIC2 cambiando el offset del vector de interrupciones

configurarPIC:

; PIC1

; ICW1 -> Activación por flancos | Modo en cascada | ICW4 necesario
    mov al, 0x11
    out 0x20, al
; ICW2 -> Offset del vector de interrupciones
    mov al, 0x20
    out 0x21, al
; ICW3 -> PIC1 Master | El PIC2 Slave conectado a la IRQ2
    mov al, 0x04
    out 0x21, al
; ICW4 -> Fully Nested Mode desactivado | Buffered Mode desactivado | Auto EOI desactivado | Modo 8086
    mov al, 0x01
    out 0x21, al
; PIC1 -> Interrupciones desactivadas
    mov al, 0xFF
    out 0x21, al

; PIC2

; ICW1 -> Activacion por flancos | Modo en cascada | ICW4 necesari necesario
    mov al, 0x11
    out 0xA0, al
; ICW2 -> Offset del vector de interrupciones
    mov al, 0x28
    out 0xA0, al
; ICW3 -> PIC2 Slave | PIC2 conectado a IRQ2
    mov al, 0x02
    out 0xA1, al
; ICW4 -> Fully Nested Mode desactivado | Buffered Mode desactivado | Auto EOI desactivado | Modo 8086
    mov al, 0x01
    out 0xA1, al
; PIC2 -> Interrupciones desactivadas
    mov al, 0xFF
    out 0xA1, al

    ret

; Procedimiento: moverMemoria
; Argumentos: rsi -> Posicion de memoria fuente
;             rdi -> Posicion de memoria destino
;             rcx -> Cantidad de bytes a mover
;
; Mueve n bytes a partir de una posicion de memoria a otra posicion de memoria indicada

moverMemoria:
    cld
    rep movsb 
    ret

; Procedimiento: crearTablasPaginacion
;
; Crear las tablas de paginacion

crearTablasPaginacion:
    xor eax,eax
    xor ebx,ebx
    xor ecx,ecx
    xor edx,edx

    mov edi, BASE_PML4T

    ; PML4E apuntando a una PDPT
    mov eax, BASE_PDPT + 3
    mov dword[edi], eax
    ; Completo los restantes 511 con 0
    mov edi, BASE_PML4T + 8
    mov ecx, 511
    mov eax, 0

    loop_pml4t:
        stosd
        add edi, 4
        loop loop_pml4t

    mov edi, BASE_PDPT

    ; PDPTE apuntando a una PDT
    mov eax, BASE_PDT + 3
    mov dword[edi], eax
    mov eax, BASE_PDT_SSE + 3
    mov dword[edi+8], eax
    ; Completo los restantes 511 con 0
    ; Completo los restantes 511 con 0
    mov edi, BASE_PDPT + 16
    mov ecx, 510
    mov eax, 0 

    loop_pdpt:
        stosd
        add edi, 4
        loop loop_pdpt

    mov edi, BASE_PDT
    
    ; PDE que mapea la 1er pagina de 2 Mb
    mov eax, 0 + 131
    mov dword[edi], eax
    ; PT0 que mapea las demás paginas de 4 Kb
    mov eax, BASE_PT0 + 3
    mov dword[edi+8], eax
    ; Completo las siguientes 510 entradas de la PDT con paginas de 2 Mb
    mov edi, BASE_PDT + 16
    mov ecx, 510
    mov eax, 0x400000 + 131
;    mov eax, 0
    
    loop_pdt:
        stosd
        add eax, 0x200000
        add edi, 4
        loop loop_pdt

    mov edi, BASE_PT0

    ; Posicion de memoria 0x200000 -> 0xB8000
    ; Accedida por modo supervisor
    ;mov eax, 0xB8000 + 3    
    ;mov dword[edi], eax

    ;mov edi, BASE_PT0 + 8
    ;mov ecx, 511
    ;mov eax, 0x201000 + 7
    
    mov edi, BASE_PT0
    mov ecx, 512
    mov eax, 0x200000 + 3

    loop_pt0:
        stosd
        add eax, 4096
        add edi, 4
        loop loop_pt0
    
;    mov edi, BASE_PDT_SSE

;    xchg bx,bx
    ; Completo 512 entradas de la PDT_SSE con paginas de 2 Mb
;    mov edi, BASE_PDT_SSE
;    mov ecx, 512
;    mov eax, 0x400000 + 131
    
;    loop_pdt_sse:
;        stosd
;        add eax, 0x200000
;        add edi, 4
;        loop loop_pdt_sse

    ret

; Procedimiento: verificar64bits
;
; Verifica que el procesador acepte 64 bits

verificar64bits:

    mov eax, 0x80000000
    cpuid

    cmp eax, 0x80000001
    jb salir

    mov eax, 0x80000001
    cpuid

    test edx, 1<<29
    jz salir
    
    ret

    salir:
        jmp $


