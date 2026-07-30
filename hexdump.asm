; Beginner project #4
; Reads the CLI-passed file & prints it in a hex format

; CONFIGURABLE FIELDS
BUFFER_SIZE equ 4096

; CONSTANTS
SYS_READ equ 0
SYS_WRITE equ 1
SYS_EXIT equ 60
SYS_OPEN equ 2
SYS_CLOSE equ 3
SYS_SUCCESS equ 0
SYS_FAIL equ 1
O_RDONLY equ 0

STD_OUT equ 1
STD_ERR equ 2

ZERO_CHAR_ASCII equ 48
A_CHAR_ASCII_MINUS_10 equ 55
SPACE_CHAR_ASCII equ 32

default rel

section .bss
    file_buffer: resb BUFFER_SIZE
    output_buffer: resb BUFFER_SIZE * 3 ; every byte read expands into 2 ASCII characters & space separator

section .data
    usage_instruction: db "Usage: ./hexdump <filename>", 10

section .text
    global _start
    _start:
        ; r8 is gonna be the output buffer cursor
        pop rax ; argc
        cmp rax, 2
        jl print_usage

        pop rax ; program name, unneeded
        pop rdi ; argv[1] (filename)
        call open_file
        .loop:
            mov rdi, r12
            call read_chunk
            cmp rax, 0
            jle .end
            mov rcx, rax
            lea rdi, [file_buffer]
            lea rsi, [output_buffer]
            call process_buffer
            call print
            jmp .loop
        .end:
            mov rdi, r12
            call close_file
            jmp exit_success
    print_usage:
        mov rax, SYS_WRITE
        mov rdi, STD_ERR
        lea rsi, [usage_instruction]
        mov rdx, 28 ; len of the usage string
        syscall
        jmp exit_error
    print:
        mov rax, SYS_WRITE
        mov rdi, STD_OUT

        lea rsi, [output_buffer]
        mov rdx, r8

        syscall
        ret
    open_file:
        mov rax, SYS_OPEN
        mov rsi, O_RDONLY
        xor rdx, rdx
        ; rdi is already filled with filename
        syscall
        cmp rax, 0
        jl exit_error
        mov r12, rax
        ret

    read_chunk:
        mov rax, SYS_READ
        ; rdi is already passed
        lea rsi, [file_buffer]
        mov rdx, BUFFER_SIZE
        syscall
        ret
    close_file:
        mov rax, SYS_CLOSE
        ; rdi is already passed
        syscall
        ret

    nibble_to_hex:
        cmp al, 10
        jl .lessthan
        jmp .greater_or_eq

        .greater_or_eq:
            add al, A_CHAR_ASCII_MINUS_10
            jmp .end
        .lessthan:
            add al, ZERO_CHAR_ASCII
        .end:
            ret
    
    byte_to_hex:
        mov ah, al
        
        ; high nibble
        shr al, 4
        call nibble_to_hex
        mov byte [rsi], al
        inc rsi

        ; low nibble
        mov al, ah
        and al, 0x0F
        call nibble_to_hex
        mov byte [rsi], al
        inc rsi
        ret

    process_buffer:
        ; rdi = file_buffer
        ; rsi = output_buffer
        ; rcx = bytes read count
        
        push rbx
        push r15
        mov r15, rsi ; save start of output_buffer in r15
        xor rbx, rbx ; index for file_buffer

        .loop:
            cmp rbx, rcx
            jge .end
            
            mov al, byte [rdi + rbx]
            call byte_to_hex
            
            mov byte [rsi], SPACE_CHAR_ASCII
            inc rsi
            
            inc rbx
            jmp .loop

        .end:
            ; calculate total bytes written = current_rsi - start_rsi
            mov r8, rsi
            sub r8, r15
            
            pop r15
            pop rbx
            ret

    
    exit_error:
        mov rax, SYS_EXIT
        mov rdi, SYS_FAIL
        syscall

    exit_success:
        mov rax, SYS_EXIT
        mov rdi, SYS_SUCCESS
        syscall