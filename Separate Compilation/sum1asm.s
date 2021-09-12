//Separate Compilation and Linking - Call C function from ASM
size = 4
alloc = -(16 + size*3) & -16 			//i, j, result - 4 bytes each = 4*3
dealloc = -alloc
//Offsets
i_m = 16
j_m = 20 
result_m = 24
			.bss
			.global num
num:		.skip	4	//Can also be done in data section using '.word' opcode and initialise as 0		
		.text	
fmt: 	.string "result = %d, num = 2 x result =  %d\n\n"
		.balign 4
		.global main
main: 
		stp x29, x30, [sp, alloc]!
		mov x29, sp
//Store local variables on to stack
		mov w19, 5								// i = 5
		str w19, [x29, i_m] 		
		mov w19, 10								// j = 10
		str w19, [x29, j_m]
			

//Load values from stack to pass to sum function
		ldr w0, [x29, i_m] 					// Set up 1st arg for sum1.c
		ldr w1, [x29, j_m]  					// Set up 2nd arg for sum1.c		
		bl sum							// Call function defined in sum1.c

		mov w1, w0 
//Load address of num
		adrp x20, num
		add x20, x20, :lo12:num 				// Set up 2nd arg for printf
		adrp x0, fmt
		add x0, x0, :lo12:fmt 					// Set up 1st arg  for printf
		ldr w2, [x20]
		bl printf

		ldp x29, x30, [sp], dealloc 
		ret
		
