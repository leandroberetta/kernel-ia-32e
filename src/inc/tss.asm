;------------------------------------------------------------------------------
; tss.asm
;
; Autor: Leandro Beretta <lea.beretta@gmail.com> | Agosto 2012
;
; TSS para mantener el RSP0
;------------------------------------------------------------------------------

struc tss
						resd 1
	.RSP_0				resq 1
	.RSP_1				resq 1
	.RSP_2				resq 1
						resq 1
    .IST_1				resq 1							
    .IST_2				resq 1							
    .IST_3				resq 1							
    .IST_4				resq 1							
    .IST_5				resq 1							
    .IST_6				resq 1							
    .IST_7				resq 1							
						resq 1
						resw 1
    .IOMAP      		resw 1
endstruc    

TSS istruc tss
	at tss.RSP_0,							 dq BASE_PML4N + (1*7*4096) + 6*4096 + 4095
	at tss.RSP_1,							 dq 0
	at tss.RSP_2,							 dq 0
	at tss.IST_1,							 dq 0
	at tss.IST_2,							 dq 0
	at tss.IST_3,							 dq 0
	at tss.IST_4,							 dq 0
	at tss.IST_5,							 dq 0
	at tss.IST_6,							 dq 0
	at tss.IST_7,							 dq 0
	at tss.IOMAP,							 dw 0
iend






    
