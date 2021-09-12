//Separate Compilation and Linking - Call ASM function from C code

//Defines the body of Sum function called from C code
		.text
		.balign 4
		.global sum
sum: 
		stp x29, x30, [sp, -16]!
		mov x29, sp 

		add w0, w0, w1	// Add the two passed arguments 
						//and return result in w0

		ldp x29, x30, [sp], 16 
		ret
		