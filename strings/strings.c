size_t strlen(const char *s)
{
  size_t len = 0;

  while (s[len] != '\0')
    len++;

  return len;
}

char *strcpy(char  *dst, const char *src)
{
  chat *ret = dst;

  while (*src) {
    *dst = *src;
    dst++;
    src++;
  }

  *dst = 0;

  return ret;
}

int strcmp(const char *a, const char *b)
{
  while (*a && *a == *b) {
    a++;
    b++;
  }

  return (unsigned char)*a - (unsigned char)*b;
}

void reverse(char *s)
{
  int i = 0;
  int j = strlen(s) - 1;

  while (i < j) {
    char tmp = s[i];
    s[i] = s[j];
    s[j] = tmp;

    i++;
    j--;
  }
}
