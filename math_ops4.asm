section .data
    ; Test data: Pairs at index 1, 4, 6, and 8 will sum to 0.
    mass1 dd  10, -5,  20, 15, -8,  44, -12, 50,  3,  99
    mass2 dd   5,  5, -20, 10,  8,  11,  12, 10, -3,   1

    ; A nice header message to print first
    msg db "Found zero sum! Memory Addresses:", 10
    msg_len equ $ - msg

section .bss
    mass3 resd 20       ; Array to hold our found memory addresses
    buffer resb 9       ; 8 bytes for the hex address + 1 byte for newline (\n)

section .text
    global _start

_start:
    ; --- 1. FIND PAIRS AND STORE ADDRESSES ---
    mov ecx, 10         ; Loop counter (10 elements)
    mov esi, 0          ; mass1/mass2 offset
    mov edi, 0          ; mass3 offset

.array_loop:
    mov eax, [mass1 + esi] 
    mov ebx, [mass2 + esi] 
    add eax, ebx        ; Add elements
    cmp eax, 0          ; Check if sum is 0
    jne .next_element

.found_zero:
    ; Calculate and store mass1 address
    mov edx, mass1
    add edx, esi
    mov [mass3 + edi], edx

    ; Calculate and store mass2 address
    mov edx, mass2
    add edx, esi
    mov [mass3 + edi + 4], edx

    add edi, 8          ; Move mass3 offset forward by 8 bytes (2 addresses)

.next_element:
    add esi, 4          ; Move array offset forward 4 bytes
    dec ecx
    jnz .array_loop

    ; Save the total number of bytes written to mass3 into EBP so we know when to stop printing
    mov ebp, edi        

    ; --- 2. PRINT HEADER MESSAGE ---
    mov eax, 4
    mov ebx, 1
    mov ecx, msg
    mov edx, msg_len
    int 0x80

    ; --- 3. PRINT ADDRESSES IN HEXADECIMAL ---
    mov esi, 0          ; Reset ESI to use as the reader for mass3

.print_addresses_loop:
    cmp esi, ebp        ; Have we printed all the stored addresses?
    jge .exit           ; If yes, exit

    mov eax, [mass3 + esi] ; Load the memory address we want to print
    
    ; Convert EAX into an 8-character Hex string
    mov ecx, 8          ; 8 hex digits in a 32-bit address
    mov edi, buffer     ; Point to our printing buffer
.hex_convert:
    rol eax, 4          ; "Rotate Left": Push the highest 4 bits to the bottom
    mov edx, eax
    and edx, 0x0F       ; Mask out everything except the lowest 4 bits
    cmp dl, 9           ; Is it a number 0-9?
    jbe .is_digit
    add dl, 7           ; If it's 10-15, shift it up to ASCII letters 'A' through 'F'
.is_digit:
    add dl, 48          ; Convert to ASCII character
    mov [edi], dl       ; Save character to buffer
    inc edi             ; Move buffer pointer forward
    dec ecx             
    jnz .hex_convert
    
    mov byte [edi], 10  ; Add a newline character at the end of the 8 hex digits

    ; Print the 9-byte buffer
    push esi            ; Save ESI (our mass3 position) because sys_write might mess it up
    mov eax, 4
    mov ebx, 1
    mov ecx, buffer
    mov edx, 9          
    int 0x80
    pop esi             ; Restore ESI

    add esi, 4          ; Move to the next address in mass3
    jmp .print_addresses_loop ; Loop back and print it

.exit:
    mov eax, 1
    mov ebx, 0
    int 0x80
