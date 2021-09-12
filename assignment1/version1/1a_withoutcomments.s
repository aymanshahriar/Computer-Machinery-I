// NAME: Ayman Shahriar	      UCID: 10180260     


// part of print

fmt: .string "x = %d, y = %d, current max = %d\n"
        .balign 4

        .global main
main:   stp     x29, x30, [sp,-16]!
        mov     x29, sp

// start of while loop
        mov     x19, -10        // x starts at 0
test:   cmp     x19, 4       //   loop will run while x <= 4
        b.gt    done            // note the complement of the condition

	
	// the calculations for the assignment
	// for -2(x^3)
	mul	x20, x19, x19	
	mul	x20, x20, x19
	
	mov 	x21, -2
	mul	x20, x20, x21
	add	x22, x22, x20	
	
	// for -22(x^2)
	mul 	x20, x19, x19
	mov	x21, -22
	mul	x20, x20, x21
	add	x22, x22, x20

	// for 11(x)
	mov	x20, x19
	mov	x21, 11
	mul	x20, x20, x21
	add	x22, x22, x20

	// for 57
	add	x22, x22, 57
	
	// in the first iteration set max to be y
	cmp	x19, -10
	b.ne	moveOn1
	mov	x23, x22
 


	// calculate current max
moveOn1:cmp	x22, x23
	b.le	moveOn2
	mov	x23, x22	// if y is more than max, then this statement is executed
moveOn2:mov	xzr, 44 	// otherwise, the above statement is skipped

        // part of print
        adrp    x0, fmt
        add     x0, x0, :lo12:fmt
        mov     x1, x19 // to print x
	mov 	x2, x22 // to print y
	mov	x3, x23 // to print max
        bl      printf

	// clear the temp, temp2 register and y register
        mov x20, 0
        mov x21, 0
	mov x22, 0
	

        add     x19, x19, 1       //increments x++ for while loop
        b       test
// while loop ends with "done:"
done:   ldp x29, x30, [sp], 16
        ret

