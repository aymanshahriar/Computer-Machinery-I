// File: assign4.asm
// Author: Ayman Shahriar	UCID: 10180260
// Date: November 6, 2019



// format strings
fmt1:		.string "error: stack full\n"				// format string for push subroutine
fmt2:           .string "error: stack empty\n"                          // format string for pop subroutine
fmt3:		.string	"ungetch: too many characters\n"		// format string for ungetch subroutine


// define constants using assembler equates
		MAXOP = 20						// define MAXOP to be 20
		NUMBER = '0'						// define NUMBER to be the ascii code of '0'
		TOOBIG = '9'						// define TOOBIG to be the ascii code foe '9'

		MAXVAL = 100						// define MAXVAL to be 100
		BUFSIZE = 100						// define BUFSIZE to be 100

// now define the global variable sp in the data section
		.data							// What follows will be stored in the data section
		.global	sp_m						// make variable sp_m available to other compilation units
sp_m:		.word	0						// allocate and initialize sp_m to 0

		.global	bufp_m						// make variable bufp_m available to other compilation units
bufp_m:		.word 	0						// allocate and initialize bufp_m to 0

// now define the global variable val[MAXVAL] in the bss section
		.bss							// What follows will be stored in the bss section
		.global	val_m						// make variable val_m[] available to other compilation units
val_m:		.skip	4*MAXVAL					// allocate 4*MAXVAL bytes for val_m[]
		
		.global	buf_m 						// make variable buf_m[] available to other compilation units 
buf_m:		.skip	1*BUFSIZE					// allocate 1*BUFSIZE bytes for buf_m[]


		.text							// what follows will go into the text section of program memory
		.balign 4						// ensure instructions are word aligned



// create the clear subroutine
// clear is a leaf subroutine, so no need for stp/ldp instructions
		.global clear						// make subroutine clear available to other compilation units
clear:		adrp	x9, sp_m					// store address of sp_m in x9 (high order bits)
		add	x9, x9, :lo12:sp_m				// store address of sp_m in x9 (low 12 bits)
		str	wzr, [x9]					// set sp_m to be 0
		ret							// return control to calling code



// create the push subroutine
		.global push						// make subroutine push available to other compilation units
push:		stp	x29, x30, [sp, -16]!				// increment sp, then store fp and lr
		mov	x29, sp						// change value of fp to sp
		
		// note: w0 = f
		// get address of val_m into x9
		adrp	x9, val_m					// store address of val_m into x9 (high order bits)
		add	x9, x9, :lo12:val_m				// store address of val_m into x9 (low 12 bits)

		// get value of sp_m into w11
		adrp	x10, sp_m					// store address of sp_m into x10 (high order bits)
		add	x10, x10, :lo12:sp_m				// store address of sp_m into x10 (low 12 bits)
		ldr	w11, [x10]					// w11 contains value of sp_m

		cmp     w11, MAXVAL					// compare w11 with MAXVAL
                b.ge    else1						// if w11 >= MAXVAL, branch to else1

		str	w0, [x9, w11, SXTW 2]				// set val_m[sp_m] = w0

		// increment sp_m			
		add	w11, w11, 1					// add 1 to sp_m
		str	w11, [x10]					// update the value of sp_m in program memory
	
		b	end1						// branch to end1

else1:		adrp	x0, fmt1					// set 1st arg (high order bits)
		add	x0, x0, :lo12:fmt1				// set 1st arg (low 12 bits)
		bl	printf						// call the print function
		bl	clear						// call the clear function
		mov	x0, 0						// set x0 to be 0

end1:		ldp	x29, x30, [sp], 16				// load fp and lr, then decrement sp
		ret							// return control to calling code

		

// create the pop subroutine
		.global pop						// make subroutine pop available to other compilation units
pop:		stp 	x29, x30, [sp, -16]!				// increment sp, then store fp and lr
		mov	x29, sp

		adrp	x9, val_m					// store address of val_m[] in x9 (high order bits)
		add	x9, x9, :lo12:val_m				// store address of val_m[] in x9 (low 12 order bits)

		adrp	x10, sp_m					// store address of sp_m in x10 (high order bits)
		add	x10, x10, :lo12:sp_m				// store address of sp_m in x10 (low 12 order bits)
		ldr	w11, [x10]					// set w11 to be the value of sp_m

		cmp	w11, 0						// compare wll with 0
		b.le	else2						// if w11 <= 0, branch to else2
	
		sub	w11, w11, 1					// decrement sp_m by 1
		str	w11, [x10]					// update value of sp_m in program memory

		ldr	w0, [x9, w11, SXTW 2]				// set w0 (return value) to be val_m[sp_m]
		b	end2						// branch to end2

