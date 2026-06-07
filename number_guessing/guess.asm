global main

extern srand
extern rand
extern time
extern printf
extern scanf

section .data
    start_msg     db "You have 10 attempts to guess the correct number", 10, 0
    prompt_msg    db "(Attempt %d) Guess a number (1-10): ", 0
    guess_format  db "%d", 0

    correct_msg   db "You guessed correctly!", 10, 0
    lower_msg     db "You guessed incorrectly, the number is lower", 10, 0
    higher_msg    db "You guessed incorrectly, the number is higher", 10, 0
    game_over_msg db "Game over, the correct number was %d", 10, 0

section .bss
    number  resd 1
    guess   resd 1
    count   resd 1

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

    ; printf("You have 10 attempts to guess the correct number\n")
    mov rdi, start_msg
    xor eax, eax
    call printf

while:
    ; while (count++ < 10)
    cmp dword [rel count], 10
    jge game_over
    inc dword [rel count]
    
    ; printf("(Attempt %d) Guess a number (1-10)")
    mov rdi, prompt_msg
    mov esi, [rel count] 
    xor eax, eax
    call printf

    ; scanf("%d", &guess)
    mov rdi, guess_format
    lea rsi, [rel guess]
    xor eax, eax
    call scanf

    ; if (scanf... != 1)
    cmp eax, 1
    jne exit_error

    ; if (guess == number)
    mov eax, [rel guess]
    mov edx, [rel number]

    cmp eax, edx
    jg lower
    jl higher
 
correct:
     ; printf("You guessed correctly!\n")
    mov rdi, correct_msg
    xor eax, eax
    call printf

    jmp exit

lower:
    ; printf("You guessed incorrectly, the number is lower\n")
    mov rdi, lower_msg
    xor eax, eax
    call printf

    jmp while

higher:
    ; printf("You guessed incorrectly, the number is higher\n")
    mov rdi, higher_msg
    xor eax, eax
    call printf

    jmp while

game_over:
    ; printf("Game over, the correct number was %d\n")
    mov rdi, game_over_msg
    mov esi, [rel number]
    xor eax, eax
    call printf

exit:
    xor eax, eax
    ret

exit_error:
    mov al, 1
    ret
