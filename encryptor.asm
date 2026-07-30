; beginner project #3
; features:
; encryption & decryption
; encryption key generation (xorshift64)
section .data
    message_to_encrypt: db "Hello, world!", 0
    encrypted_message: times 32 db 0
    decrypted_message: times 32 db 0
    seed: dq 0

section .text
    global _start
    _start:
        call init_seed
        lea rax, [message_to_encrypt]
        mov r8, rax
        call strlen ; get string length to the register rdx
        call encryption_key ; get the encryption key to register rax

        push rax ; store the encryption key (since it is rotated inside of the encrypt function)
        call encrypt
        
        pop rax
        lea r8, [encrypted_message]
        call decrypt

        lea rsi, [decrypted_message]
        call print

        jmp end
    strlen:
        ; rax = address of the string
        ; rdx = return value (string length)
        ; rsi = local register for operations
        push rsi ; store the original value of rsi
        xor rdx, rdx ; zero
        .loop:
            mov sil, byte [rax + rdx]
            cmp sil, 0
            jz .end
            inc rdx
            jmp .loop
            
        .end:
            pop rsi ; give the original value back
            ret

    init_seed:
        rdtsc
        shl rdx, 32
        or rax, rdx
        
        cmp rax, 0
        jnz .save
        mov rax, 88172645463325252

        .save:
            mov [seed], rax
            ret

    encrypt:
        ; rax = encryption key
        ; r8 = message to encrypt
        ; rdx = length of the message
        ; writes the encrypted message to encrypted_message label
        mov r9, rdx
        lea r10, [encrypted_message]

        cmp rdx, 0
        jle .end

        .loop:
            mov r11b, byte [r8 + r9 - 1]
            xor r11b, al
            mov byte [r10 + r9 -1], r11b

            ror rax, 8

            dec r9
            jnz .loop
        
        .end:
            ret

    decrypt:
        ; rax = encryption key
        ; r8 = message to decrypt
        ; rdx = length of the message
        ; writes the decrypted message to decrypted_message label
        mov r9, rdx
        lea r10, [decrypted_message]

        cmp rdx, 0
        jle .end

        .loop:
            mov r11b, byte [r8 + r9 - 1]
            xor r11b, al
            mov byte [r10 + r9 -1], r11b

            ror rax, 8

            dec r9
            jnz .loop
        
        .end:
            ret


    print:
        mov rax, 1
        mov rdi, 1

        ; rsi and rdx are filled by the caller
        syscall
        ret
    
    encryption_key:
        ; uses xorshift64 algorithm

        push rdx ; store the data

        mov rax, [seed]    ; load current seed state
        mov rdx, rax       ; copy state

        shl rdx, 13        ; x ^= x << 13
        xor rax, rdx
        
        mov rdx, rax       ; x ^= x >> 7
        shr rdx, 7
        xor rax, rdx
        
        mov rdx, rax       ; x ^= x << 17
        shl rdx, 17
        xor rax, rdx
        
        mov [seed], rax    ; save the new state/seed
        pop rdx
        ret
    
    end:
        mov rax, 60
        xor rdi, rdi
        syscall
