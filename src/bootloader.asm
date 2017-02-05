;------------------------------------------------------------------------------
; bootloader.asm
;
; Autor: Leandro Beretta <lea.beretta@gmail.com> | Septiembre 2012
;
; Bootloader para iniciar el kernel
;------------------------------------------------------------------------------

[ORG 0x7C00]

[BITS 16]

    cli

    mov ax, 0           
    mov es, ax          
    mov bx, KERNEL_START

    mov ah, 0x02
    mov al, KERNEL_SECTORS
    mov cl, 0x02                ; Primer sector a copiar, sector 2
    mov ch, 0                   ; Cylinder = 0
    mov dh, 0                   ; Head = 0
    mov dl, 0                   ; Drive = 0
    int 13h  
    jc error
    sti

    jmp (KERNEL_START>>4):0   

    error:
	    jmp $

    times 510-($-$$) db 0        ; Firma para que el disco sea booteable
    dw 0xAA55

