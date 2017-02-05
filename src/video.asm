;------------------------------------------------------------------------------
; video.asm
;
; Autor: Leandro Beretta <lea.beretta@gmail.com> | Mayo 2012
;
; Procedimientos utiles para el manejo de la pantalla en modo texto
;------------------------------------------------------------------------------

[BITS 64]

EXTERN getHora, getMin, getSeg, binToAscii, getAnio, getMes, getDia

; Procedimientos para llamar desde C

GLOBAL generic, puts, strlen, putc, putn

; Procedimientos para llamar desde assembler

GLOBAL borrarPantalla, imprimirMensaje, imprimirDecimal, calcularPosicion, imprimirFecha
GLOBAL imprimirTexto, cambiarModoInverso, imprimirTiempo, aplicarAtributos
GLOBAL imprimirDeltaConmutacion, borrarPantallaParcial

%include "src/inc/defines.asm"

memVideo   dq   0
auxPosX    dq   0
auxPosY    dq   0

vecMensaje: times 256 db 0

; Mensajes

; Mensajes para imprimirMensaje
mensaje_deco:               db      "+-----------------------------------------------------------------------+"
mensaje_deco_size           equ     $ - mensaje_deco
mensaje_deco_center:        db      "|                                                                       |"
mensaje_deco_center_size    equ     $ - mensaje_deco_center

; Procedimiento: generic
; 
; Parametros:
;
; Tipo int: rdi, rsi, rdx, rcx, r8, r9
; Tipo float: xmm0, xmm1, xmm2, xmm3, xmm4, xmm5, xmm6, xmm7
;
; Plantilla de funcion que puede ser llamada desde C con la interfaz ABI

generic:
    
    ret

; Procedimiento: strlen
; 
; Parametros:
;
; int -> rdi - Puntero al comienzo del string
;
; Devuelve en rcx y rax la longitud del string
;

strlen:
    push rax
    
    xor rax,rax
    xor rcx,rcx
    
    loop_strlen:
        cmp byte[rdi], 0
        jz strlen_end
        inc rcx
        inc rdi
        jmp loop_strlen
        
    strlen_end:

    pop rax

    ret

; Procedimiento: putc
; 
; Parametros:
;
; int -> rdi - Caracter
;        rsi - Atributos del caracter
;        rdx - Posicion X
;        rcx - Posicion Y
;
; Imprime un caracter en la pantalla en la posicion (x,y) y con los atributos asignados
;

putc:
    push rax
    push rbx
    push r8

; Inicializo en 0 los registros necesarios
    xor rax,rax
    xor rbx,rbx

; Resguardo los parametros en variables
    mov r8, rdi
    
; Ubicacion del string en la pantalla en rdi
    mov rax, rdx
    mov rbx, rcx
    call calcularPosicion 
    
; Aplico los atributos a partir de la posicion calculada
    mov rax, rsi
    mov rcx, 1
    call aplicarAtributos
    
; Imprimo el string
    mov rsi, r8
    mov rcx, 1
    call imprimirTexto

    pop r8
    pop rbx
    pop rax

    ret

; Procedimiento: putn
;
; Argumentos: rdi -> Variable decimal
;             rsi -> Atributos
;             rdx -> Posicion X
;             rcx -> Posicion Y
;             r8 -> Cantidad de digitos a mostrar
;
; Imprime en la pantalla un numero decimal de tipo int

putn:
    push rax
    push rbx
    push r9

    mov r9, rdi
    
    mov rax, rdx
    mov rbx, rcx
    call calcularPosicion
    ; En rdi tengo la posicion donde voy a escribir
    push rdi
    mov rax, r8
    mov rbx, 2
    mul rbx
    sub rax, 2
    sub rdi, rax
    mov rax, rsi
    mov rcx, r8
    call aplicarAtributos
    ; Aplico los atributos a partir de rdi, r8 posiciones
    pop rdi
    mov rcx, r8
    mov rax, r9
    mov rbx, 10
    loop_putn:
        mov rdx, 0
        div rbx
        add dl, 0x30
        mov byte[rdi], dl
        sub rdi, 2
        loop loop_putn

    pop r9
    pop rbx
    pop rax

    ret

; Procedimiento: puts
; 
; Parametros:
;
; int -> rdi - Puntero al comienzo del string
;        rsi - Atributos del string
;        rdx - Posicion X
;        rcx - Posicion Y
;
; Imprime un string en la pantalla en la posicion (x,y) y con los atributos asignados
;

puts:
    push rax
    push rbx
    push r8

; Inicializo en 0 los registros necesarios
    xor rax,rax
    xor rbx,rbx

; Resguardo los parametros en variables
    mov r8, rdi
    
; Ubicacion del string en la pantalla en rdi
    mov rax, rdx
    mov rbx, rcx
    call calcularPosicion 
    
    push rdi
; Calculo la longitud del string
    mov rdi, r8
    call strlen
    pop rdi
    push rcx

; Aplico los atributos a partir de la posicion calculada
    mov rax, rsi
    call aplicarAtributos
    
    pop rcx
