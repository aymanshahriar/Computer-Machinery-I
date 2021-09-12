// File: assign4.asm
// Author: Ayman Shahriar	UCID: 10180260
// Date: December 4, 2019




min:		.double	0r1.0e-13								// allocate and initialize the fp constant 1.0e-13
one:		.double	0r1.0									// allocate and initialize the fp constant 1.0
zero:		.double 0r0.0									// allocate and initialize the fp constant 0.0

fmt1:		.string "x = %10.10f		ln(x) = %.10f \n"				// column headings
fmt2:		.string "\n\nValue of x:			ln(x): \n\n"			// display values of x and ln(x)
error_msg1:	.string "Error opening file: %s. Program aborted. \n"				// error message when cannot open file
error_msg2:	.string "Error closing the file: %s. Perhaps the file is already closed \n"	// error message when cannot close file

define(x_r, d8)											// define x_r to be d18
define(term, d9)										// define term to be d9
define(total, d10)										// define total to be d10
define(abs_term, d11)										// define abs_term to be d11
define(i_r, w20)										// define i_r to be w20
define(fraction_r, d12)										// define fraction_r ((x-1)/x) to be d12	
define(min_r, d13)										// define min_r to be d13

		buf_size = 8									// set size of buffer to be 8 (read 8 bytes at a time)
		alloc = -(16 + buf_size) & -16							// used to increment fp at start of main
		dealloc = -alloc								// used to decrement fp at end of main
		buf_s = 16

		.balign 4									// to ensure instructions are word aligned
		.global main									// makes label main visible to linker
main:		stp	x29, x30, [sp, alloc]!							// increment sp, then store fp and lr 
		mov	x29, sp									// set fp to be value of sp

		mov	w19, 1									// set w19 to be 1
		ldr	x20, [x1, w19, SXTW 3]       						// load address of argv[1] to x20 (argv[0] is ./a6)
		
		// name of file is now in x20
		// now open the file
		mov	w0, -100								// 1st arg (use cwd)
		mov	x1, x20									// 2nd arg (pathname)
				
		mov	w2, 0									// 3rd arg (read only)
		mov	w3, 0									// 4th arg (not used)
		
		mov	x8, 56									// openat I/O request
		svc	0									// call system function

		mov	w19, w0									// move file descriptor to w19
		cmp	w19, 0									// compare fd with 0
		b.ge	open_works								// if file descriptor is posiive there was no error
		
		// if error opening file, print error message
		adrp	x0, error_msg1								// else, print error message, load 1st arg 
		add	x0, x0, :lo12:error_msg1						// 1st arg (high order bits)
		mov	x1, x20									// 2nd arg (name of file)
		bl	printf									// call print function
		
		// return -1, exit the program
		mov w0, -1 									// return -1 
		b exit										// exit the program


open_works:	// print column headers		
		adrp	x0, fmt2								// load 1st arg (high order bits)
		add	x0, x0, :lo12:fmt2							// load 1st arg (low order bits)
		bl	printf									// call print function


		// file is open, fd is in w19, use it to read the floating point 
		// numbers (so each is 8 bytes) in binary file
read:		mov	w0, w19									// 1st arg (fd)
		add	x1, x29, buf_s								// 2nd arg (pointer to buf)
		
		mov	x2, 8									// 3rd arg (number of bytes to read, known as n)
		mov	x8, 63									// read I/O request
		svc	0									// call sys function

		cmp	x0, 8									// check if bytes read is different from n
		b.lt	end									// if bytes read is different from n, end program


		// floating point number x is at address [x29, buf_s], calculate ln(x)		
		ldr	x_r, [x29, buf_s]							// get value of x from buf
		

		//start of post test loop
		mov	i_r, 1									// initialize i_r to 1
		adrp	x22, zero								// set x22 to be address of zero (high order bits)
		add	x22, x22, :lo12:zero							// set x22 to be address of zero (low 12 bits)
		ldr	total, [x22]								// set total to 0.0 before the loop

		adrp	x22, one            							// set x22 to be address of one (high order bits)
		add	x22, x22, :lo12:one							// set x22 to be address of one (low 12 bits)
		ldr	d14, [x22]								// set d14 to be 1.0 before the loop

		fsub	fraction_r, x_r, d14							// set fraction to be (x - 1.0)
		fdiv	fraction_r, fraction_r, x_r						// set fraction to be ((x - 1.0) / x)

top:		fmov	d0, fraction_r								// 1st arg (fraction)
		mov	w0, i_r									// 2nd arg (i)

		bl	powerDivide								// call powerDivide function
		
		fmov	term, d0								// store result of powerDivide function in term

		add	i_r, i_r, 1								// increment i

		fabs	abs_term, term								// get absolute value of term
		
		// initialize min_r
		adrp	x22, min								// set high order bits of x22 to be address of min
		add	x22, x22, :lo12:min							// set low 12 bits of x22 to be address of min
		ldr	min_r, [x22]								// put value at min inside register min_r

		// test if the abs_term is smaller than min_r
test:		fcmp	abs_term, min_r								// compare absolute value of term with min
		b.lt	printValues								// if abs_term < min, jump to printValues
		fadd	total, total, term							// else, add term to total
		b	top									// branch to top of loop


printValues:	adrp	x0, fmt1								// set 1st arg (high order bits)
		add	x0, x0, :lo12:fmt1							// set 1st arg (low 12 bits)
		fmov	d0, x_r									// set 2nd arg (x value)
		fmov	d1, total								// set 3rd arg (total, which now holds value of ln(x))
		bl	printf									// call print function

		b	read									// to read another fp number from the file, branch to read

		// close file
end:		mov	w0, w19									// 1st arg (fd, the file descriptor)
		mov	x8, 57									// close I/O request
		svc 	0									// call sys function
		cmp	w0, -1									// check if status is -1
		b.ne	close_ok								// if status is not -1, then file closed properly
		
		adrp	x0, error_msg2								// otherwise, print error message. 1st arg
		add	x0, x0, :lo12:error_msg2					 	// 1st arg (low 12 bits)
		mov	x1, x20									// 2nd arg (name of file)
		bl	printf									// call print function


close_ok:	ldp	x29, x30, [sp], dealloc							// deallocate sp, load fp, lr from stack fram
		ret										// return control to caling code (in os)
			




// Now we create the powerDivide subroutine.
// Since this is a leaf subroutine, there is no need for stp, ldp

define(value_r, d16)										// define value_r to be d16
define(j_r, w9)											// define j_r to be w9

powerDivide:	fmov	value_r, d0								// set value_r to be input in d0 (base)
		
		mov	j_r, 2									// initialize j_r to be 2
		b	test1									// start of loop, branch to test1
		
top1:		fmul	value_r, value_r, d0							// value_r *= base

		add	j_r, j_r, 1								// j_r += 1
test1:		cmp	j_r, w0									// compare j_r with the input in w0 (exponent)
		b.ls	top1									// is j_r >= exponent, continue loop. Note: we used ls instead of le because the input in w0 (exponent) is an unsigned integer
		
		scvtf	d18, w0									// convert the value in w0 into a floating point value
		fdiv	d0, value_r, d18							// divide value_r with d18, store in d0 (return value)

		ret										// return control to caling code





