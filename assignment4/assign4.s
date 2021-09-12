// File: assign4.asm
// Author: Ayman Shahriar	UCID: 10180260
// Date: November 6, 2019



// format strings
fmt1:		.string	"Cuboid %s origin = (%d, %d)\n"					// string format for name and origin of cuboid
fmt2:		.string	"\tBase width = %d	Base length = %d\n"			// string format for base and width of cuboid
fmt3:		.string "\tHeight = %d\n"						// string format for height of cuboid
fmt4:		.string "\tVolume = %d\n\n"						// string format for volume of cuboid
fmt5:		.string "Initial cuboid values:\n"					// string format for printing "Initial cuboid values"
fmt6:		.string "first"								// string format for the name of a cuboid
fmt7:		.string "second"							// string format for the name of a cuboid
fmt8:		.string "\nChanged cuboid values:\n"					// string format for printing "Changed cuboid values"


		FALSE = 0								// set FALSE to be constant 0
		TRUE = 1								// set TRUE to ne constant 1

		point_x = 0								// offset of x is 0
		point_y = 4								// offset of y is 4

		dimension_width = 0							// offset of width is 0
		dimension_length = 4							// offset of length is 4
		
		cuboid_origin = 0							// offset of origin is 0
		cuboid_base = 8								// offset of base is 8
		cuboid_height = 16							// offset of height is 16
		cuboid_volume = 20							// offset of volume is 20	

		first_size = 24								// size of cuboid first is 24
		second_size = 24							// size of cuboid second is 25
		alloc1 = -(16 + first_size + second_size) & -16				// used to increment sp at the start of main
		dealloc1 = -alloc1							// used to decrement sp at the end of main
		first_s = 16								// offset of cuboid named first
		second_s = 16 + first_size						// offset of cuboid named second

		.balign 4								// to ensure all machine instructions are word aligned
		.global main								// makes label main visible to the linker


main:		stp 	x29, x30, [sp, alloc1]!						// increment sp, then store fp and lr 
		mov	x29, sp								// change value of fp into sp

		add	x8, x29, first_s						// move address of cuboid named first to x8 
		bl	newCuboid							// call newCuboid function to initialize first

		add	x8, x29, second_s						// mov address of cuboid named second to x8 
		bl	newCuboid							// call newCuboid function to initialize second

		// print "initial values"
		adrp	x0, fmt5							// set 1st arg (high order bits)
		add	x0, x0, :lo12:fmt5						// set low 12 order bits of 1st arg
		bl	printf								// call print function

		// print fields of cuboid named "first"
		adrp	x0, fmt6							// set 1st arg to be string "first"
		add	x0, x0, :lo12:fmt6						// set low 12 bits of 1st arg
		add	x1, x29, first_s						// set 2nd arg to contain address of cuboid named first
		bl	printCuboid							// call printCuboid function

		// print fields of cuboid named "second"
		adrp	x0, fmt7							// set 1st arg to be string "second"
		add	x0, x0, :lo12:fmt7						// et low 12 bits of 1st arg
		add	x1, x29, second_s						// set 2nd arg to contain address of cuboid named second
		bl	printCuboid							// call printCuboid function

		// check if both cuboids have equal field values			
		add	x0, x29, first_s						// set 1st arg to be address of cuboid first
		add	x1, x29, second_s						// set 2nd arg to be address of cuboid named second
		bl	equalSize							// call equalSize function
		cmp	w0, wzr								// check if result of equalSize function is FALSE
		b.eq	next2								// if result is false, branch to next2

		// use the move function on cuboid first
		add	x0, x29, first_s						// set 1st arg to be address of first
		mov	w1, 3								// set 2nd arg to be int 3
		mov	w2, -6								// set 3rd arg to be int -6
		bl	move								// call move function
		
		// use the scale function on cuboid second
		add	x0, x29, second_s						// set 1st arg to be address of cuboid second
		mov	w1, 4								// set 2nd arg to be int 4
		bl	scale								// call scale function
		
		// print "Changed cuboid values:"
next2:		adrp	x0, fmt8							// set 1st arg (high order bits) to be fmt8
		add	x0, x0, :lo12:fmt8						// set 1st arg (low 12 bits)
		bl	printf								// call print function
		
		// print first cuboid
		adrp	x0, fmt6							// set 1st arg (high order bits) to be fmt6
		add	x0, x0, :lo12:fmt6						// set low 12 bits of 1st arg
		add	x1, x29, first_s						// set 2nd arg to be address of cuboid first
		bl	printCuboid							// call printCuboid function
	
		// print second cuboid
		adrp	x0, fmt7							// set 1st arg (high order bits) to be fmt7
		add	x0, x0, :lo12:fmt7						// set low 12 bits of 1st arg
		add	x1, x29, second_s						// set 2nd arg to be address of cuboid second
		bl	printCuboid							// call printCuboid function

		ldp	x29, x30, [sp], dealloc1					// load fp and lr, and then decrement sp
		ret									// returns control to caling code (in os)



