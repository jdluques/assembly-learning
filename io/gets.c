#include <stdio.h>

int main()
{
  char buffer[100];

  if (fgets(buffer, sizeof(buffer), stdin)) {
    printf("%s", buffer);
  }

  return 0;
}
