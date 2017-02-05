;------------------------------------------------------------------------------
; kernel.asm
;
; Autor: Leandro Beretta <lea.beretta@gmail.com> | Agosto 2012
;------------------------------------------------------------------------------

; EXTERN
; Se importan procedimientos de otros modulos como video.asm y util.asm

EXTERN borrarPantalla, imprimirMensaje, cambiarModoInverso, puts, putn, putc, imprimirMenu
EXTERN obtenerTicksTarea, obtenerPrivilegioTarea, obtenerTiempoEjecucionTarea, idMemcheck
EXTERN configurarPIC, moverMemoria, crearTablasPaginacion, verificar64bits, configurarTimertick
EXTERN main, scheduler, int80h, evaluarCambiosTarea, verificarSSE, configurarSSE, inicializarGateA20

; GLOBAL
; Se define que procedimientos de este archivo seran accesibles desde otros modulos y el linker

GLOBAL _start, switchTo, tarea0, tarea0Size, key

; Se alinea a 8 bytes

align 8

[BITS 16]                       ; Modo Real (16 bits) 

jmp _start

; Se incluyen los descriptores de la idt y la gdt, para luego ser reubicados en memoria

%include "src/inc/defines.asm"
%include "src/inc/idt.asm"
%include "src/inc/gdt.asm"
%include "src/inc/tss.asm"

_start:

    cli                         ; Deshabilita interrupciones ya que al cambiar de modo, las interrupciones se manejan distinto

    call configurarPIC          ; Configuro el PIC1 y el PIC2
    call configurarTimertick
    call inicializarGateA20
    
    ; Inicializo en 0 el es
    xor ax, ax
    mov es, ax

    ; Muevo IDT a la posicion de memoria 0
    mov esi, idt
    mov edi, 0
    mov ecx, idt_size
    call moverMemoria
    
    ; Muevo GDT luego de la IDT
    mov esi, gdt
    mov edi, idt_size+1
    mov ecx, gdt_size
    call moverMemoria

    lgdt [gdtr]                 ; Cargo el descriptor de la GDT
    lidt [idtr]                 ; Cargo el descriptor de la IDT

	mov eax, cr0                ; Leo el registro de control 0
	or al, PE_ON                ; Bit PE = 1
	mov cr0, eax                ; Activo modo protegido
    
    xor eax, eax                ; Inicializo eax en 0
	
    jmp gdt_code:modo_protegido ; jmp far -> Vacio cola de ejecucion

[BITS 32]                       ; Modo Protegido (32 bits)

modo_protegido:
    
    mov eax, gdt_data           ; Cargo en eax el selector de segmento de datos
    mov ds, eax                 ; Cargo en ds, es y ss el selector de segmento de datos
    mov es, eax
    mov ss, eax

    call verificar64bits        ; Verifico mediante las CPUID que el procesador sea compatible para entrar al modo de 64 bits
    call verificarSSE           ; Verifico si el procesador soporta las instrucciones SSE
    call crearTablasPaginacion  ; Creo las tablas de paginacion necesarias para el modo IA-32e
    
    ; Inicializo el CR3 con la posición de la PML4T
    mov eax, BASE_PML4T
    and eax, 0xFFFFF000
    
    ; Resguardo los primeros 12 bits del cr3
    mov ebx, cr3
    and ebx, 0x00000FFF
    
    ; Armo el cr3 respetando los primeros 12 bits y tambien la direccion fisica (lineal
    ; ya que todavia no hay paginacion y la segmentacion es flat) de la PML4T
    or eax, ebx
    
    mov cr3, eax

    mov eax, cr4
    or eax, PAE_ON
    mov cr4, eax                ; Activo PAE

    mov ecx, 0xC0000080         ; Cargo la direccion del ia32_efer
    rdmsr                       ; Cargo el registro ia32_efer a edx:eax
    or eax, LME_ON              ; Bit LME = 1
    wrmsr                       ; Escribo el registro ia32_efer con edx:eax

    mov eax, cr0                ; Leo registro de control 0
    or eax, PG_ON               ; Bit PG = 1
    mov cr0, eax                ; Activo la paginación

	mov al, 0xFC      		    ; PIC 1 -> Interrupciones de teclado activadas
	out 0x21, al
    mov al, 0xFF                ; PIC 2 -> Todas las interrupciones del PIC2 desactivadas
    out 0xA1, al

    jmp gdt_64_code:modo_64     ; jmp far -> Vacio la cola de ejecucion y salto a un segmento de codigo de 64 bits