; Imprimo el string
    mov rsi, r8
    call imprimirTexto

    pop r8
    pop rbx
    pop rax

    ret

; Procedimiento: imprimirDeltaConmutacion
;
; Argumentos: rdi -> Tiempo
;             rsi -> Atributos
;             rdx -> Posicion X
;             rcx -> Posicion Y
;             r8 -> Cantidad de digitos

imprimirDeltaConmutacion:
    push rax
    push rbx
    push r9
    push r11
    push r12
    push r13
    
    mov r9, rsi
    mov r11, rdi
    mov r12, rdx
    mov r13, rcx

    mov rdi, deltaTSC
    call puts

    mov rdi, r11
    mov rsi, r9
    mov rdx, r12
    add rdx, 21
    mov rcx, r13
    call putn
    
    pop r13
    pop r12
    pop r11
    pop r9
    pop rbx
    pop rax

    ret

; Procedimiento: imprimirFecha
;
; Argumentos: rsi -> Atributos
;             rdx -> Posicion X
;             rcx -> Posicion Y

imprimirFecha:
    push rdi
    push rax
    push rbx

    xor rax, rax
    xor rdi, rdi
    xor rbx, rbx

    call getDia
    call binToAscii
    ; En rax tengo la direccion de un vector de digitos

    mov rbx, qword[rax+1]
    mov qword[vecMensaje], rbx
    mov rbx, qword[rax+0]
    mov qword[vecMensaje+1], rbx
    
    mov rbx, '/'
    mov qword[vecMensaje+2], rbx

    call getMes
    call binToAscii
    
    mov rbx, qword[rax+1]
    mov qword[vecMensaje+3], rbx
    mov rbx, qword[rax+0]
    mov qword[vecMensaje+4], rbx

    mov rbx, '/'
    mov qword[vecMensaje+5], rbx
    
    call getAnio
    call binToAscii

    mov rbx, qword[rax+1]
    mov qword[vecMensaje+6], rbx
    mov rbx, qword[rax+0]
    mov qword[vecMensaje+7], rbx
    
    mov rax, rdx
    mov rbx, rcx
    call calcularPosicion
    
    mov rax, rsi
    mov rcx, 8
    call aplicarAtributos
    

    mov rsi, vecMensaje
    mov rcx, 8
    call imprimirTexto

    pop rbx
    pop rax
    pop rdi

    ret

; Procedimiento: imprimirTiempo
;
; Argumentos: rsi -> Atributos
;             rdx -> Posicion X
;             rcx -> Posicion Y

imprimirTiempo:
    push rdi
    push rax
    push rbx

    xor rax, rax
    xor rdi, rdi
    xor rbx, rbx

    call getHora
    call binToAscii
    ; En rax tengo la direccion de un vector de digitos

    mov rbx, qword[rax+1]
    mov qword[vecMensaje], rbx
    mov rbx, qword[rax+0]
    mov qword[vecMensaje+1], rbx
    
    mov rbx, ':'
    mov qword[vecMensaje+2], rbx

    call getMin
    call binToAscii
    
    mov rbx, qword[rax+1]
    mov qword[vecMensaje+3], rbx
    mov rbx, qword[rax+0]
    mov qword[vecMensaje+4], rbx

    mov rbx, ':'
    mov qword[vecMensaje+5], rbx
    
    call getSeg
    call binToAscii

    mov rbx, qword[rax+1]
    mov qword[vecMensaje+6], rbx
    mov rbx, qword[rax+0]
    mov qword[vecMensaje+7], rbx
    
    mov rbx, ' '
    mov qword[vecMensaje+8], rbx
    mov rbx, 'h'
    mov qword[vecMensaje+9], rbx
    mov rbx, 's'
    mov qword[vecMensaje+10], rbx
    
    mov rax, rdx
    mov rbx, rcx
    call calcularPosicion
    
    mov rax, rsi
    mov rcx, 11
    call aplicarAtributos
    

    mov rsi, vecMensaje
    mov rcx, 11
    call imprimirTexto

    pop rbx
    pop rax
    pop rdi

    ret
 
; Procedimiento: cambiarModoInverso
;
; Cambia el color de fondo y el del caracter de cada pocision de la pantalla
; por su inverso correspondiente

cambiarModoInverso:
    mov rsi, VIDEO+1
    mov rcx, 80*25
    mod_inv:
        mov al, byte[rsi]
        and al, MASK_BACK + MASK_FORE
        not al
        and al, MASK_BACK + MASK_FORE
        
        mov bl, byte[rsi]
        and bl, MASK_BL_INT
        
        or al,bl

        mov byte[rsi], al 
        add rsi, 2
        loop mod_inv
    ret

; Procedimiento: aplicarAtributos
;
; Argumentos: rax -> Atributos
;             rdi -> Posicion a partir de la cual se desean esos atributos
;             rcx -> Cantidad de caracteres con esos atributos
;
; | Blink |  R  |  G  |  B  | Intense |  R  |  G  |  B  | 
; |       |   Background    |         |   Foreground    |

