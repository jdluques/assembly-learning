default rel

global main
extern printf
extern fprintf

section .data
    ; Syscall Constants
    SYS_WRITE         equ 1
    SYS_OPEN          equ 2
    SYS_CLOSE         equ 3
    SYS_FSTAT         equ 5
    SYS_LSEEK         equ 8
    SYS_MMAP          equ 9
    SYS_MPROTECT      equ 10
    SYS_MUNMAP        equ 11
    SYS_BRK           equ 12
    SYS_NANOSLEEP     equ 35
    SYS_GETPID        equ 39
    SYS_EXIT          equ 60

    ; File Flags & Permissions
    O_CREAT_WR        equ 578   ; O_RDWR (2) | O_CREAT (64) | O_TRUNC (512)
    FILE_PERMS        equ 644o ;

    ; Memory Mapping Flags
    PROT_RW           equ 3     ; Read and Write
    PROT_RO           equ 1     ; Read-only
    MAP_ANON_PRIV     equ 34

    ; Streams
    STDOUT            equ 1
    STDERR            equ 2

    ; Error code
    MAX_ERRNO         equ -4095
    EXIT_FAILURE      equ 1

    ; SYS_FSTAT
    ST_MODE           equ 24
    ST_UID            equ 28
    ST_GID            equ 32
    ST_SIZE           equ 48

    ; SYS_LSEEK
    SEEK_SET          equ 0

    ; SYS_MMAP
    MAP_SHARED        equ 1

    ; Strings
    getpid_msg        db "1. getpid: Process ID is %d", 10, 0
    brk_msg           db "2. brk: Heap expanded to %p. Old top: %p", 10, 0
    open_msg          db "3. open: Created demo.txt (fd: %d)", 10, 0
    write_msg         db "4. Wrote data to demo.txt", 10, 0
    lseek_msg         db "5. lseek: Rewound file pointer to beginning", 10, 0
    fstat_msg         db "6. fstat: File size is %ld bytes", 10, 0
    mmap_msg          db "7. mmap: File mapped into memoty at %p", 10, 0
    mprotect_msg      db "8. mprotect: Memory locked to Read-only", 10, 0
    mapped_msg_1      db 10, "--- MAPPED DATA ---", 10, 0
    mapped_msg_2      db "-------------------", 10, 10, 0
    munmap_msg        db "9. munmap: Unmapped memory", 10, 0
    close_msg         db "10. close: Close file descriptor", 10, 0
    nanosleep_msg     db "11. nanosleep: Suspending current thread for %d seconds and %d nanoseconds", 10, 0
    exit_msg          db "12. exit: Terminating cleanly.", 10, 0

    brk_err_msg       db "Error incrementing heap size by 1 KB", 10, 0
    open_err_msg      db "Error opening '%s'", 10, 0
    write_err_msg     db "Error writing to '%s'", 10, 0
    write_out_err_msg db "Error writing to stdout", 10, 0
    lseek_err_msg     db "Error setting file pointer to 0", 10, 0;
    fstat_err_msg     db "Error getting file metadata from '%s'", 10, 0
    mmap_err_msg      db "Error mapping '%s'", 10, 0
    mprotect_err_msg  db "Error locking the mapping of '%s' to READ-ONLY", 10, 0
    munmap_err_msg    db "Error releasing memory mapping of '%s'", 10, 0
    close_err_msg     db "Error closing '%s'", 10, 0
    nanosleep_err_msg db "Error during nanosleep", 10, 0

    filepath          db "demo.txt", 0
    write_str         db "Hello directly from the kernel memory!", 10
    write_str_len     equ $ - write_str

section .bss
    fd                resq 1
    mmap_ptr          resq 1

section .text