// code for the newCuboid function
									// register for holding base of struct c
		c_size = 24								// size of c is 24
		alloc2 = -(16 + c_size) & -16						// used to increment sp at start of newCuboid
		dealloc2 = -alloc2							// used to decrement sp at end of newCuboid
		c_s = 16								// offset of c is 16

newCuboid:	stp	x29, x30, [sp, alloc2]!						// increment sp, then store fp and lr
		mov	x29, sp								// set fp to be value of sp

		add	x9, x29, c_s						// set base address of c
		
		// set origin.x, origin.y of c
		mov	w10, 0								// w10 = 0
		str	w10, [x9, cuboid_origin + point_x]				// c.origin.x = 0
		str	w10, [x9, cuboid_origin + point_y]				// c.origin.y = 0
		
		// set base.width, base.length of c
		mov	w11, 2
		str	w11, [x9, cuboid_base + dimension_width]			// c.base.width = 2
		str	w11, [x9, cuboid_base + dimension_length]			// c.base.length = 2
		
		// set height of c
		mov	w12, 3								// w12 = 3
		str	w12, [x9, cuboid_height]					// c.height = 3
		
		// calculate volume
		mul	w13, w11, w11							// w13 = c.base.width * c.base.length
		mul	w13, w13, w12							// w13 = w13 * c.height
		str	w13, [x9, cuboid_volume]					// c.volume = c.base.width * c.base.length * c.height

		// now set the fields of the cuboid whose address is in x8 to be the same as the fields of c
		str	w10, [x8, cuboid_origin + point_x]				// set origin.x of cuboid at address in x8 to be that of c
		str	w10, [x8, cuboid_origin + point_y]				// set origin.y of cuboid at address in x8 to be that of c
		str	w11, [x8, cuboid_base + dimension_width]			// set base.width of cuboid at address in x8 to be that of c
		str	w11, [x8, cuboid_base + dimension_length]			// set base.length of input cuboid to be that of c
		str	w12, [x8, cuboid_height]					// set height of input cuboid to be that of c
		str	w13, [x8, cuboid_volume]					// set volume of input cuboid to be that of c
		
		ldp	x29, x30, [sp], dealloc2					// load fp and lr, then decrement sp
		ret									// returns control to calling code



// code for the move function
move:		stp	x29, x30, [sp, -16]!						// increment sp, then store fp and lr
		mov	x29, sp								// set fp to be value of sp
		

		ldr	w9, [x0, cuboid_origin + point_x]				// get origin.x of the struct
		add	w1, w1, w9							// add deltaX to origin.x of the struct
		str	w1, [x0, cuboid_origin + point_x]				// store the new value of origin.x back to the struct
		
		ldr	w9, [x0, cuboid_origin + point_y]				// get origin.y of the struct
		add	w2, w2, w9							// add deltaY to origin.y of the struct
		str	w2, [x0, cuboid_origin + point_y]				// store the new value of origin.y back to the struct

		ldp	x29, x30, [sp], 16						// loads fp and lr, and then decrements sp
		ret									// returns control to calling code



// Code for the printCuboid function
		x19_size = 8								// calculate size of x19
		x20_size = 8								// calculate size of x20
		alloc3 = -(16 + x19_size + x20_size) & -16				// used to increment sp at start of printCuboid
		dealloc3 = -alloc3							// used to decrement sp at end of printCuboid
		x19_save = 16								// calculate offset to store x19
		x20_save = 16 + x19_size						// calculate offset to store x20

