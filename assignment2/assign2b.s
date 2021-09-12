// File: assign2b.asm
// Author: Ayman Shahriar	UCID: 10190260
// Date: October 3, 2019




// format strings
fmt1:		.string "multiplier = 0x%08x (%d)   multiplicand = 0x%08x (%d)\n\n"		// Define string formats for printf
fmt2:		.string "product = 0x%d  multiplier = 0x%08x \n"
fmt3:		.string "64-bit result = 0x%016lx (%ld)\n"


// Define m4 macros
										// Defines 0 to be constant of 0
											// Defines 1 to be constant of 1
										// Defines w20 to be w20
									// Defines w21 to be w21
										// Defines w22 to be w22
											// Defines w23 to be w23
										// Defines w24 to be w24
										// Defines x25 to be x25
										// Defines x26 to be x26
										// Defines temp7 to be x27


		.global main									// makes the label "main" visible to the linker
		.balign 4									// Ensures instructions are properly aligned

main:		stp	x29, x30, [sp, -16]!							// Stores contents of x29, sp to the stack
		mov	x29, sp									// Updates x29 to the current sp
						

		// initialize variables
		mov	w21, 522133279							// set w21 to 522133279
		mov	w20, 200								// set w20 to 200
		mov	w22, 0								// set w22 to 0


		adrp	x0, fmt1								// set first arg (high order bits)
		add	x0, x0, :lo12:fmt1							// set first arg (lower 12 bits)
		mov	w1, w20								// put w20 as second argument
		mov	w2, w20								// put w20 as third argument
		mov	w3, w21							// put w21 as fourth argument
		mov	w4, w21							// put w21 as fifth argument
		bl	printf									// call the print function


		// determine if w20 is w24
		cmp	w20, wzr								// w20 is compared with wzr 
		b.ge	else									// if w20 is equal to wzr, branch to else
		mov	w24, 1								// set netative to 1
		b	next									// branch to next
else:		mov	w24, 0								// set w24 to 0
		

next:		
// begin loop from 0 to 31
		mov	w23, 0									// set w23 to be 0
		b	test									// branch to test (which is the loop test)


		// do repeated add and shift
start: 		tst	w20, 0x1								// test if lsb of w20 is 1
		b.eq	bitclear1								// if lsb of w20 is 0, branch to bitclear1
bitset1:	add	w22, w22, w21						// add w22 with w21, store x25 in w22


bitclear1:	// arithmetic shift right the combined w22 and w20
		asr	w20, w20, 1						// arithmetic shift right w20 by 1, storing the x25 in w20
		tst	w22, 0x1								// test if lsb of w22 is 1
		b.eq	bitclear2								// if lsb og w22 is 0, branch to bitclear2
bitset2:	orr	w20, w20, 0x80000000					// bitwise or w20 with 0x80000000, storing the x25 in w20
		b	next1									// branch to next1
bitclear2:	and	w20, w20, 0x7FFFFFFF					// bitwise and w20 with ox7FFFFFFF, storing th eresult in w20
next1:		asr	w22, w22, 1							// arithmetic shift right w22 by 1, storing the x25 back to w22


		add	w23, w23, 1									// increment w23 by 1
test:		cmp	w23, 32									// compare w23 with 32
		b.lt	start									// if w23 is less than 32, branch to start

// end of loop

		// Adjust w22 register if w20 is w24
		cmp	w24, wzr								// compare w24 with wzr
		b.eq	next2									// if w24 is equal to wzr, branch to next2
		sub	w22, w22, w21						// subtract w22 with w21, storing the x25 in w22
		
next2:
		// print out w22 and w20
		adrp 	x0, fmt2								// set first arg (high order bits)
		add	x0, x0, :lo12:fmt2							// set first arg (lower 12 bits)
		mov	w1, w22								// set w1 to be the w22
		mov	w2, w20								// set w2 to w20
		bl	printf									// call print function

		
		// combine w22 and w20 together
		sxtw	x28, w22								// typecast w22 to be a 64 bit register x28
		and	x26, x28, 0xFFFFFFFF							// bitwise and x28 with 0xFFFFFFFF, storing the x25 in x26
		lsl	x26, x26, 32							// logical shift left temp 1 by 32
		sxtw	x28, w20								// typecase w20 to a 64 bit register x28
		and	x27, x28, 0xFFFFFFFF							// bitwise and x28 with 0xFFFFFFFF, storing th eresult in x27
		add	x25, x26, x27							// bitwise and x26 with x27, storing the x25 in x25



		// print out 64 bit x25
		adrp	x0, fmt3								// set first arg (high order bits)
		add	x0, x0, :lo12:fmt3							// set first arg (lower 12 bits)
		mov	x1, x25
		mov	x2, x25
		bl	printf


		ldp	x29, x30, [sp], 16							// loads x29, x30 from RAM and deallocates 16 bytes in stack memory
		ret										// returns control to caling code (in os)
