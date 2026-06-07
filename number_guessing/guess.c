#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main()
{
  srand(time(NULL));
  
  int number = rand() % 10 + 1;

  int guess, count = 0;

  printf("You have 10 attempts to guess the correct number\n");

  while (count++ < 10) {
    printf("(Attempt %d) Guess a number (1-10): ", count);
    if (scanf("%d", &guess) != 1) {
      return 1;
    }

    if (guess == number) {
      printf("You guessed correctly!\n");
      return 0;
    } else if (guess > number){
      printf("You guessed incorrectly, the number is lower\n");
    } else if (guess < number) {
      printf("You guessed incorrectly, the number is higher\n");
    }
  }

  printf("Game over, the correct number was %d\n", number);

  return 0;
}
