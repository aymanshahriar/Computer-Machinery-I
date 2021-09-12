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

											// define d8 to be d18
										// define d9 to be d9
										// define d10 to be d10
										// define d11 to be d11
										// define w20 to be w20
										// define d12 ((x-1)/x) to be d12	
										// define d13 to be d13

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
		ldr	d8, [x29, buf_s]							// get value of x from buf
		

		//start of post test loop
		mov	w20, 1									// initialize w20 to 1
		adrp	x22, zero								// set x22 to be address of zero (high order bits)
		add	x22, x22, :lo12:zero							// set x22 to be address of zero (low 12 bits)
		ldr	d10, [x22]								// set d10 to 0.0 before the loop

		adrp	x22, one            							// set x22 to be address of one (high order bits)
		add	x22, x22, :lo12:one							// set x22 to be address of one (low 12 bits)
		ldr	d14, [x22]								// set d14 to be 1.0 before the loop

		fsub	d12, d8, d14							// set fraction to be (x - 1.0)
		fdiv	d12, d12, d8						// set fraction to be ((x - 1.0) / x)

top:		fmov	d0, d12								// 1st arg (fraction)
		mov	w0, w20									// 2nd arg (i)

		bl	powerDivide								// call powerDivide function
		
		fmov	d9, d0								// store result of powerDivide function in d9

		add	w20, w20, 1								// increment i

		fabs	d11, d9								// get absolute value of d9
		
		// initialize d13
		adrp	x22, min								// set high order bits of x22 to be address of min
		add	x22, x22, :lo12:min							// set low 12 bits of x22 to be address of min
		ldr	d13, [x22]								// put value at min inside register d13

		// test if the d11 is smaller than d13
test:		fcmp	d11, d13								// compare absolute value of d9 with min
		b.lt	printValues								// if d11 < min, jump to printValues
		fadd	d10, d10, d9							// else, add d9 to d10
		b	top									// branch to top of loop


printValues:	adrp	x0, fmt1								// set 1st arg (high order bits)
		add	x0, x0, :lo12:fmt1							// set 1st arg (low 12 bits)
		fmov	d0, d8									// set 2nd arg (x value)
		fmov	d1, d10								// set 3rd arg (d10, which now holds value of ln(x))
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

										// define d16 to be d16
											// define w9 to be w9

powerDivide:	fmov	d16, d0								// set d16 to be input in d0 (base)
		
		mov	w9, 2									// initialize w9 to be 2
		b	test1									// start of loop, branch to test1
		
top1:		fmul	d16, d16, d0							// d16 *= base

		add	w9, w9, 1								// w9 += 1
test1:		cmp	w9, w0									// compare w9 with the input in w0 (exponent)
		b.ls	top1									// is w9 >= exponent, continue loop. Note: we used ls instead of le because the input in w0 (exponent) is an unsigned integer
		
		scvtf	d18, w0									// convert the value in w0 into a floating point value
		fdiv	d0, d16, d18							// divide d16 with d18, store in d0 (return value)

		ret										// return control to caling code





