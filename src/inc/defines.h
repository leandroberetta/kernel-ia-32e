/*-----------------------------------------------------------------------------
-- defines.c
--
-- Autor: Leandro Beretta <lea.beretta@gmail.com> | Agosto 2012
--
-- Definiciones generales para C
-----------------------------------------------------------------------------*/

#define		MAX_TAREAS		50
#define   MAX_TICKS     20
#define   MIN_TICKS     1

#define		KERNEL_PRIV		3
#define		APP_PRIV		  7
#define		PERMANENTE		0
#define		REMOVIBLE		  1
#define   TICKS_DFLT    2

#define		TRUE			    0
#define		FALSE			    1

#define   NULL          0

#define   BASE_PML4N    0x200000
#define   TIME_FRAME    100

#define   TAREA_IDLE    0
#define   TAREA_1       1
#define   TAREA_2       2

#define   MANTENER      0
#define   AUMENTAR      1
#define   DISMINUIR     2

#define   BASE_X_INFO_TAREAS      3
#define   BASE_Y_INFO_TAREAS      2

#define   COLOR_TAREA_1_2         116
#define   COLOR_TAREA_IDLE        114
#define   COLOR_TAREA_PS          113
#define   COLOR_KERNEL            112
#define   COLOR_KERNEL_2          7
#define   COLOR_KERNEL_3          64