printCuboid:	stp	x29, x30, [sp, alloc3]!						// increment sp, then store fp and lr
		mov	x29, sp								// set fp to be sp
		str	x19, [x29, x19_save]						// save contents of x19 to stack
		str	x20, [x29, x20_save]						// save contents of x20 to stack

		mov	x19, x0								// move cuboid's name into x19
		mov	x20, x1								// move	cuboid's address into x20

		// print name of input struct, origin.x, origin.y
		adrp	x0, fmt1							// set 1st arg (high order bits) to be fmt1
		add	x0, x0, :lo12:fmt1						// set 1st arg (low order bits)
		mov	x1, x19								// set 2nd arg to be address of input cuboid
		ldr	w2, [x20, cuboid_origin + point_x]				// set 3rd arg to be origin.x of input cuboid
		ldr	w3, [x20, cuboid_origin + point_y]				// set 4th arg to be origin.y of input cuboid
		bl	printf								// call print function
		
		// print base.width, base.length of input cuboid
		adrp	x0, fmt2							// set 1st arg (high order bits) to be fmt2
		add	x0, x0, :lo12:fmt2						// set 1st arg (low 12 order bits)
		ldr	w1, [x20, cuboid_base + dimension_width]			// set 2nd arg to be base.width of input cuboid
		ldr	w2, [x20, cuboid_base + dimension_length]			// set 3rd arg to be base.length of input cuboid
		bl	printf								// call print function

		adrp	x0, fmt3							// set 1st arg (high irder bits) to be fmt3
		add	x0, x0, :lo12:fmt3						// set 1st arg (low 12 order bits)
		ldr	w1, [x20, cuboid_height]					// set 2nd arg to be height of input cuboid
		bl	printf								// call print function

		adrp	x0, fmt4							// set 1st arg (high order bits) to be fmt4
		add	x0, x0, :lo12:fmt4						// set 1st arg (low 12 order bits)
		ldr	w1, [x20, cuboid_volume]					// set 2nd arg to be volume of input cuboid
		bl	printf								// call print function

		ldr	x19, [x29, x19_save]						// restore contents of x19 from stack
		ldr	x29, [x29, x20_save]						// restore contents of x20 from stack
		ldp	x29, x30, [sp], dealloc3					// load fp and lr, then decrement sp
		ret									// return control to calling code



// code for the scale function
scale:		stp 	x29, x30, [sp, -16]!						// increment sp, then store fp and lr
		mov	x29, sp								// change value of fp to sp

		ldr	w9, [x0, cuboid_base + dimension_width]				// retrieve base.width of input cuboid
		mul	w9, w9, w1							// multiply base.width by factor (second input)
		str	w9, [x0, cuboid_base + dimension_width]				// save updated base.width to stack

		ldr	w10, [x0, cuboid_base + dimension_length]			// retrieve base.length of input cuboid
		mul	w10, w10, w1							// multiply base by factor (second input)
		str	w10, [x0, cuboid_base + dimension_length]			// save updated base.length to stack

		ldr	w11, [x0, cuboid_height]					// retrieve height of input cuboid
		mul	w11, w11, w1							// multiply height by factor (second input)
		str	w11, [x0, cuboid_height]					// save updated height to stack

		mul	w12, w9, w10							// w12 = base.length * base.height
		mul	w12, w12, w11							// w12 = w12 * volume
		str	w12, [x0, cuboid_volume]  					// save updated volume (in w12) to stack

		ldp	x29, x30, [sp], 16						// load fp and lr, then deallocate sp
		ret									// return control to calling code
		

// code for the equalSize function
		result_size = 4								// set size of result to be 4. (result is a local variable)
		alloc4 = -(16 + result_size) & -16					// used to increment sp at start of subroutine
		dealloc4 = -alloc4							// used to decrement sp ar end of subroutine
		result_s = 16								// set offset of result

equalSize:	stp	x29, x30, [sp, alloc4]!						// increment sp, then store fp and lr
		mov	x29, sp								// set value of fp to be that of sp

		mov	w9, FALSE							// w9 = FALSE
		str	w9, [x29, result_s]						// result = FALSE

		ldr	w9, [x0, cuboid_base + dimension_width]				// w9 = base.width of first input cuboid
		ldr	w10, [x1, cuboid_base + dimension_width]			// w10 = base.width of second input cuboid
		cmp	w9, w10								// compare base.width of the two cuboids
		b.ne	next1								// if their base.width is different, branch to next1

		ldr	w9, [x0, cuboid_base + dimension_length]			// w9 = base.length of first input cuboid 
		ldr	w10, [x1, cuboid_base + dimension_length]			// w10 = base.length of second input 
		cmp	w9, w10								// compare base.length of the two cuboids 
		b.ne	next1								// if their base.length is different, branch to next1

		ldr	w9, [x0, cuboid_height]						// w9 = height of first input cuboid
		ldr	w10, [x1, cuboid_height]					// w10 = height of second input cuboid
		cmp	w9, w10								// compare height of the two cuboids
		b.ne	next1								// if their height is different, then branch to next1

		mov	w9, TRUE							// set w9 = TRUE
		str	w9, [x29, result_s]						// update return to be TRUE

next1:		ldr	w0, [x29, result_s]						// set return value to be the result variable

		ldp	x29, x30, [sp], dealloc4					// load fp and lr, then decrement sp
		ret									// returns control to calling code (in os)

















