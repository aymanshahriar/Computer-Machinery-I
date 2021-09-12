// File: a5aMain.c
// Author: Ayman Shahriar	UCID: 10180260
// Date: November 28, 2019





#include <stdio.h>
#include <stdlib.h>

/*  Constants (also defined in the assembly file)  */
#define MAXOP   20
#define NUMBER  '0'
#define TOOBIG  '9'
#define MAXVAL  100
#define BUFSIZE   100


/*  Function prototypes  */
int push(int f);
int pop();
void clear();
int getop(char *s, int lim);
int getch();
void ungetch(int c);

/* External Variables aka Global Variables 
 * (which are declared here, but are declared and defined in the assembly file)
 */
extern int sp_m;
extern int val_m[MAXVAL];

extern char buf_m[BUFSIZE];
extern int bufp_m;


/* The main function*/
int main()
{
  int type;
  char s[MAXOP];
  int op2;

  while ((type = getop(s, MAXOP)) != EOF) {
    switch (type) {
    case NUMBER:
      push(atoi(s));
      break;
    case '+':
      push(pop() + pop());
      break;
    case '*':
      push(pop() * pop());
      break;
    case '-':
      op2 = pop();
      push(pop() - op2);
      break;
    case '/':
      op2 = pop();
      if (op2 != 0)
	push(pop() / op2);
      else
	printf("zero divisor popped\n");
      break;
    case '=':
      printf("\n%d\n\n", push(pop()));
      break;
    case 'c':
      clear();
      break;
    case TOOBIG:
      printf("%.20s ... is too long\n", s);
      break;
    default:
      printf("unknown command %c\n", type);
      break;
    }
  }

  return 0;
}