main:
    push rbp
    mov rbp, rsp
    sub rsp, 160          ; sleep_spec (16 bytes) + st (144 bytes)

    ; 1. SYS_GETPID
    ; getpid()
    mov eax, SYS_GETPID
    syscall

    mov rdi, getpid_msg
    mov rsi, rax
    xor rax, rax
    call printf

    ; 2. SYS_BRK
    ; sbrk(0)
    mov eax, SYS_BRK
    xor rdi, rdi
    syscall
    
    mov r12, rax

    ; sbrk(1024)
    mov eax, SYS_BRK
    mov rdi, r12
    add rdi, 1024
    syscall

    cmp rax, r12
    je .brk_err

    cmp rax, MAX_ERRNO
    jae .brk_err

    mov rdi, brk_msg
    mov rsi, r12
    mov rdx, rax
    xor rax, rax
    call printf

    ; 3. SYS_OPEN
    ; open(filepath, O_RDWR | O_CREAT | O_TRUNC, 0644)
    mov eax, SYS_OPEN
    mov rdi, filepath
    mov rsi, O_CREAT_WR
    mov rdx, FILE_PERMS
    syscall

    test rax, rax
    jl .open_err

    mov [fd], rax

    mov rdi, open_msg
    mov rsi, rax
    xor rax, rax
    call printf

    ; 4. SYS_WRITE
    xor r12, r12

.for_1:
    cmp r12, write_str_len
    jge .end_for_1

    ; write(fd, msg + total_written, strlen(msg) - total_written)
    mov eax, SYS_WRITE
    mov rdi, [fd]
    mov rsi, write_str
    add rsi, r12
    mov rdx, write_str_len
    sub rdx, r12
    syscall
    
    test rax, rax
    jz .continue_1
    
    cmp rax, MAX_ERRNO
    jae .write_err

.continue_1:
    add r12, rax

    jmp .for_1

.end_for_1:

    mov rdi, write_msg
    xor rax, rax
    call printf

    ; 5. SYS_LSEEK
    ; lseek(fd, 0, SEEK_SET)
    mov eax, SYS_LSEEK
    mov rdi, [fd]
    xor rsi, rsi
    mov rdx, SEEK_SET
    syscall

    cmp rax, -1
    je .lseek_err

    mov rdi, lseek_msg
    xor rax, rax
    call printf

    ; 6. SYS_FSTAT
    ; fstat(fd, &st)
    mov eax, SYS_FSTAT
    mov rdi, [fd]
    lea rsi, [rsp + 16]
    syscall

    cmp rax, MAX_ERRNO
    jae .fstat_err

    mov rdi, fstat_msg
    mov rsi, [rsp + 16 + ST_SIZE]
    xor rax, rax
    call printf

    ; 7. SYS_MMAP
    ; mmap(NULL, st.st_size, PROT_READ, PROT_WRITE, MAP_SHARED, fd, 0)
    mov eax, SYS_MMAP
    xor rdi, rdi
    mov rsi, [rsp + 16 + ST_SIZE]
    mov rdx, PROT_RW
    mov r10, MAP_SHARED
    mov r8, [fd]
    xor r9, r9
    syscall

    cmp rax, MAX_ERRNO
    jae .mmap_err

    mov [mmap_ptr], rax

    mov rdi, mmap_msg
    mov rsi, rax
    xor rax, rax
    call printf

    ; 8. SYS_MPROTECT
    ; mprotect(mapped, st.st_size, PROT_READ)
    mov eax, SYS_MPROTECT
    mov rdi, [mmap_ptr]
    mov rsi, [rsp + 16 + ST_SIZE]
    mov rdx, PROT_RO
    syscall

    cmp rax, MAX_ERRNO
    jae .mprotect_err

    mov rdi, mprotect_msg
    xor rax, rax
    call printf

    mov rdi, mapped_msg_1
    xor rax, rax
    call printf

    xor r12, r12
    mov r13, [rsp + 16 + ST_SIZE]

.for_2:
    cmp r12, r13
    jge .end_for_2

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, [mmap_ptr]
    add rsi, r12
    mov rdx, [rsp + 16 + ST_SIZE]
    sub rdx, r12
    syscall

    test rax, rax
    jz .continue_2

    cmp rax, MAX_ERRNO
    jae .write_out_err

.continue_2:
    add r12, rax

    jmp .for_2