else2:		adrp	x0, fmt2					// set 1st arg (high order bits)
		add	x0, x0, :lo12:fmt2				// set 1st arg (low 12 order bits)
		bl	printf						// call print function
		bl	clear						// call clear function
		
		mov	x0, xzr						// set w0 (return value) to be 0
		
end2:		ldp	x29, x30, [sp], 16				// load fp and lr, then decrement sp
		ret							// return control to calling code



// create the getch subroutine
		.global	getch						// make subroutine getch available to other compilation units
getch:		stp	x29, x30, [sp, -16]!				// set value of fp to be sp
		mov	x29, sp

		adrp	x9, bufp_m					// store address of bufp_m in x9 (high order bits)
		add	x9, x9, :lo12:bufp_m				// store address of bufp_m in x10 (low 12 bits)

		ldr	w10, [x9]					// set w10 to contain value of bufp_m

		cmp	w10, 0						// compare w10 with 0
		b.le	else3						// if w10 <= 0, branch to else3

		
		sub	w10, w10, 1					// decrement bufp_m by 1
		str	w10, [x9]					// update value of bufp_m in program memory

		adrp	x11, buf_m					// store address of buf_m in x11 (high order bits)
		add	x11, x11, :lo12:buf_m				// store address of buf_m in x11 (low 12 bits)
		ldrb	w0, [x11, w10, SXTW]				// set w0 (return value) to be buf_m[bufp_m]
		b	end3						// branch to end3

else3:		bl	getchar						// call getchar, it's result will be in w0, as needed

end3:		ldp	x29, x30, [sp], 16				// load fp and lr, then decrement sp
		ret							// return control to calling code



// create the ungetch subroutine
		.global ungetch						// makes subroutine ungetch available to other conpilation units
ungetch:	stp	x29, x30, [sp, -16]!				// increment sp, then store fp and lr
		mov	x29, sp						// set fp to be the value of sp

		adrp	x9, bufp_m					// store address of bufp_m in x9 (high order bits)
		add	x9, x9, :lo12:bufp_m				// store address of bufp_m in x9 (low 12 bits)

		ldr	w10, [x9]					// store value of bufp_m in w10

		adrp	x11, buf_m					// store address of buf_m[] in x11 (high order bits)
		add	x11, x11, :lo12:buf_m				// store address of buf_m in x11 (low 12 bits)

		cmp	w10, BUFSIZE					// compare w10 with BUFSIZE
		b.le	else4						// if w10 <= BUFSIZE, branch to else4

		adrp	x0, fmt3					// set 1st arg (high order bits)
		add	x0, x0, :lo12:fmt3				// set 1st arg (low 12 order bits)
		bl	printf						// call the print function
		b	end4						// branch to end4

else4:		str	w0, [x11, w10, SXTW 2]				// set w0 (return value) to be buf_m[bufp_m]
		
		add	w10, w10, 1					// increment bufp_m by 1
		str	w10, [x9]					// update value of bufp_m in program memory

end4:		ldp	x29, x30, [sp], 16
		ret



// create the getop subroutine
i_size = 4								// set i_size to be 4
c_size = 4								// set c_size to be 4
x19_size = 8								// set x19_size to be 8
w20_size = 4								// set w20_size to be 4
alloc = -(16 + i_size + c_size + x19_size + w20_size) & - 16		// used to increment sp at the start of getop
dealloc = -alloc							// used to decrement sp at the start of getop

i_s = 16								// set offset of i to be 16
c_s = 16 + i_size							// set offset of c to be 20
x19_save = c_s + c_size							// store contents of x19 at this offset
w20_save = x19_save + x19_size						// store contents of w20 at this offset

		.global	getop						// makes subroutine getop available to other compilation modules
