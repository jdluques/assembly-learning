#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main()
{
  srand(time(NULL));
  
  int number = rand() % 10 + 1;

  int guess;

  printf("Guess a number (1-10): ");
  scanf("%d", &guess);

  if (guess == number) {
    printf("You guessed correctly!\n");
  } else {
    printf("You guessed incorrectly, the correct number was %d\n", number);
  }

  return 0;
}