aplicarAtributos:
    push rdi

    add rdi, 1
    aplicar_atributos:
        mov byte[rdi], al 
        add rdi, 2
        loop aplicar_atributos

    pop rdi    
    ret

; Procedimiento: borrarPantallaParcial
;
; Argumentos: rdi -> Posicion X
;             rsi -> Posicion Y
;             rdx -> Atributos
;             rcx -> Cantidad        
;       
; | Blink |  R  |  G  |  B  | Intense |  R  |  G  |  B  | 
; |       |   Background    |         |   Foreground    |

borrarPantallaParcial:
    push rax
    push rbx
    
    mov rax, rdi
    mov rbx, rsi

    push rcx

    call calcularPosicion
    
    mov rsi, rdi
    inc rsi

    pop rcx

    clear_parcial:
        mov byte[rdi], ' '
        mov byte[rsi], dl 
        add rdi, 2
        add rsi, 2
        loop clear_parcial
    
    pop rbx
    pop rax
    
    ret

; Procedimiento: borrarPantalla
;
; Argumentos: al -> Atributos
; | Blink |  R  |  G  |  B  | Intense |  R  |  G  |  B  | 
; |       |   Background    |         |   Foreground    |

borrarPantalla:
    push rdi
    push rsi
    push rcx
    
    mov rdi, VIDEO
    mov rsi, VIDEO+1
    mov rcx, 80*25

    clear:
        mov byte[rdi], ' '
        mov byte[rsi], al 
        add rdi, 2
        add rsi, 2
        loop clear
    
    pop rcx
    pop rsi
    pop rdi
    
    ret

; Procedimiento: imprimirTexto
;
; Argumentos: rsi -> Cadena del mensaje
;             rdi -> Posicion de la memoria de video
;             rcx -> Largo de la cadena

imprimirTexto:
    imprimir_cadena:
        movsb
        inc rdi 
        loop imprimir_cadena
    ret

; Procedimiento: calcularPosicion
;
; Argumentos: rax -> Posicion X
;             rbx -> Posicion Y
;
; Guarda en edi la posicion de memoria correspondiente a (X,Y)

calcularPosicion:
    push rcx
    push rdx
    push rsi

    xor rcx, rcx
    xor rdx, rdx

    mov rsi, VIDEO
    mov rcx, 2
    mul rcx
    add rsi, rax

    mov rax, rbx
    mov rcx, 160
    mul rcx
    add rsi, rax

    mov rdi, rsi

    pop rsi
    pop rdx
    pop rcx

    ret

; Procedimiento: imprimirDecimal
;
; Argumentos: rax -> Variable decimal
;             rcx -> Digitos del número a mostrar
;
; Imprime en la pantalla un numero decimal de tipo int

imprimirDecimal:
    push rdi
    push rbx
    push rdx
    
    mov rbx, 10
    loop_to_string:
        mov rdx, 0
        div rbx
        add dl, 0x30
        mov byte[rdi], dl
        sub rdi, 2
        loop loop_to_string

    pop rdx
    pop rbx
    pop rdi

    ret

; Procedimiento: imprimirMensaje
;
; Argumentos: rdi -> Puntero al mensaje
;             rsi -> Atributos del mensaje
;             rdx -> Posicion X
;             rcx -> Posicion Y
;
; Imprime un mensaje de informacion

imprimirMensaje:
    push rax
    push rbx
    push r8
    push r9

    xor rax, rax
    xor rbx, rbx

    mov r8, rdi
    mov r9, rsi
    
    push rcx
    mov rax, rdx
    mov rbx, rcx
    call calcularPosicion 
    
    mov rax, r9
    mov rcx, mensaje_deco_size
    call aplicarAtributos

    mov rsi, mensaje_deco
    mov rcx, mensaje_deco_size
    call imprimirTexto
    
    pop rcx
    push rcx

    mov rax, rdx
    mov rbx, rcx
    add rbx, 1
    call calcularPosicion

    mov rax, r9
    mov rcx, mensaje_deco_center_size
    call aplicarAtributos

    mov rsi, mensaje_deco_center
    mov rcx, mensaje_deco_center_size
    call imprimirTexto
   
    pop rcx
    push rcx

    mov rax, rdx
    mov rbx, rcx
    add rbx, 2
    call calcularPosicion

    mov rax, r9
    mov rcx, mensaje_deco_size
    call aplicarAtributos

    mov rsi, mensaje_deco
    mov rcx, mensaje_deco_size
    call imprimirTexto
    
    pop rcx
    
    mov rax, rdx
    add rax, 2
    mov rbx, rcx
    add rbx, 1
    call calcularPosicion
    push rdi

    mov rdi, r8
    call strlen
    pop rdi
    push rcx
    
    mov rax, r9
    call aplicarAtributos
    
    pop rcx
    mov rsi, r8
    call imprimirTexto

    pop r9
    pop r8
    pop rbx
    pop rax

    ret

