#include <stdlib.h>

long long fibonacci_recursive(long long n)
{
  if (n < 0) return -1;

  if (n <= 1) return n;
  return fibonacci_recursive(n-1) + fibonacci_recursive(n-2);
}

long long fibonacci_memoization_helper(long long n, int *mem)
{
  if (n <= 1) return n;
  if (mem[n] != -1) return mem[n];

  mem[n] = fibonacci_memoization_helper(n-1, mem) + fibonacci_memoization_helper(n-1, mem);
  return mem[n];
}

long long fibonacci_memoization(long long n)
{
  if (n < 0) return -1;

  int *mem = malloc(sizeof(n+1));
  for (long long i = 0; i < n+1; i++) mem[i] = -1;

  return fibonacci_memoization_helper(n, mem);
}

long long fibonacci_iterative(long long n)
{
  if (n < 0) return -1;

  int *fibNums = malloc(sizeof(n+1));
  for (long long i = 0; i < n+1; i++) fibNums[i] = -1;

  fibNums[0] = 0;
  fibNums[1] = 1;

  for (long long i = 2; i < n+1; i++) {
    fibNums[i] = fibNums[i-1] + fibNums[i-2];
  }

  return fibNums[n];
}

long long fibonacci_iterative_optimized(long long n)
{
  if (n < 0) return -1;

  if (n <= 1) return n;

  long long n_2 = 0, n_1 = 1;
  for (long long i = 2; i <= n; i++) {
    long long tmp = n_1;
    n_1 = n_1 + n_2;
    n_2 = tmp;
  }

  return n_1;
}

void matrix_multiplication(long long A[2][2], long long B[2][2])
{
  long long x = A[0][0] * B[0][0] + A[0][1] * B[1][0];
  long long y = A[0][0] * B[0][1] + A[0][1] * B[1][1];
  long long z = A[1][0] * B[0][0] + A[1][1] * B[1][0];
  long long w = A[1][0] * B[0][1] + A[1][1] * B[1][1];

  A[0][0] = x;
  A[0][1] = y;
  A[1][0] = z;
  A[1][1] = w;
}

long long fibonacci_exponentiation(long long n)
{
  if (n < 0) return -1;

  if (n <= 1) return n;

  long long F[2][2]   = {{1, 1}, {1, 0}};
  long long res[2][2] = {{1, 0}, {0, 1}};

  for (; n; n >>= 1) {
    if (n % 2 == 0) matrix_multiplication(res, F);
    matrix_multiplication(F, F);
  }

  return F[0][0];
}
