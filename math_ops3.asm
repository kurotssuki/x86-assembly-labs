section .bss
    mass1 resw 1 ; reserve 1 word (16bits / 2 bytes)
    buffer resb 2 ; 2 bytes one for '0' or '1', and one for the entere key

section .text
    global _start

_start:
    ;1. Set up the values
    mov ax, 10
    mov bx, 5

    ;2 Perform addition
    add ax, bx             ; AX = AX + BX

    ;3 Check for signed overflow
    jo .is_overflow        ;  Jump if Overflow Flag (OF) is set.

    ;4 No overflow path
.no_overflow:
    mov word [mass1], 0x7F ; Write 7f to mass1
    mov byte [buffer], '0' ; Prepare '1' for printing
    jmp .print_result

.is_overflow:
    ;5.overflow path
    mov word [mass1], ax    ; save the result from ax to mass1
    mov byte [buffer], '1'  ; Prepare '1' for printing

.print_result:
    ;PRINT THE FLAG 
    mov byte [buffer+1], 10 ; Add a newline (\n) after the number

    mov eax, 4          ; sys_write
    mov ebx, 1          ; stdout
    mov ecx, buffer     ; Memory address of our characters
    mov edx, 2          ; Print 2 bytes ('0' or '1', plus newline)
    int 0x80


    mov eax, 1          ; sys_exit
    mov ebx, 0          ; return 0
    int 0x80
