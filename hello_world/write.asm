section .data
    msg db "Hello world!", 10
    len equ $ - msg

section .text
    global _start

_start:
  ; write(fd, buffer, len)
  mov rax, 1    ; syscall number for write
  mov rdi, 1    ; stdout -> 1
  mov rsi, msg  ; pointer to message
  mov rdx, len  ; message length
  syscall

  mov rax, 60   ; syscall number for exit
  xor rdi, rdi  ; status code 0
  syscall