[BITS 64]

modo_64:
    mov eax, gdt_64_data        ; Cargo en eax el selector de segmento de datos de 64
    mov ds, eax                 ; Cargo en ds, es, ss el selector de segmento de datos de 64
    mov es, eax
    mov ss, eax
    
    ; Cargo la TSS en el TR
    mov rax, gdt_64_tss 
    ltr ax
    
    ; Habilito instrucciones SSE
    call configurarSSE

    ; Cargo el rsp con la pila de nivel 0 de la tarea 0 (Idle)
    mov rsp, BASE_PML4N + (1*8*4096) + 6*4096 + 4088

    ; Background -> Blanco | Foreground -> Negro
    mov al, 00000111b           
    call borrarPantalla
    call cambiarModoInverso

    ; Llamo a una funcion en C
    call main
    
    sti   ; Habilito las interrupciones                    
    
    jmp tarea0

align 4096
tarea0:

    mov r9, 0
    add r9, BASE_Y_INFO_TAREA

    mov rdi, pid
    mov rsi, COLOR_TAREA_IDLE
    mov rdx, BASE_X_INFO_TAREA
    mov rcx, r9
    call puts
    
    mov rdi, 0
    mov rsi, COLOR_TAREA_IDLE
    mov rdx, BASE_X_INFO_TAREA + 6
    mov rcx, r9
    mov r8, 2
    call putn

    mov rdi, pipe
    mov rsi, COLOR_TAREA_IDLE
    mov rdx, BASE_X_INFO_TAREA + 8
    mov rcx, r9
    call putc

    mov rdi, priv
    mov rsi, COLOR_TAREA_IDLE
    mov rdx, BASE_X_INFO_TAREA + 10
    mov rcx, r9
    call puts

    mov rdi, 0
    call obtenerPrivilegioTarea
    
    cmp rax, 3
    jz kernel_priv
    mov rdi, app
    jmp priv_end
    kernel_priv:
        mov rdi, kernel
    priv_end:
        
    mov rsi, COLOR_TAREA_IDLE
    mov rdx, BASE_X_INFO_TAREA + 13
    mov rcx, r9
    call putc

    mov rdi, pipe
    mov rsi, COLOR_TAREA_IDLE
    mov rdx, BASE_X_INFO_TAREA + 15
    mov rcx, r9
    call putc

    mov rdi, te
    mov rsi, COLOR_TAREA_IDLE
    mov rdx, BASE_X_INFO_TAREA + 17
    mov rcx, r9
    call puts

    mov rdi, 0
    call obtenerTiempoEjecucionTarea
    
    mov rdi, rax
    mov rsi, COLOR_TAREA_IDLE
    mov rdx, BASE_X_INFO_TAREA + 25
    mov rcx, r9
    mov r8, 5
    call putn

    mov rdi, pipe
    mov rsi, COLOR_TAREA_IDLE
    mov rdx, BASE_X_INFO_TAREA + 27
    mov rcx, r9
    call putc

    mov rdi, ticks
    mov rsi, COLOR_TAREA_IDLE
    mov rdx, BASE_X_INFO_TAREA + 29
    mov rcx, r9
    call puts

    mov rdi, 0
    call obtenerTicksTarea

    mov rdi, rax
    mov rsi, COLOR_TAREA_IDLE
    mov rdx, BASE_X_INFO_TAREA + 33
    mov rcx, r9
    mov r8, 2
    call putn

    jmp tarea0
tarea0Size equ $ - tarea0

system:

; Incluyo los handlers para las interrupciones externas y las excepciones
%include "src/handlers.asm"

; Incluyo el manejo de contextos
%include "src/switchTo.asm"


