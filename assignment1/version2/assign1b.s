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
					// defines x19 to be x19
					// defines x20 to be x20
					// defines x21 to be x21
					// defines x22 to be x22
					// defines x23 to be x23


    	mov	x19, -10				// before the loop begins, x19 is set to -10
	b	test					// branch instruction jumps to label test
       	
	// calculates -2(x19^3) 
top:  	mul     x20, x19, x19				// x20 stores the square of x19
        mul     x20, x20, x19			// x20 stores the product of x19 and itself
        mov     x21, -2				// x21 stores value -2
        madd	x22, x20, x21, x22			// x20 is multiplied by x21, and added to x22. 
	
	// calculates -22(x19^2)
        mul     x20, x19, x19				// x20 stores square of x
        mov     x21, -22				// x21 stores value -22
        madd	x22, x20, x21, x22			// x20 is multiplied with x21 and added to x22
        
	// calculates 11(x19)+27
        mov     x21, 11				// x21 stores value 11
	madd	x22, x19, x21, x22  			// x19 is multiplied with x21 and the result is added to x22
        add     x22, x22, 57				// the value 57 is added to y
       			
	// Make sure x23 is set to value of x22
	// int the first iteration of the loop
        cmp     x19, -10				// x19 is compared with -10 
        b.ne    br1					// if x19 != -10, then instruction jumps to br1
        mov     x23, x22				// x23 stores value at x22

	// calculates the current x23
br1:	cmp     x22, x23				// compares x22 with x23
        b.le    br2					// x22 is compared to x23. If x22 <= x23, then instruction jumps to br2
        mov     x23, x22        			// x23 stores value at x22 

	// print the values of x19, x22, x23
br2:    adrp    x0, fmt					// the first argument is set to the address of the string
        add     x0, x0, :lo12:fmt			// the first argument is now the address of the string
        mov     x1, x19 				// to print x
        mov     x2, x22 				// to print y
        mov     x3, x23 				// to print x23
        bl      printf					// function call for printf

	// clear x20, x21, x22 registers
        mov x20, 0					// clear the x20 register
        mov x21, 0					// clear the x21 register
        mov x22, 0					// clear the x22 register

        add     x19, x19, 1       			// increments x19 by 1 for the loop
test:	cmp	x19, 4					// compares x19 with 4. In this program, the loop test is at bottom
	b.le	top					// if x19 <= 4, then flow of instruction jumps to the label top (the start of the loop)


	ldp x29, x30, [sp], 16				// loads x29, x30 from RAM and deallocates 16 bytes in stack memory
        ret						// returns control to caling code (in os)

