;------------------------------------------------------------------------------
; defines.asm
;
; Autor: Leandro Beretta <lea.beretta@gmail.com> | Agosto 2012
;
; Definiciones generales para Assembler
;------------------------------------------------------------------------------

GLOBAL BASE_X_INFO_TAREAS, BASE_Y_INFO_TAREAS

%define     BASE_PML4T      0x10000
%define     BASE_PDPT       0x11000
%define     BASE_PDT        0x12000
%define     BASE_PT0        0x13000
%define     BASE_PDT_SSE    0x14000

%define PE_ON           0x01
%define PG_ON           0x80000000
%define PAE_ON          0x20
%define LME_ON          0x100
%define P_OFF           0xFFFF
%define SSE_EDX         0x7080000
%define SSE_EAX         0x201
%define OSFXSR_ON       0x100
%define OSXMMEXCPT_ON   0x200
%define CM_OFF          0xFFFFFFFB
%define MP_ON           0x02
%define TS_ON           0x08
%define TS_OFF          0xFFFFFFF7

check_55: times 16 db 0x55
check_AA: times 16 db 0xAA

%define BASE_IDT    0
%define BASE_PML4N  0x200000

; Indices para los contextos de las tareas

%define     RSP0     0  
%define     SS0      8
%define     CR3      16
%define     RIP      24
%define     RFLAGS   32
%define     RAX      40
%define     RBX      48
%define     RCX      56
%define     RDX      64
%define     R8       72
%define     R9       80
%define     RSP      88
%define     RBP      96
%define     RSI      104
%define     RDI      112
%define     ES       120
%define     CS       128
%define     SS       136
%define     DS       144
%define     FS       152
%define     GS       160
%define     R10      168
%define     R11      176
%define     R12      184
%define     R13      192
%define     R14      200
%define     R15      208

%define     XMM0     224
%define     XMM1     240
%define     XMM2     256
%define     XMM3     272
%define     XMM4     288
%define     XMM5     304
%define     XMM6     320
%define     XMM7     336

; Distintos tipos de System Call

%define     IMPRIMIR_TIEMPO                     0
%define     IMPRIMIR_FECHA                      1
%define     PS                                  2
%define     OBTENER_TICKS_TAREA                 3
%define     OBTENER_PRIV_TAREA                  4
%define     OBTENER_ES_PERMANENTE               5
%define     PUTS_FUNC                           6
%define     PUTN_FUNC                           7
%define     PUTC_FUNC                           8
%define     OBTENER_ORDEN_TAREA                 9
%define     BORRAR_PANTALLA_PARCIAL             10
%define     OBTENER_CANTIDAD_TAREAS             11
%define     OBTENER_TIEMPO_EJECUCION_TAREA      12

%define     BASE_X_INFO_TAREA           3
%define     BASE_Y_INFO_TAREA           2

%define VIDEO           0xB8000
%define MASK_BACK       0x70
%define MASK_BACK_AUX   0x8F
%define MASK_FORE       0x7
%define MASK_FORE_AUX   0xF8
%define MASK_BL_INT     0x88
%define BASE            0x00
%define BLINK           0x80
%define BACK_RED        0x40
%define BACK_GREEN      0x20
%define BACK_BLUE       0x10
%define INTENSITY       0x20
%define FORE_RED        0x20
%define FORE_GREEN      0x20
%define FORE_BLUE       0x20

%define TAREAS12        BASE + BACK_RED + BACK_GREEN + BACK_BLUE + FORE_RED

%define         BLACK           0
%define         BLUE            1
%define         GREEN           2
%define         CYAN            3
%define         RED             4
%define         MAGENTA         5
%define         BROWN           6     
%define         LIGHTGREY       7
%define         DARKGREY        8   
%define         LIGHTBLUE       9
%define         LIGHTGREEN      10
%define         LIGHTCYAN       11
%define         LIGHTRED        12
%define         LIGHTMAGENTA    13
%define         LIGHTBROWN      14
%define         WHITE           15
%define         BLINKING        128
%define         INTEN           8

%define         COLOR_TAREA_1_2         116   
%define         COLOR_TAREA_IDLE        114
%define         COLOR_TAREA_PS          113
%define         COLOR_KERNEL            112
%define         COLOR_KERNEL_2          7
%define         COLOR_KERNEL_3          64
%define         COLOR_KERNEL_4          32

%define 		KERNEL_PRIV		        3
%define	    	APP_PRIV		        7

pid:        db      "PID:"
            db      0
pipe:       db      '|'
priv:       db      "P:"
            db      0
kernel:     db      '0'
app:        db      '3'
te:         db      "TE:"
            db      0
ticks:      db      "T:"
            db      0
ps_back:    db      " PS: TP0:    TP3:                                                               "
            db      0
deltaTSC:   db      "Ciclos consumidos:     |"            
            db      0
lempty      db      "                                                                                "
            db      0
mem_ok:     db      " Memoria verificada correctamente | Ticks consumidos =                          "
            db      0
mem_error:  db      " Ha ocurrido un error al verificar la memoria                                   "
            db      0
mem_start:  db      " Verificando memoria                                                            "
            db      0
