#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <string.h>
#include <time.h>

int main()
{
  // --- 1. getpid (Syscall 39): Get Process ID ---
  pid_t pid = getpid();
  printf("1. getpid: Process ID is %d\n", pid);

  // --- 2. brk (Syscall 12): Manage heap memory ---
  void *old_heap = sbrk(0); // Get current heap position
  void *new_heap = sbrk(1024); // Expand heap by 1 KB
  if (new_heap == (void *) -1) {
    fprintf(stderr, "Error incrementing heap size by 1 KB");
    return EXIT_FAILURE;
  }

  printf("2. brk: Heap expanded to %p. Old top: %p\n", new_heap + 1024, old_heap);

  // --- 3. open (Syscall 2): Create/open a file ---
  char *filepath = "demo.txt";
  int fd = open(filepath, O_RDWR | O_CREAT | O_TRUNC, 0644);
  if (fd == -1) {
    fprintf(stderr, "Error opening '%s' file\n", filepath);
    return EXIT_FAILURE;
  }

  printf("3. open: Created demo.txt (fd: %d)\n", fd);

  // --- 4. write (Syscall 1): Write to the file ---
  const char *msg = "Hello directly from the kernel memory!\n";
  for (long long total_written = 0; total_written < strlen(msg);) {
    long long num_written = write(
      fd,
      msg + total_written,
      strlen(msg) - total_written
    );
    
    if (num_written == -1) {
      if (errno == EINTR) {
        continue;
      }

      fprintf(stderr, "Error writing to '%s'\n", filepath);
      if (close(fd) == -1) {
        fprintf(stderr, "Error closing '%s'\n", filepath);
      }  
      return EXIT_FAILURE;
    }

    total_written += num_written;
  }

  printf("4. Wrote data to demo.txt\n");

  // --- 5. lseek (Syscall 8): Rewind file pointer back to byte 0 ---
  if (lseek(fd, 0, SEEK_SET) == -1) {
    fprintf(stderr, "Error setting file pointer to 0\n");
    if (close(fd) == -1) {
        fprintf(stderr, "Error closing '%s'\n", filepath);
      }
    return EXIT_FAILURE;
  }
  printf("5. lseek: Rewound file pointer to beginning\n");

  // --- 6. fstat (Syscall 5): Get file metadata ---
  struct stat st;
  int metadata = fstat(fd, &st);
  if (metadata == -1) {
    fprintf(stderr, "Error getting file metadata from '%s'\n", filepath);
    if (close(fd) == -1) {
      fprintf(stderr, "Error closing '%s'\n", filepath);
    }
    return EXIT_FAILURE;
  }
  printf("6. fstat: File size is %ld bytes\n", st.st_size);

  // --- 7. mmap (Syscall 9): Map the file contents directly into RAM ---
  char *mapped = mmap(NULL, st.st_size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
  if (mapped == nullptr) {
    fprintf(stderr, "Error mapping '%s'\n", filepath);
    if (close(fd) == -1) {
      fprintf(stderr, "Error closing '%s'\n", filepath);
    }
    return EXIT_FAILURE;
  }

  printf("7. mmap: File mapped into memoty at %p\n", mapped);

  // --- 8. mprotect (Syscall 10): Lock the memory to Read-only ---
  if (mprotect(mapped, st.st_size, PROT_READ) == -1) {
    fprintf(stderr, "Error locking the mapping of '%s' to READ-ONLY\n", filepath);
    if (close(fd) == -1) {
      fprintf(stderr, "Error closing '%s'\n", filepath);
    }
    return EXIT_FAILURE;
  }

  printf("8. mprotect: Memory locked to Read-only\n");

  printf("\n--- MAPPED DATA ---\n");
  for (long long total_written = 0; total_written < st.st_size;) {
    long long num_written = write(
      1,
      mapped + total_written,
      st.st_size - total_written
    );

    if (num_written == -1) {
      if (errno == EINTR) {
        continue;
      }

      fprintf(stderr, "Error writing to stdout\n");
      if (close(fd) == -1) {
        fprintf(stderr, "Error closing '%s'\n", filepath);
      }
      return EXIT_FAILURE;
    }

    total_written += num_written;
  }
  printf("-------------------\n\n");

  // --- 9. munmap (Syscall 11): Release the memory mapping ---
  if (munmap(mapped, st.st_size) == -1) {
    fprintf(stderr, "Error releasing memory mapping of '%s'\n", filepath);
    if (close(fd) == -1) {
      fprintf(stderr, "Error closing '%s'\n", filepath);
    }
    return EXIT_FAILURE;
  }

  printf("9. munmap: Unmapped memory\n");

  // --- 10. close (Syscall 3): Close the file ---
  if (close(fd) == -1) {
    fprintf(stderr, "Error closing '%s'\n", filepath);
    return EXIT_FAILURE;
  }
  printf("10. close: Close file descriptor\n");

  // --- 11. nanosleep (Sysacll 35): Suspend current thread ---
  struct timespec sleep_spec;
  sleep_spec.tv_sec = 1;
  sleep_spec.tv_nsec = 0;

  printf(
    "11. nanosleep: Suspending current thread for %d seconds and %d nanoseconds\n",
    sleep_spec.tv_sec, sleep_spec.tv_nsec
  );

  if (nanosleep(&sleep_spec, 0) == -1) {
    fprintf(stderr, "Error during nanosleep\n");
    return EXIT_FAILURE;
  }

  // 11. exit (Syscall 60): Terminate
  printf("12. exit: Terminating cleanly.\n");
  exit(0);
}
