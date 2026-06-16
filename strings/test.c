#include <stdio.h>
#include <string.h>

size_t strlen(const char *s);
char *strcpy(char *dst, const char *src);
int strcmp(const char *a, const char *b);
void reverse(char *s);

int main(void)
{
    char buf[100];

    printf("strlen(\"hello\") = %zu\n",
           strlen("hello"));

    strcpy(buf, "abcdef");
    printf("strcpy -> \"%s\"\n", buf);

    printf("strcmp(\"abc\",\"abc\") = %d\n",
           strcmp("abc","abc"));

    printf("strcmp(\"abc\",\"abd\") = %d\n",
           strcmp("abc","abd"));

    printf("strcmp(\"abd\",\"abc\") = %d\n",
           strcmp("abd","abc"));

    strcpy(buf, "abcdef");
    reverse(buf);
    printf("reverse(\"abcdef\") -> \"%s\"\n", buf);

    strcpy(buf, "");
    reverse(buf);
    printf("reverse(\"\") -> \"%s\"\n", buf);

    return 0;
}