.end_for_2:

    mov rdi, mapped_msg_2
    xor rax, rax
    call printf

    ; 9. SYS_MUNMAP
    ; munmap(mapped, st.st_size)
    mov eax, SYS_MUNMAP
    mov rdi, [mmap_ptr]
    mov rsi, [rsp + 16 + ST_SIZE]
    syscall

    cmp rax, MAX_ERRNO
    jae .munmap_err

    mov rdi, munmap_msg
    xor rax, rax
    call printf

    ; 10. SYS_CLOSE
    ; close(fd)
    mov eax, SYS_CLOSE
    mov rdi, [fd]
    syscall

    cmp rax, MAX_ERRNO
    jae .close_err

    mov rdi, close_msg
    xor rax, rax
    call printf

    ; 11. SYS_NANOSLEEP
    mov qword [rsp], 1      ; tv_sec = 1 second
    mov qword [rsp + 8], 0  ; tv_nsec = 0 nanoseconds

    mov rdi, nanosleep_msg
    mov rsi, [rsp]
    mov rdx, [rsp + 8]
    xor rax, rax
    call printf

    ; nanosleep(&sleep_spec, 0)
    mov eax, SYS_NANOSLEEP
    mov rdi, rsp
    xor rsi, rsi
    syscall

    cmp rax, MAX_ERRNO
    jae .nanosleep_err

    ; 12. SYS_EXIT
    mov rdi, exit_msg
    xor rax, rax
    call printf

    add rsp, 160
    
    mov eax, SYS_EXIT
    xor rdi, rdi
    syscall

.brk_err:
    mov rdi, STDERR
    mov rsi, brk_err_msg
    xor rax, rax
    call fprintf

    jmp .exit_failure

.open_err:
    mov rdi, STDERR
    mov rsi, open_err_msg
    mov rdx, filepath
    xor rax, rax
    call fprintf

    jmp .exit_failure

.write_err:
    mov rdi, STDERR
    mov rsi, write_err_msg
    mov rdx, filepath
    xor rax, rax
    call fprintf

    mov eax, SYS_CLOSE
    mov rdi, [fd]
    syscall

    cmp rax, MAX_ERRNO
    jae .close_err

    jmp .exit_failure

.write_out_err:
    mov rdi, STDERR
    mov rsi, write_out_err_msg
    xor rax, rax
    call fprintf

    mov eax, SYS_CLOSE
    mov rdi, [fd]
    syscall

    cmp rax, MAX_ERRNO
    jae .close_err

    jmp .exit_failure

.lseek_err:
    mov rdi, STDERR
    mov rsi, lseek_err_msg
    mov rdx, filepath
    xor rax, rax
    call fprintf

    mov eax, SYS_CLOSE
    mov rdi, [fd]
    syscall

    cmp rax, MAX_ERRNO
    jae .close_err

    jmp .exit_failure

.fstat_err:
    mov rdi, STDERR
    mov rsi, fstat_err_msg
    mov rdx, filepath
    xor rax, rax
    call fprintf

    mov eax, SYS_CLOSE
    mov rdi, [fd]
    syscall

    cmp rax, MAX_ERRNO
    jae .close_err

    jmp .exit_failure

.mmap_err:
    mov rdi, STDERR
    mov rsi, mmap_err_msg
    mov rdx, filepath
    xor rax, rax
    call fprintf

    mov eax, SYS_CLOSE
    mov rdi, [fd]
    syscall

    cmp rax, MAX_ERRNO
    jae .close_err

    jmp .exit_failure

.mprotect_err:
    mov rdi, STDERR
    mov rsi, mprotect_err_msg
    mov rdx, filepath
    xor rax, rax
    call fprintf

    mov eax, SYS_CLOSE
    mov rdi, [fd]
    syscall

    cmp rax, MAX_ERRNO
    jae .close_err

    jmp .exit_failure

.munmap_err:
    mov rdi, STDERR
    mov rsi, munmap_err_msg
    mov rdx, filepath
    xor rax, rax
    call fprintf

    mov eax, SYS_CLOSE
    mov rdi, [fd]
    syscall

    cmp rax, MAX_ERRNO
    jae .close_err

    jmp .exit_failure

.fail_close:
    mov eax, SYS_CLOSE
    mov rdi, [fd]
    syscall

    cmp rax, MAX_ERRNO
    jb .exit_failure

.close_err:
    mov rdi, STDERR
    mov rsi, close_err_msg
    mov rdx, filepath
    xor rax, rax
    call fprintf

    jmp .exit_failure

.nanosleep_err:
    mov rdi, STDERR
    mov rsi, nanosleep_err_msg
    xor rax, rax
    call fprintf

.exit_failure:
    add rsp, 160
    mov rax, EXIT_FAILURE
    ret
