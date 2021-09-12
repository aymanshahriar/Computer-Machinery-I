		.balign 4
		.data
		.global 	a_m
a_m: 	.word 	404 					// global constant

		.text
		.global myfunc
myfunc: 
		stp x29, x30, [sp, -16]!
		mov x29, sp 
		
		add w0, w0, 10
		

		ldp x29, x30, [sp], 16 

		ret
