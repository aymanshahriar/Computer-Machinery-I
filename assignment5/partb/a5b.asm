// File: assign5.asm
// Author: Ayman Shahriar	UCID: 10180260
// Date: November 24, 2019




// first of all, create an external array of pointers named month
		.text									// store all string literals of months in the text section
jan_m:		.string "January"							// store string literal "January"
feb_m:		.string "February"							// store string literal "February"
mar_m:		.string "March"								// store string literal "March"
apr_m:		.string "April"								// store string literal "April"
may_m:		.string "May"								// store string literal "May"
jun_m:		.string "June"								// store string literal "June"
jul_m:		.string "July"								// store string literal "July"
aug_m:		.string "August"							// store string literal "August"
sep_m:		.string "September"							// store string literal "September"
oct_m:		.string "October"							// store string literal "October"
nov_m:		.string "November"							// store string literal "November"
dec_m:		.string "December"							// store string literal "December"

		.data									// store the  external array of pointers in the data section
		.balign 8								// some architectures require doubleword alignment
month_m:	.dword	jan_m, feb_m, mar_m, apr_m, may_m, jun_m, jul_m, aug_m, sep_m, oct_m, nov_m, dec_m	// declare external array of pointers 



// define register names using mactos
define(argc_r, w19)									// register for holding argc
define(argv_r, x20)									// register for lolding address of argv[]
define(month_r, x21)									// register for holding month
define(day_r, x22)									// register for holding day
define(year_r, x23)									// register for holding year
define(base_r, x24)									// register for holding base address of month_m

		.text									// store string literal used to print date in text section
fmt1:		.string	"Usage:	a5b mm dd yyyy\n"					// error message
fmt2:		.string "%s %dst, %d\n"							// print date with "st" suffix for day
fmt3:           .string "%s %dnd, %d\n"							// print date with "nd" suffix for day
fmt4:           .string "%s %drd, %d\n"							// print date with "rd" suffix for day
fmt5:           .string "%s %dth, %d\n"							// print date with "th" suffix for day

// now on to the main routine
		.balign 4								// to ensure instructions are quadword aligned
		.global main								// makes label main visible to the linker
main:		stp	x29, x30, [sp, -16]!						// increment sp by 16, store x29 and x30 to stack
		mov	x29, sp								// set fp (x29) to be value of sp

		mov	argc_r, w0							// set argc_r to contain the value in w0
		mov	argv_r, x1							// set argv_r to contain the value in x1


		// check if there are 3 input values
		cmp	argc_r, 4							// compare argc_r with value 4
		b.ne	printError							// if argc_r = 4, branch to printError																			

		// get values of month, day, year
		mov	w25, 1								// set w25 to be 1
		ldr	x0, [argv_r, w25, SXTW 3]					// load 2nd command line argument (1st agument is ./assign5b)
		bl	atoi								// convert 2nd command line argument into integer
		mov	month_r, x0							// store that integer in month_r

		mov	w25, 2								// set w23 to be 2
		ldr	x0, [argv_r, w25, SXTW 3]					// load 3rd command line argument
		bl	atoi								// convert 3rd command line argument into integer
		mov	day_r, x0							// store that integer into day_r

		mov	w25, 3								// set w25 to be 3
		ldr	x0, [argv_r, w25, SXTW 3]					// load 4th command line argument
		bl	atoi								// convert 4th argument into integer
		mov	year_r, x0							// store that integer in year_r
		

		// check range of day
		cmp	day_r, 1							// compare day_r with 1
		b.lt	printError							// if day_r < 1, branch to printError
					
		cmp	day_r, 31							// compare day_r, 31
		b.gt	printError							// if day_r > 31, branch to printError


		// check range of month
		cmp	month_r, 1							// compare month_r with 1
		b.lt	printError							// if month_r < 1, branch to printError

		cmp	month_r, 12							// compare month_r with 12
		b.gt	printError							// if month_r > 12, branch to printError


		// check range of year
		cmp	year_r, 0							// compare year_r with 0
		b.lt	printError							// if year_r < 0, branch to printError


		// now decide which suffix to use for the day (st, nd, rd, th)		
		// see if we should use "st"
		cmp	day_r, 1							// compare day_r with 1
		b.eq	use_st								// if day_r = 1, use the "st" prefix
		cmp	day_r, 21							// compare day_r with 21
		b.eq	use_st								// if day_r = 21, use the "st" prefix
		cmp	day_r, 31							// compare day_r with 31
		b.eq	use_st								// if day_r = 31, use the "st" prefix

		b	next1								// branch to next1
use_st:		adrp	x0, fmt2							// set 1st arg (high order bits)
		add	x0, x0, :lo12:fmt2						// set 1st arg (low 12 bits)
		b	printdate							// branch to printdate
		

		// see if we should use "nd"
next1:		cmp	day_r, 2							// compare day_r with 2
		b.eq	use_nd								// if day_r = 2, use the "nd" prefix
		cmp	day_r, 22							// compare day_r with 22
		b.eq	use_nd								// if day_r = 22, ise the "nd" prefix

		b	next2								// branch to next2
use_nd:		adrp	x0, fmt3							// set 1st arg (high order bits)
		add	x0, x0, :lo12:fmt3						// set 2nd arg (low order bits)
		b	printdate							// branch to printdate


		// see if we should use "rd"
next2:		cmp	day_r, 3							// compare day_r with 3
		b.eq	use_rd								// if day_r = 3, use the "rd" prefix 
		cmp	day_r, 23							// compare day_r with 23
		b.eq	use_rd								// if day_r = 23, use the "rd" prefix
				
		b	next3								// branch to next3
use_rd:		adrp	x0, fmt4							// set up 1st arg (high order bits)
		add	x0, x0, :lo12:fmt4						// set up 2nd arg (low 12 bits)
		b	printdate							// branch to printdate

		
		// if not using "st", "nd", "rd", use "th"
next3:		adrp	x0, fmt5							// set up 1st arg (high order bits)
		add	x0, x0, :lo12:fmt5						// set up 1st arg (low 12 order bits)
		
		
		// print the date
printdate:	adrp	base_r, month_m							// set base_r to the address of month_m (high order bits)
		add	base_r, base_r, :lo12:month_m					// set base_r to the address of month_m (low 12 bits)
		sub	month_r, month_r, 1						// subtract month_r by 1 since array month_m starts at index 0
		ldr	x1, [base_r, month_r, lsl 3]					// set 2nd arg to be the month corresponding to month_r
		mov	x2,  day_r							// set 3rd arg to be value in day_r
		mov	x3, year_r							// set 4th arg to be value in year_r
		bl	printf								// call print function
		

		// now jump to the end of the program
		b	end								// branch to label end
	

		// if there was an error, we jump to this location and print error message
printError:	adrp    x0, fmt1							// set 1st arg (high order bits) to be fmt1
                add     x0, x0, :lo12:fmt1						// set 1st arg (low 12 bits) to be fmt1
                bl      printf								// call print function


		// end of program
end:		ldp	x29, x30, [sp], 16						// load fp and lr from stack, then decrement sp by 16
		ret									// returns control to calling code (in os)














