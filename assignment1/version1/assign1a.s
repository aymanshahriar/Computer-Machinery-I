// File: assign1a.s
// Author: Ayman Shahriar	UCID 10180260
// Date: September 26, 2019
// Description:
// This is the version 1 program for assignment 1. 
// Thisprogram uses a pre-test loop, where the test is at the top of the loop



fmt: 	.string "x = %d, y = %d, current max = %d\n"		// creates the format string
	.balign 4						// ensures instructions are properly aligned
        .global main						// makes label "main visible to the linker"

main:   stp     x29, x30, [sp,-16]!				// stores contents of x29, x30 to stack and allocates 16 bytes in stack memory
        mov     x29, sp						// updates FP (x29) to the current sp

	// start of while loop
        mov     x19, -10        				// we will use the x19 register to hold x, whose initial value is -10
test:   cmp     x19, 4          				// loop will run while x <= 4
        b.gt    done            				// when x > 4, then the loop will exited by jumping to the label "done"


        // the calculations for the assignment
        // for -2(x^3)
        mul     x20, x19, x19   				// x20 = x19 * x19
        mul     x20, x20, x19   				// x20 = x20 * x19
        mov     x21, -2         				// x21 = -2
        mul     x20, x20, x21   				// x20 = x20 * x21
        add     x22, x22, x20   				// x22 = x22 * x20

        // for -22(x^2)
        mul     x20, x19, x19   				// x20 = x19 * x19
        mov     x21, -22        				// x21 = -22
        mul     x20, x20, x21   				// x20 = x20 * x21
        add     x22, x22, x20   				// x22 = x22 + x20

        // for 11(x)
        mov     x20, x19        				// x20 = x19
        mov     x21, 11         				// x21 = 11

        mul     x20, x20, x21   				// x20 = x20 * x21
        add     x22, x22, x20   				// x22 = x22 + x20

        // for 57
        add     x22, x22, 57    				// x22 = x22 + 57


        // in the first iteration set max to be y
        cmp     x19, -10        				// compares if x19 with -10
        b.ne    br1             				// if value at x19 is not equal -10, jump to label br1
        mov     x23, x22        				// x23 = x22


        // calculate current max
br1:    cmp     x22, x23        				// compares x22 with x23
        b.le    br2             				// if b22 <= x23, then jump to label br3
        mov     x23, x22        				// x23 = x22    


        // part of print
br2:    adrp    x0, fmt
        add     x0, x0, :lo12:fmt
        mov     x1, x19         				// to print x
        mov     x2, x22         				// to print y
        mov     x3, x23         				// to print max
        bl      printf          				// branch statement that jumps to printf


        // clear the temp, temp2 register and y register
        mov x20, 0						// clear x20 register
        mov x21, 0						// clear x21 register
        mov x22, 0						// clear x22 register


        add     x19, x19, 1       				//increments x++ for the loop
        b       test


// while loop ends with "done:"
done:   ldp x29, x30, [sp], 16					// loads x29, x30 from RAM, deallocates 16 bytes in stack memory
        ret							// returns control to calling code (in os)


