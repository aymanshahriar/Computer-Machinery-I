//Separate Compilation and Linking - Call C function from ASM
extern int num;				//Global variable declared in sum1asm.s

int sum(int a, int b){
num = 2*(a+b);
return a + b; 
}