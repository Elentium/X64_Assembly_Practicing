; beginner project #1
; decrypts the message by subtracting 3 from the ascii index of each character
section .data
    align 16
    ciphertext: db "Khoor#Dvvhpeo|#", 10 
    
    align 16
    key:        db 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3

section .text
    global _start

_start:
    movdqa xmm0, [ciphertext]
    psubb xmm0, [key]
    movdqa [ciphertext], xmm0

    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    mov rsi, ciphertext         ; Address of buffer
    mov rdx, 16                 ; Length of buffer (16 bytes)
    syscall

    mov rax, 60                 ; sys_exit
    mov rdi, 0                  ; Exit code 0
    syscall