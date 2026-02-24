section .bss
  x resb 2 ; Reserve 2 bytes (one for the digit, one for the 'Enter' key)
  buffer resb 10 ; Output buffer for a final string
section .text
  global _start
  
_start:
;1.READ INPUT
mov eax, 3 ;perform a read operation
mov ebx, 0 ;read from standard input(keyboard)
mov ecx, x ;save to the variable x
mov edx, 2 ;read 2 bytes
int 0x80

;2.CONVERT ASCII TO int
movzx eax, byte [x] ; character still in ASCII
sub eax, 48 ; int

mov esi, eax ; safe a copy for each bracket

;3.DO THE MATH
mov edi, 1 ; Y (loop result)
mov ebx, 1 ; n (loop index)

.math_loop:
    ; (3n-2)
    mov eax, 3
    imul eax, ebx ; 3*n
    sub eax, 2 ; eax = (3n-2)
    mov ecx, eax ; save frist bracket result in ECX

    ; nX
    mov eax, esi ; load x
    imul eax, ebx; X * n

    ; [nX - (3n - 2)]
    sub eax, ecx

    ;Multiply into Y
    imul edi, eax ; Y = y*current result

    ; Loop control
    inc ebx ; n = n + 1
    cmp ebx, 10 ; check if n = 10
    jle .math_loop ; if n<=10, jump back to .math_loop

    ; Put the result into EAX for printing
    mov eax, edi

    ;4. COVERT EAX TO DECIMAL AND PRINT

;check for negative numbers
cmp eax, 0
    jge .start_conversion ; If positive or zero, jump straight to conversion
    
    ; If negative, print a minus sign
    push eax              ; Save our negative number
    mov byte [buffer], '-' 
    mov eax, 4            ; sys_write
    mov ebx, 1            ; stdout
    mov ecx, buffer
    mov edx, 1
    int 0x80
    pop eax               ; Get number back
    neg eax               ; Make it positive so division works

.start_conversion:
    mov ebx, 10 ; Divide by 10 
    mov ecx, 0 ; count how many digits were generated


.divide_loop:
  xor edx, edx ; clear edx before operation
  div ebx ; divide by 10
  add dl, 48 ; convert the remainder to ASCII
  push dx ; push to the stack
  inc ecx ; keep track on how many digits we have
  test eax, eax ; check if we have any left
  jnz .divide_loop

.print_loop:
  pop dx ; take the top characher
  mov [buffer], dl ; using the buffer

  push ecx ; save digit count in case Kernel overwrites it
  mov eax, 4 ; sys_write command
  mov ebx, 1 ; file descriptor for stdout
  mov ecx, buffer ; the memory addres of the characther
  mov edx, 1
  int 0x80 ; call the kernel;
  pop ecx  ; get digit counter back

  loop .print_loop


;4 EXIT
mov eax, 1 ; call the sys_exit()
mov ebx, 0 ; return 0 (everyhing fine)
int 0x80 ; call the kernel
