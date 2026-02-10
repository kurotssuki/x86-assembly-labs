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
;bracket (x + 1)
mov eax, esi ; get the copy 
add eax, 1
mov ebx, eax ;store the first bracket result in ebx
;bracket 2 (2X-4)
mov eax, esi ; get the copy
imul eax, 2
sub eax, 4
mov ecx, eax ; store the second bracket result in ecx
;bracket 3 (3X-7)
mov eax, esi; get safe copy
imul eax, 3
sub eax, 7 ; third bracket result can be kept in eax
;multiply everything
imul ebx, ecx ; bracket 1*bracket 2
imul eax, ebx ; result*bracket 3

;4. COVERT EAX TO DECIMAL AND PRINT
mov ebx, 10 ; divide by 10 repeatedly to separate bigger numbers (123 to '1' '2' '3' etc.)
mov ecx, 0 ; exc will count how many digits were generated

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
