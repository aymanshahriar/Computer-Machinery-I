// File: assign2b.asm
// Author: Ayman Shahriar	UCID: 10190260
// Date: October 3, 2019




// format strings
fmt1:		.string "multiplier = 0x%08x (%d)   multiplicand = 0x%08x (%d)\n\n"		// Define string formats for printf
fmt2:		.string "product = 0x%d  multiplier = 0x%08x \n"
fmt3:		.string "64-bit result = 0x%016lx (%ld)\n"


// Define m4 macros
define(FALSE, 0)										// Defines FALSE to be constant of 0
define(TRUE, 1)											// Defines TRUE to be constant of 1
define(multiplier, w20)										// Defines multiplier to be w20
define(multiplicand, w21)									// Defines multiplicand to be w21
define(product, w22)										// Defines product to be w22
define(i, w23)											// Defines i to be w23
define(negative, w24)										// Defines negative to be w24
define(result, x25)										// Defines result to be x25
define(temp1, x26)										// Defines temp1 to be x26
define(temp2, x27)										// Defines temp7 to be x27


		.global main									// makes the label "main" visible to the linker
		.balign 4									// Ensures instructions are properly aligned

main:		stp	x29, x30, [sp, -16]!							// Stores contents of x29, sp to the stack
		mov	x29, sp									// Updates x29 to the current sp
						

		// initialize variables
		mov	multiplicand, 522133279							// set multiplicand to 522133279
		mov	multiplier, 200								// set multiplier to 200
		mov	product, 0								// set product to 0

		// print out initial values of variables
		adrp	x0, fmt1								// set first arg (high order bits)
		add	x0, x0, :lo12:fmt1							// set first arg (lower 12 bits)
		mov	w1, multiplier								// put multiplier as second argument
		mov	w2, multiplier								// put multiplier as third argument
		mov	w3, multiplicand							// put multiplicand as fourth argument
		mov	w4, multiplicand							// put multiplicand as fifth argument
		bl	printf									// call the print function


		// determine if multiplier is negative
		cmp	multiplier, wzr								// multiplier is compared with wzr 
		b.ge	else									// if multiplier is equal to wzr, branch to else
		mov	negative, TRUE								// set netative to TRUE
		b	next									// branch to next
else:		mov	negative, FALSE								// set negative to FALSE
		

next:		
// begin loop from 0 to 31
		mov	i, 0									// set i to be 0
		b	test									// branch to test (which is the loop test)


		// do repeated add and shift
start: 		tst	multiplier, 0x1								// test if lsb of multiplier is 1
		b.eq	bitclear1								// if lsb of multiplier is 0, branch to bitclear1
bitset1:	add	product, product, multiplicand						// add product with multiplicand, store result in product


bitclear1:	// arithmetic shift right the combined product and multiplier
		asr	multiplier, multiplier, 1						// arithmetic shift right multiplier by 1, storing the result in multiplier
		tst	product, 0x1								// test if lsb of product is 1
		b.eq	bitclear2								// if lsb og product is 0, branch to bitclear2
bitset2:	orr	multiplier, multiplier, 0x80000000					// bitwise or multiplier with 0x80000000, storing the result in multiplier
		b	next1									// branch to next1
bitclear2:	and	multiplier, multiplier, 0x7FFFFFFF					// bitwise and multiplier with ox7FFFFFFF, storing th eresult in multiplier
next1:		asr	product, product, 1							// arithmetic shift right product by 1, storing the result back to product


		add	i, i, 1									// increment i by 1
test:		cmp	i, 32									// compare i with 32
		b.lt	start									// if i is less than 32, branch to start

// end of loop

		// Adjust product register if multiplier is negative
		cmp	negative, wzr								// compare negative with wzr
		b.eq	next2									// if negative is equal to wzr, branch to next2
		sub	product, product, multiplicand						// subtract product with multiplicand, storing the result in product
		
next2:
		// print out product and multiplier
		adrp 	x0, fmt2								// set first arg (high order bits)
		add	x0, x0, :lo12:fmt2							// set first arg (lower 12 bits)
		mov	w1, product								// set w1 to be the product
		mov	w2, multiplier								// set w2 to multiplier
		bl	printf									// call print function

		
		// combine product and multiplier together
		sxtw	x28, product								// typecast product to be a 64 bit register x28
		and	temp1, x28, 0xFFFFFFFF							// bitwise and x28 with 0xFFFFFFFF, storing the result in temp1
		lsl	temp1, temp1, 32							// logical shift left temp 1 by 32
		sxtw	x28, multiplier								// typecase multiplier to a 64 bit register x28
		and	temp2, x28, 0xFFFFFFFF							// bitwise and x28 with 0xFFFFFFFF, storing th eresult in temp2
		add	result, temp1, temp2							// bitwise and temp1 with temp2, storing the result in result



		// print out 64 bit result
		adrp	x0, fmt3								// set first arg (high order bits)
		add	x0, x0, :lo12:fmt3							// set first arg (lower 12 bits)
		mov	x1, result
		mov	x2, result
		bl	printf


		ldp	x29, x30, [sp], 16							// loads x29, x30 from RAM and deallocates 16 bytes in stack memory
		ret										// returns control to caling code (in os)
