
.text
cargar_datos:
		addi x1, x0, 6
        sw x1, 0(x0)
        addi x1, x0, 9
        sw x1, 4(x0)
        addi x1, x0, 3
        sw x1, 8(x0)
        addi x1, x0, 1
        sw x1, 12(x0)
main:	add x2, x0, x0
		add x3, x0, x0
		addi x3, x3, 3
		add s2, x0, x0
		addi s2, s2, 1
		lw t6, 0(x0)
		lw t5, 4(x0)
		lw t4, 8(x0)
		lw t3, 12(x0)
loop:
loop1:	
		SLT x4,t3,t4
        BEQ x4,s2,loop2
		add x1, t3, x0
		add t3, t4, x0
		add t4, x1, x0		
loop2:
		SLT x4,t4,t5
        BEQ x4,s2,loop3
		add x1, t4, x0
		add t4, t5, x0
		add t5, x1, x0
loop3:
		BEQ x2, x3, guardar
		addi x2, x2, 1
		SLT x4,t5,t6
        BEQ x4,s2,loop1
		add x1, t5, x0
		add t5, t6, x0
		add t6, x1, x0
		BEQ x0, x0, loop1

#Necesitaremos:
#Dos registros para llevar la cuenta en bucle
#Registro auxiliar

#Bucle for 1
guardar:
		sw t6, 12(x0)
		sw t5, 8(x0)
		sw t4, 4(x0)
		sw t3, 0(x0)
		
#Bucle for 2

finish: