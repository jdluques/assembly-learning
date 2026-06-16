global fibonacci_recursive
global fibonacci_memoization_helper
global fibonacci_memoization
global fibonacci_iterative
global fibonacci_iterative_optimized
global matrix_multiplication
global fibonacci_exponentiation

section .text

; fibonacci_recursive(long long n)
fibonacci_recursive:
    ; if (n < 0) return -1;
    test rdi, rdi
    mov rax, -1
    jz .less_zero

    ; if (n <= 1) return n;
    cmp rdi, 1
    jle .less_eq_one

    ; fibonacci_recursive(n-1)
    dec rdi
    push rdi
    call fibonacci_recursive
    push rax

    ; fibonacci_recursive(n-2)
    pop rdi
    dec rdi
    call fibonacci_recursive
    
    ; fibonacci_recursive(n-1) + fibonacci_recursive(n-2)
    mov rdi, rax
    pop rax
    add rax, rdi
    
    ret

.less_eq_one:
    mov rax, rdi
    ret

.less_zero:
    mov rax, -1
    ret

fibonacci_memoization_helper:
    ret

fibonacci_memoization:
    ret

fibonacci_iterative:
    ret

fibonacci_iterative_optimized:
    ret

matrix_multiplication:
    ret

fibonacci_exponentiation:
    ret
