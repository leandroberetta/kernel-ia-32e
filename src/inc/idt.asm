;------------------------------------------------------------------------------
; idt.asm
;
; Autor: Leandro Beretta <lea.beretta@gmail.com> | Agosto 2012
;
; Tabla de descriptores de interrupcion y excepciones
;------------------------------------------------------------------------------

; IDT (64 bits)
;
; 31                                                             0 
; +--------------------------------------------------------------+
; | Reserved                                                     |
; +--------------------------------------------------------------+

; 31                                                             0 
; +--------------------------------------------------------------+
; | OFFSET                                                       |
; +--------------------------------------------------------------+
; 
; 31                      16                                     0 
; +-----------------------+---------+---+------+-----------+-----+
; | OFFSET                | P | DPL | 0 | TYPE | 0 0 0 0 0 | IST |
; +-----------------------+---------+---+------+-----------+-----+
;   
; 31                         16                                  0
; +--------------------------+-----------------------------------+
; | SEGMENT SELECTOR         | OFFSET                            |
; +--------------------------+-----------------------------------+
;

idt:

    dw __00_exc
    dw gdt_64_code
    db 0
    db 10001110b
    dw 0
    dq 0

    dw __01_exc
    dw gdt_64_code
    db 0
    db 10001110b
    dw 0
    dq 0
    
    dq 0
    dq 0

    dw __03_exc
    dw gdt_64_code
    db 0
    db 10001110b
    dw 0
    dq 0

    dw __04_exc
    dw gdt_64_code
    db 0
    db 10001110b
    dw 0
    dq 0

    dw __05_exc
    dw gdt_64_code
    db 0
    db 10001110b
    dw 0
    dq 0

    dw __06_exc
    dw gdt_64_code
    db 0
    db 10001110b
    dw 0
    dq 0

    dw __07_exc
    dw gdt_64_code
    db 0
    db 10001110b
    dw 0
    dq 0

    dw __08_exc
    dw gdt_64_code
    db 0
    db 10001110b
    dw 0
    dq 0

    dw __09_exc
    dw gdt_64_code
    db 0
    db 10001110b
    dw 0
    dq 0

    dw __10_exc
    dw gdt_64_code
    db 0
    db 10001110b
    dw 0
    dq 0

    dw __11_exc
    dw gdt_64_code
    db 0
    db 10001110b
    dw 0
    dq 0

    dw __12_exc
    dw gdt_64_code
    db 0
    db 10001110b
    dw 0
    dq 0

    dw __13_exc
    dw gdt_64_code
    db 0
    db 10001110b
    dw 0
    dq 0

    dw __14_exc
    dw gdt_64_code
    db 0
    db 10001110b
    dw 0
    dq 0

    dq 0
    dq 0

    dw __16_exc
    dw gdt_64_code
    db 0
    db 10001110b
    dw 0
    dq 0

    dw __17_exc
    dw gdt_64_code
    db 0
    db 10001110b
    dw 0
    dq 0

    dw __18_exc
    dw gdt_64_code
    db 0
    db 10001110b
    dw 0
    dq 0

    dw __19_exc
    dw gdt_64_code
    db 0
    db 10001110b
    dw 0
    dq 0

    dq 0
    dq 0
    dq 0
    dq 0
    dq 0
    dq 0
    dq 0
    dq 0
    dq 0
    dq 0
    dq 0
    dq 0
    dq 0
    dq 0
    dq 0
    dq 0
    dq 0
    dq 0
    dq 0
    dq 0
    dq 0
    dq 0
    dq 0
    dq 0

    dw scheduler            ; Posicion de la funcion en C que maneja el scheduler
    dw gdt_64_code
    db 0
    db 0x8E
    dw 0
    dq 0

    dw handlerTeclado
    dw gdt_64_code              
    db 0       
    db 0x8E                 ; P=1 | DPL=0 | D=1 (32 bits)
    dw 0
    dq 0
    
    times 188 dq 0
    
    dw int80h
    dw gdt_64_code              
    db 0       
    db 11101110b                 ; P=1 | DPL=3 | D=1 (32 bits)
    dw 0
    dq 0


idt_size equ $ - idt

idtr:
    dw idt_size - 1
    dw 0
    dw 0

