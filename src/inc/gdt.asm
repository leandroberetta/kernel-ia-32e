;------------------------------------------------------------------------------
; gdt.asm
;
; Autor: Leandro Beretta <lea.beretta@gmail.com> | Agosto 2012
;
; Tabla global de descriptores
;------------------------------------------------------------------------------

GLOBAL gdt_64_code, gdt_64_data, gdt_64_code_a3, gdt_64_data_a3

; GDT
;
; 31                                 16                          0 
; +------+---+-----+---+-----+-------+---+-----+---+------+------+
; | BASE | G | D/B | L | AVL | LIMIT | P | DPL | S | TYPE | BASE |
; +------+---+-----+---+-----+-------+---+-----+---+------+------+
;   
; 31                                 16                          0
; +----------------------------------+---------------------------+
; | BASE                             | LIMIT                     |
; +----------------------------------+---------------------------+
;

gdt: 
; Seteo en 0 los primeros 8 bytes para el Null Descriptor
    dd 0           
    dd 0    

gdt_code equ $-gdt   
    dw 0xFFFF       ; Limit 15:00 -> 4GB
    dw 0x0000       ; Base 15:00
    db 0x0000       ; Base 23:16
    db 10011010b    ; P=1 | DPL=0 | S=1 | Type=1010 -> Code - Execute/Read 
    db 11001111b    ; G=1 | D/B=1 | L=0 | AVL= 0 | Limit 19:16
    db 0x0000

gdt_data equ $-gdt
    dw 0xFFFF       ; Limit 15:00 -> 4GB
    dw 0x0000       ; Base 15:00
    db 0x0000       ; Base 23:16
    db 10010010b    ; P=1 | DPL=0 | S=1 | Type=0010 -> Data - Read/Write 
    db 11001111b    ; G=1 | D/B=1 | L=0 | AVL= 0 | Limit 19:16
    db 0x0000

gdt_code_a3 equ $-gdt   
    dw 0xFFFF       ; Limit 15:00 -> 4GB
    dw 0x0000       ; Base 15:00
    db 0x0000       ; Base 23:16
    db 11111010b    ; P=1 | DPL=3 | S=1 | Type=1010 -> Code - Execute/Read 
    db 11001111b    ; G=1 | D/B=1 | L=0 | AVL= 0 | Limit 19:16
    db 0x0000

gdt_data_a3 equ $-gdt
    dw 0xFFFF       ; Limit 15:00 -> 4GB
    dw 0x0000       ; Base 15:00
    db 0x0000       ; Base 23:16
    db 11110010b    ; P=1 | DPL=3 | S=1 | Type=0010 -> Data - Read/Write 
    db 11001111b    ; G=1 | D/B=1 | L=0 | AVL= 0 | Limit 19:16
    db 0x0000

gdt_64_code equ $-gdt
    dw 0xFFFF       ; Limit 15:00 -> 4GB
    dw 0x0000       ; Base 15:00
    db 0x0000       ; Base 23:16
    db 10011010b    ; P=1 | DPL=0 | S=1 | Type=1010 -> Code - Execute/Read
    db 10101111b    ; G=1 | D/B=0 | L=1 | AVL= 0 | Limit 19:16
    db 0x0000

gdt_64_data equ $-gdt
    dw 0xFFFF       ; Limit 15:00 -> 4GB
    dw 0x0000       ; Base 15:00
    db 0x0000       ; Base 23:16
    db 10010010b    ; P=1 | DPL=0 | S=1 | Type=0010 -> Data - Read/Write 
    db 10101111b    ; G=1 | D/B=0 | L=1 | AVL= 0 | Limit 19:16
    db 0x0000

gdt_64_code_a3 equ $-gdt
    dw 0xFFFF       ; Limit 15:00 -> 4GB
    dw 0x0000       ; Base 15:00
    db 0x0000       ; Base 23:16
    db 11111010b    ; P=1 | DPL=3 | S=1 | Type=1010 -> Code - Execute/Read
    db 10101111b    ; G=1 | D/B=0 | L=1 | AVL= 0 | Limit 19:16
    db 0x0000

gdt_64_data_a3 equ $-gdt
    dw 0xFFFF       ; Limit 15:00 -> 4GB
    dw 0x0000       ; Base 15:00
    db 0x0000       ; Base 23:16
    db 11110010b    ; P=1 | DPL=3 | S=1 | Type=0010 -> Data - Read/Write 
    db 10101111b    ; G=1 | D/B=0 | L=1 | AVL= 0 | Limit 19:16
    db 0x0000

gdt_64_tss equ $-gdt
	dw 0x65					; Limite 15:00 -> Espacio ocupado por la TSS
	dw TSS					; Base 15:00 -> Direccion base de la TSS
	db 0						; Base 23:16
    db 10001001b			; P=1 | DPL=0 | 0 | Type=1001 
    db 0						
    db 0
 	dq 0

gdt_size equ $-gdt

gdtr:
   dw gdt_size-1
   dw idt_size+1
   dw 0

