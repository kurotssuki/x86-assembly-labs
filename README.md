# x86 Assembly Math Operations

A low-level assembly program written in NASM (32-bit) that performs algebraic calculations on user input.

## The Formula
The program takes a single digit input (x) and solves:
$$(x + 1) * (2x - 4) * (3x - 7)$$

## Tech Stack
* **Language:** x86 Assembly (Intel Syntax)
* **Assembler:** NASM
* **Linker:** GNU ld
* **Platform:** Linux (Elf32)

## How to Run (Kali Linux / Debian)

1.**Assemble the code:**
```bash
nasm -f elf32 math_ops.asm -o math_ops.o
```
2.**Link the object file:**
```bash
ld -m elf_i386 math_ops.o -o math_ops
```
3.**Run the executable:**
```bash
./math_ops
```
## Example Output
```bash
$ ./math_ops
5
288
```
