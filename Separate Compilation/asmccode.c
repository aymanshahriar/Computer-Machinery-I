//Separate Compilation and Linking - Call ASM function from C code

#include <stdio.h>

int sum(int, int);						 // Function prototype
int main(){

int i = 5, j = 10, result;
result = sum(i, j); 
printf("result = %d\n", result); 
return 0;
}