global main

extern printf
extern scanf

section .data
    prompt_msg    db "Enter expression: ", 0
    exp_format    db "%d %c %d"
    unknown_msg   db "Unknown operator", 10, 0
    result_msg    db "Result = %d", 10, 0
    zero_div_msg  db "Can't divide by zero", 10, 0

section .bss
    a   resd 1
    b   resd 1
    op  resb 1

section .text

main:
    ; printf(prompt_msg)
    mov rdi, prompt_msg
    xor eax, eax
    call printf

    ; scanf(%d %c %d, &a, &op, &n)
    mov rdi, exp_format
    lea rsi, [rel a]
    lea rdx, [rel op]
    lea rcx, [rel b]

    xor eax, eax
    call scanf

    ; eax = a, ebx = b, cl (lower 8 bits of rdx) = op
    mov eax, [rel a]
    mov ebx, [rel b]
    mov cl, [rel op]

    cmp cl, '+'
    je do_add

    cmp cl, '-'
    je do_sub

    cmp cl, '*'
    je do_mul

    cmp cl, '/'
    je do_div

    ; printf("unknown_msg operator\n"")
    mov rdi, unknown_msg
    xor eax, eax
    call printf

    jmp done

do_add:
    add eax, ebx
    jmp print_res

do_sub:
    sub eax, ebx
    jmp print_res

do_mul:
    imul eax, ebx
    jmp print_res

do_div:
    cmp ebx, 0
    je div_by_zero

    cdq
    idiv ebx
    jmp print_res

div_by_zero:
    ; printf("Can't divide by zero")
    mov rdi, zero_div_msg
    mov al, 1
    call printf

    jmp done

print_res:
    ; printf("Result = %d\n", result_msg)
    mov rdi, result_msg
    mov esi, eax

    xor eax, eax
    call printf

done:
    xor eax, eax
    ret
