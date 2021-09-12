// File: assign3.asm
// Author: Ayman Shahriar	UCID: 10180260
// Date: October 22, 2019




// format strings
fmt1:		.string "v[%d]: %d\n"								// string format wor printing array elements
fmt2: 		.string "\nSorted array:\n"							// string fomat for printing "Sorted array:"

// use assembler equates to define size of local variables
SIZE = 50											// this is the size of the array
i_size = 4											// size of i is 4 bytes
j_size = 4											// size of j is 4 bytes
min_size = 4											// size of min is 4 bytes
temp_size = 4											// size of temp is 4 bytes
v_size = SIZE*4											// size of array v is 50*4 = 200 bytes

// calculate total memory needed for the frame record plus all the stack variables
alloc = -(16 + i_size + j_size + min_size + temp_size + v_size) & -16				// used to increment the sp at the start of the program
dealloc = -alloc										// used to decrement the sp at the end of the program

// use assembler equates to define the offsets of local variables
i_s = 16											// offset of i is 16
j_s = 16 + i_size										// offset of j is 20
min_s = j_s + j_size										// offset of min is 24				
temp_s = min_s + min_size									// offset of temp is 28
v_s = temp_s + temp_size									// offset of array v is 32


// use register equates and m4 macros to define register aliases
fp .req x29											// rename x29 to fp
lr .req x30											// rename x30 to lr

										// register for holding i
										// register for holding j
										// register for holding w21
										// register for holding w22
										// for holding an element of v
										// x24 = (x29 + v_s), must be an x register
										// for holding v[w21]


		.balign 4									// ensures instructions are properly aligned
		.global main									// maekes label main visible to the linker

main:		stp	fp, lr, [sp, alloc]!							// increment sp, then store fp and lr
		mov 	fp, sp									// change value of fp to sp



// initialize array to random positive integers, mod 256
		mov	w19, 0									// initialize i to 0
		str	w19, [fp, i_s]								// save new value of i
		
		b 	test1									// start of loop: branch to test1
	
top1:		bl	rand 									// call rand() function, result is stored in w0
		and	w23, w0, 0xFF								// mod the result with 256
		
		ldr	w19, [fp, i_s]								// load current i
		add	x24, fp, v_s								// x24 = x29 + v_s
		str	w23, [x24, w19, SXTW 2]						// address of ith element = (x29+v_s) + (i*4)
		
		// print value and index just stored
		adrp	x0, fmt1								// set 1st arg (high order bits)
		add	x0, x0, :lo12:fmt1							// set 1st arg (low 12 order bits) 
		ldr	w1, [fp, i_s]								// set 2nd arg to be i
		ldr 	w2, [x24, w19, SXTW 2]							// set 3rd arg to be v[i]
		bl	printf									// call the print function
		
		// update i
		ldr	w19, [fp, i_s]								// get current i
		add	w19, w19, 1								// increment i by 1
		str	w19, [fp, i_s]								// save updated i to stack

test1:		cmp	w19, SIZE								// compare w19 with SIZE
		b.lt	top1									// if w19 < SIZE, branch to top1

	

// sort the array using selection sort
		mov	w19, 0									// initialize i to 0
		str	w19, [fp, i_s]								// store 0 value of i to stack
		
		b 	test2									// start of loop: branch to test2

top2:		ldr	w21, [fp, i_s]								// set w21 = i		
		str	w21, [fp, min_s]							// store value of w21 to stack
		

		ldr	w20, [fp, i_s]								// initialize j to i
		add	w20, w20, 1								// set j to i+1
		str	w20, [fp, j_s]								// store j to stack
		
		b 	test3									// start of loop, branch to test3
top3:		// compare elements				
	
		ldr	w23, [x24, w20, SXTW 2]						// retrieve element at v[j]
		ldr	w25, [x24, w21, SXTW 2]						// retrieve element at v[w21]
		cmp	w23, w25								// compare v[i] with v[w21]	
		b.ge	next1									// if v[i] >= v[w21], branch to next1
		str	w20, [fp, min_s]							// if v[j] < v[w21], then w21 = j
		ldr	w21, [x29, min_s]							// update w21 register	

next1:		// update j
		ldr	w20, [fp, j_s]								// get current j
		add	w20, w20, 1								// increment j by 1
		str	w20, [fp, j_s]								// save updated j to stack
test3:		cmp	w20, SIZE								// compare j with SIZE
		b.lt	top3									// if j < SIZE, then branch to top3

		// swap elements
		ldr	w25, [x24, w21, SXTW 2]						// retrieve v[w21]
		mov	w22, w25								// store w25 to w22 register
		str	w22, [x29, temp_s]							// update stack variable w22
		
		ldr	w23, [x24, w19, SXTW 2]						// retrieve v[i]
		str	w23, [x24, w21, SXTW 2]						// v[w21] = v[i]
		
		str	w22, [x24, w19, SXTW 2]						// v[i] = w22

		// update i
		ldr	w19, [fp, i_s]								// get current i
		add	w19, w19, 1								// increment i by 1
		str	w19, [fp, i_s]								// save updated i to stack

test2:		cmp	w19, SIZE-1								// compare i with SIZE-1
		b.lt	top2									// if i < SIZE-1, branch to top2



// print out sorted array	
		// first print "Sorted Array:"
		adrp 	x0, fmt2								// get 1st argument (high-order bits)
		add	x0, x0, :lo12:fmt2							// get 1st argument (low 12 bits)
		bl	printf									// call print function
		
		mov	w19, 0									// initialize i to 0
		str	w19, [fp, i_s]								// store i at this address
		b	test4									// start of loop: branch to test 4

top4:		// print value at v[i]
		adrp	x0, fmt1								// set 1st argument (high-order bits)
		add	x0, x0, :lo12:fmt1							// set 1st argument (low 12 bits)
		ldr	w19, [fp, i_s]								// get current i
		mov	w1, w19									// set 2nd argument to i
		ldr	w2, [x24, w19, SXTW 2]							// set 3rd argument to v[i]
		bl	printf									// call print function

		// update i
		ldr	w19, [fp, i_s]								// get current i
		add	w19, w19, 1								// increment i by 1
		str	w19, [fp, i_s]								// save incremented i

test4:		cmp	w19, SIZE								// compare i with size
		b.lt	top4									// if i < SIZE, branch to top4



		ldp	fp, lr, [sp], dealloc							// load fp and lr, then decrement sp
		ret										// returns control to calling code (in os)