getop:		stp	x29, x30, [sp, alloc]!				// increment sp, store fp and lr
		mov	x29, sp						// set fp to be the value of sp

		str	x19, [x29, x19_save]				// save contents of x19 to stack
		str	w20, [x29, w20_save]				// save contents of w20 to stack
		
		mov	x19, x0						// set x19 to be value of x0 (which contains a pointer to a string named s)
		mov	w20, w1						// set w20 to be value of w1 (which contains an int named lim)


// the while loop
top1:		bl	getch						// call the getch function
		str	w0, [x29, c_s]					// store the result of the getch function in c

		cmp	w0, ' '						// compare w0 with ascii character ' '
		b.eq	top1						// if w0 = ' ', branch to top1
		cmp	w0, '\t'					// compare w0 wiht '\t'
		b.eq	top1						// if w0 = 'lt', branch to top1
		cmp	w0, '\n'					// compare w0 with '\n'
		b.eq	top1						// if w0 = '\n', branch to top1


// first if statement
		ldr	w0, [x29, c_s]					// load value of c in w0
		cmp	w0, '0'						// compare w0 with '0'
		b.lt	end5						// if w0 < '0', branch to end5, with w0 = c being returned
		cmp	w0, '9'						// compare w0 with '9'
		b.gt	end5						// if w0 > '9', brancht to end5, wiht w0 = c being returned


// set s[0] = c
		ldr	w0, [x29, c_s]					// load value of c into w0
		strb	w0, [x19]					// set the first character of string s to be c (s[0] = c)


// for loop, let w11 represent i					
		mov	w11, 1						// set i to be 1
		str	w11, [x29, i_s]					// update i in stack
		b	test1						// branch to test

top:		ldr	w11, [x29, i_s]					// load value of i in w11
		cmp	w11, w20					// compare i with lim (which is stored in w20)
		b.ge	next1						// if i >= lim, branch to next1
		
		ldr	w12, [x29, c_s]					// load value of c in w12
		strb	w12, [x19, w11, SXTW]				// set s[i] to be c

next1:		add	w11, w11, 1					// increment i by 1
		str	w11, [x29, i_s]					// save updated i to stack
		
test1:		bl	getchar						// call getchar function
		str	w0, [x29, c_s]					// store c in w0
		cmp	w0, '0'						// compare w0 with '0'
		b.lt	endloop1					// if w0 < '0', branch to endloop1
		cmp	w0, '9'						// compare w0 with '9'
		b.gt	endloop1					// if w0 > '9', branch to endloop1
		b	top						// branch to top


// second if statement
endloop1:	
		ldr	w11, [x29, i_s]					// load i into w11
		cmp	w11, w20					// compare w11 with w20 (lim)
		b.ge	else5						// if w11 >= lim, branch to else5

		ldr	w0, [x29, c_s]					// load c into w0
		bl	ungetch						// call ungetch function

		mov	w13, 0x0					// mov 0x0 into w13
		ldr	w11, [x29, i_s]					// load value of i in w11
		strb	w13, [x19, w11, SXTW]   			// store low byte of w13 into s[i]
		
		mov	x0, NUMBER					// mov NUMBER into x0
		b	end5						// branch to end5

else5:		b	test2						// branch to test2

top3:		bl	getchar						// call the getchar function
		str	w0, [x29, c_s]					// store result of getchar into c
		
test2:		ldr	w11, [x29, c_s]					// load c into w11
		cmp	w11, 0x0A					// compare c with 0x0A
		b.eq	endloop2					// if w11 = 0x0A, branch to endloop2
		cmp	w11, -1						// compare w11 with -1
		b.ne	top3						// if w11 != -1, branch to top3

endloop2:	mov	w9, w20						// set w9 to be lim
		sub	w9, w9, 1					// decrement w9 by 1
		
		mov	w10, 0x0					// set w10 to be 0x0
		strb	w10, [x19, w9, SXTW]				// set s[lim-1] to be 0x0

		mov	x0, TOOBIG					// set x0 (the return value) to be TOOBIG


end5:		ldr	x19, [x29, x19_save]				// restore contents of x19
		ldr	w20, [x29, w20_save]				// restore contents of w20

		ldp	x29, x30, [sp], dealloc				// load fp and lr, then decrement sp
		ret							// return control to calling code
		
































