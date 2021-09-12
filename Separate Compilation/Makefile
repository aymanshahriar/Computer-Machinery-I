all: mysum mysumnew


#For calling asm code from c code	

mysum: sum.o asmccode.o
	gcc asmccode.o sum.o -o mysum
asmccode.o: asmccode.c
	gcc -c asmccode.c
sum.o: sum.s
	as sum.s -o sum.o

	
	
mysumnew: sum1.o sum1asm.o
	gcc sum1asm.o sum1.o -o mysumnew
sum1asm.o: sum1asm.s
	as sum1asm.s -o sum1asm.o
sum1.o: sum1.c
	gcc -c sum1.c



#Remove all object files and the executable files as well	
clean: 
	rm *.o  mysum mysumnew
