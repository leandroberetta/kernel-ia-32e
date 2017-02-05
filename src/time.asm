;------------------------------------------------------------------------------
; clock.asm
;
; Autor: Leandro Beretta <lea.beretta@gmail.com> | Agosto 2012
;
; Procedimientos utiles para el manejo del RTC
;------------------------------------------------------------------------------

EXTERN convertirDec

GLOBAL getHora, getMin, getSeg, getAnio, getMes, getDia

[BITS 64]

; Procedimiento: esperoActualizacionRTC
;
; Recibe: -
; Devuele: -
;
; Verifica que el RTC no se este actualizando

esperoActualizacionRTC:
    mov al, 0x0a
    out 0x70, al
    espero:
        in al, 0x71
        test al, 0x80
        jnz espero
 
    ret

; Procedimiento: getHora
;
; Recibe: -
; Devuele: al -> Hora
;

getHora:
    call esperoActualizacionRTC

    mov	rax, 4
	out	0x70, al		
	in al, 0x71	
    
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    mov rdi, rax
    call convertirDec
    
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx

    ret

; Procedimiento: getMin
;
; Recibe: -
; Devuelve: al -> Minutos
;

getMin:
    call esperoActualizacionRTC
    
    mov	rax, 2
	out	0x70, al		
	in al, 0x71		

    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    mov rdi, rax
    call convertirDec
    
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx


    ret

; Procedimiento: getSeg
;
; Recibe: -
; Devuelve: al -> Segundos
;

getSeg:
    call esperoActualizacionRTC
    
    mov	rax, 0
	out	0x70, al		
	in al, 0x71			

    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    mov rdi, rax
    call convertirDec
  
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    
    ret
    
; Procedimiento: getAnio
;
; Recibe: -
; Devuele: al -> Año
;

getAnio:
    call esperoActualizacionRTC
    
    mov	rax, 9
	out	0x70, al		
	in al, 0x71			

    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    mov rdi, rax
    call convertirDec
  
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx

    ret

; Procedimiento: getHora
;
; Recibe: -
; Devuele: al -> Hora
;
; Verifica que el RTC no se este actualizando

getMes:
    call esperoActualizacionRTC

    mov	rax, 8
	out	0x70, al		
	in al, 0x71			

    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    mov rdi, rax
    call convertirDec
  
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx

    ret

; Procedimiento: getHora
;
; Recibe: -
; Devuele: al -> Hora
;
; Verifica que el RTC no se este actualizando

getDia:
    call esperoActualizacionRTC

    mov	rax, 7
	out	0x70, al		
	in al, 0x71			

    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    mov rdi, rax
    call convertirDec
  
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx

    ret

