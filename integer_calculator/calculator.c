#include <stdio.h>

int main()
{
  int a, b;
  char op;

  printf("Enter expression: ");
  scanf("%d %c %d", &a, &op, &b);

  int result;

  switch (op) {
    case '+':
      result = a + b;
      break;
    case '-':
      result = a - b;
      break;
    case '*':
      result = a * b;
      break;
    case '/':
      if (b == 0) {
        printf("Can't divide by zero\n");
        return 1;
      }
      result = a / b;
      break;
    default:
      printf("Unknown operator\n");
      return 1;
  }

  printf("Result = %d\n", result);

  return 0;
}
