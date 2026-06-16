global strlen
global strcpy
global strcmp
global reverse

section .text

; size_t strlen(const char *s)
strlen:
    xor rax, rax  ; size_t len = 0

.while_len:
    cmp byte [rdi + rax], 0
    je .done_len

    inc rax
    jmp .while_len

.done_len:
    ret

; char * strcpy(char *dst, const char *src)
strcpy:
    mov rax, rdi      ; char *ret = dst

.while_cpy:
    ; *dst = *src
    mov dl, [rsi]
    mov [rdi], dl
    
    inc rdi
    inc rsi

    ; while (*src)
    test dl, dl
    jne .while_cpy

    mov [rdi], 0

    ret

; int strcmp(const char *a, const char *b)
strcmp:

.while_cmp:
    mov al, [rdi]   ; al = *a
    mov dl, [rsi]   ; dl = *b

    cmp al, dl      ; *a == *b
    jne .diff

    test al, al     ; *a != 0
    je .equal

    inc rdi
    inc rsi
    jmp .while_cmp

.diff:
    ; return (unsigned char)*a - (unsigned char)*b
    movzx eax, al
    movzx edx, dl
    sub eax, edx
    ret

.equal:
    ; return 0
    xor eax, eax
    ret

; void reverse(char *s)
reverse:
    ; int j = strlen(s) - 1
    push rdi
    call strlen
    pop rdi

    test rax, rax
    jz .done_rev

    dec rax

    ; int i = 0
    xor rsi, rsi
    
.while_rev:
    ; while (i < j)
    cmp rsi, rax
    jge .done_rev

    mov dl, [rdi + rsi] ; dl= s[i]
    mov cl, [rdi + rax] ; rcx = s[j]
    mov [rdi + rsi], cl ; s[i] = s[j]
    mov [rdi + rax], dl ; s[j] = tmp

    inc rsi
    dec rax

    jmp .while_rev

.done_rev:
    ret

