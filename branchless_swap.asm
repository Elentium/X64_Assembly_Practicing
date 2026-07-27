; beginner project #2
; branchless swap of characters using SIMD
; not very organized and only works for 16 byte string
section .data
    align 16
    string: db "attack at dawn!!", 0
    
    align 16
    match_symbol: db "aaaaaaaaaaaaaaaa"

    align 16
    replace_symbol: db "@@@@@@@@@@@@@@@@"

section .text
    global _start

    _start:
        ; load the data to the registers
        movdqa xmm0, [string]
        movdqa xmm1, [match_symbol]
        movdqa xmm2, [replace_symbol]

        ; match the characters in string
        movdqa xmm3, xmm0
        pcmpeqb xmm3, xmm1

        ; move data to the register
        movdqa xmm4, xmm3
        ; every byte that is 0xFF, it will be replaced with ascii @, the rest is 0x00
        pand xmm4, xmm2

        ; zero all the bytes with the match symbol
        pandn xmm3, xmm0

        ; merge
        por xmm3, xmm4

        ; load back
        movdqa [string], xmm3


        ; print the string
        mov rax, 1
        mov rdi, 1
        mov rsi, string
        mov rdx, 16
        syscall

        mov rax, 60
        mov rdi, 0
        syscall

