; a program to add ten numbers without a seperate counter
[org 0x0100]

    jmp start

num1:   dw 1,2,3,4,5,1,2,3,4,5
total:  dw 0

start:  mov bx, 0 ;initialise array index to 0
        mov ax, 0 ;initialise sum to zero

l1: add ax, [num1+bx]
    add bx,2
    cmp bx, 20
    jne l1

    mov [total], ax

    mov ax, 0x4C00
    int 0x21

