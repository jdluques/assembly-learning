#include <unistd.h>

int main()
{
  char buffer[100];

  size_t bytes_read = read(0, buffer, sizeof(buffer));

  if (bytes_read > 0) {
    write(1, buffer, bytes_read);
  }

  return 0;
}
