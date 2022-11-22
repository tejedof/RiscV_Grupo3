#Cargamos la lista
.data
	n0: .byte 6
	n1: .byte 9
	n2: .byte 3
	n3: .byte 1

.text
main:	add x2, x0, x0
		add x3, x0, x0
		addi x3, x3, 3
		add s2, x0, x0
		addi s2, s2, 1
		la t2, n3
		lb t6, 0(t2)
		la t2, n2
		lb t5, 0(t2)
		la t2, n1
		lb t4, 0(t2)
		la t2, n0
		lb t3, 0(t2)
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
		la t2, n3
		sb  0(t2), t6
		la t2, n2
		sb 0(t2),t5
		la t2, n1
		sb 0(t2),t4
		la t2, n0
		sb 0(t2),t3
		
#Bucle for 2

finish: