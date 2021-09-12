// File: assign1a.s
// Author: Ayman Shahriar       UCID 10180260
// Date: September 26, 2019
// Description:
// This program is the version 2 program for assignment 1
// This program uses a pre-test loop, where the test is at the bottom of the loop


fmt: 	.string "x = %d, y = %d, current max = %d\n"  	// creates the format string

     	.balign 4					// Ensures instructions are properly aligned
       	.global main					// makes the label "main" visible to the linker
main: 	stp     x29, x30, [sp,-16]!			// Stores contents of x29, sp to the stack and allocates 16 bytes in stack memory
        mov     x29, sp					// Updates x29 to the current sp

// macro definitions
define(x_r, x19)					// defines x_r to be x19
define(temp1, x20)					// defines temp1 to be x20
define(temp2, x21)					// defines temp2 to be x21
define(y_r, x22)					// defines y_r to be x22
define(max, x23)					// defines max to be x23


    	mov	x_r, -10				// before the loop begins, x_r is set to -10
	b	test					// branch instruction jumps to label test
       	
	// calculates -2(x_r^3) 
top:  	mul     temp1, x_r, x_r				// temp1 stores the square of x_r
        mul     temp1, temp1, x_r			// temp1 stores the product of x_r and itself
        mov     temp2, -2				// temp2 stores value -2
        madd	y_r, temp1, temp2, y_r			// temp1 is multiplied by temp2, and added to y_r. 
	
	// calculates -22(x_r^2)
        mul     temp1, x_r, x_r				// temp1 stores square of x
        mov     temp2, -22				// temp2 stores value -22
        madd	y_r, temp1, temp2, y_r			// temp1 is multiplied with temp2 and added to y_r
        
	// calculates 11(x_r)+27
        mov     temp2, 11				// temp2 stores value 11
	madd	y_r, x_r, temp2, y_r  			// x_r is multiplied with temp2 and the result is added to y_r
        add     y_r, y_r, 57				// the value 57 is added to y
       			
	// Make sure max is set to value of y_r
	// int the first iteration of the loop
        cmp     x_r, -10				// x_r is compared with -10 
        b.ne    br1					// if x_r != -10, then instruction jumps to br1
        mov     max, y_r				// max stores value at y_r

	// calculates the current max
br1:	cmp     y_r, x23				// compares y_r with x23
        b.le    br2					// y_r is compared to x23. If y_r <= x23, then instruction jumps to br2
        mov     max, y_r        			// max stores value at y_r 

	// print the values of x_r, y_r, max
br2:    adrp    x0, fmt					// the first argument is set to the address of the string
        add     x0, x0, :lo12:fmt			// the first argument is now the address of the string
        mov     x1, x_r 				// to print x
        mov     x2, y_r 				// to print y
        mov     x3, max 				// to print max
        bl      printf					// function call for printf

	// clear temp1, temp2, y_r registers
        mov temp1, 0					// clear the temp1 register
        mov temp2, 0					// clear the temp2 register
        mov y_r, 0					// clear the y_r register

        add     x_r, x_r, 1       			// increments x_r by 1 for the loop
test:	cmp	x_r, 4					// compares x_r with 4. In this program, the loop test is at bottom
	b.le	top					// if x_r <= 4, then flow of instruction jumps to the label top (the start of the loop)


	ldp x29, x30, [sp], 16				// loads x29, x30 from RAM and deallocates 16 bytes in stack memory
        ret						// returns control to caling code (in os)

