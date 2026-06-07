global main

extern srand
extern rand
extern time
extern printf
extern scanf

section .data
    prompt_msg    db "Guess a number (1-10): ", 0
    guess_format  db "%d", 0

    correct_msg   db "You guessed correctly!", 10, 0
    incorrect_msg db "You guessed incorrectly, the correct number was %d", 10, 0

section .bss
    number  resd 1
    guess   resd 1

section .text

main:
    ; srand(time(null))
    xor rdi, rdi
    call time;
    
    mov rdi, rax
    call srand

    ; guess = rand() % 10 + 1
    call rand
    
    mov ecx, 10
    xor edx, edx
    div ecx       ; EDX = remainder (modulo)

    inc edx
    mov [rel number], edx

    ; printf("Guess a number (1-10)")
    mov rdi, prompt_msg
    xor eax, eax
    call printf

    ; scanf("%d", &guess)
    mov rdi, guess_format
    lea rsi, [rel guess]
    xor eax, eax
    call scanf

    cmp eax, 1
    jne exit_error

    ; if (guess == number)
    mov eax, [rel guess]
    mov edx, [rel number]

    cmp eax, edx
    jne incorrect

    ; printf("you guessed correctly!\n")
    mov rdi, correct_msg
    xor eax, eax
    call printf

    jmp exit

incorrect:
    ; printf("you guessed incorrectly")
    mov rdi, incorrect_msg
    mov esi, [rel number]
    xor eax, eax
    call printf

exit:
    xor eax, eax
    ret

exit_error:
    mov al, 1
    ret
