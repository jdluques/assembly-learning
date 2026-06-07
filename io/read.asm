section .bss
    buffer resb 100

section .text
    global _start

_start:
    ; read(fd, buffer, len)
    mov rax, 0      ; syscall number for read
    mov rdi, 0      ; stdin -> 0
    mov rsi, buffer
    mov rdx, 100
    syscall

    ; rax contains number of bytes read

    ; if (bytes_read > 0)
    cmp rax, 1
    jb  exit

    ; write(fd, buffer, byte_count)
    mov rdx, rax
    mov rax, 1      ; syscall number for write
    mov rdi, 1      ; stdout -> 1
    mov rsi, buffer
    syscall

exit:
    ; exit(0)
    mov rax, 60     ; syscall number for exit
    xor rdi, rdi
    syscall
