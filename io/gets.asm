global main
extern fgets
extern printf
extern stdin

section .data
    format db "%s", 0

section .bss
    buffer resb 100

section .text

main:
    ; fgets(buffer, len, fd)
    mov rdi, buffer
    mov rsi, 100
    mov rdx, [rel stdin]
    call fgets

    ; if (fgets...)
    test rax, rax
    jz exit

    ; printf(format, args...)
    mov rdi, format
    mov rsi, buffer
    xor eax, eax
    call printf

exit:
    xor eax, eax
    ret
