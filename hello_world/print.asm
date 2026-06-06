global main
extern printf

section .data
    msg db "Hello world!", 10, 0

section .text

main:
    ; printf(format)
    mov rdi, msg
    xor eax, eax
    call printf

    xor eax, eax
    ret
