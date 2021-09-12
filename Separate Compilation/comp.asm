		
		.text
fmt: 	.string 	" %d \n"

		.balign 4

		.global main			//Make main visible to OS
main: 
		stp 	x29, x30, [sp, -16]!
		mov 	x29, sp
		
		adrp 	x19, a_m
		add 	x19, x19, :lo12:a_m
		ldr 	w0, [x19] 
		
		bl myfunc
		
		mov w19, w0
		
		adrp	x0, fmt					// Load address of i (high order bits)
		add		x0, x0, :lo12:fmt		// Load address of i (low order bits)
		mov		w1, w19
		
		bl printf
		
		ldp x29, x30, [sp], 16 
		ret
