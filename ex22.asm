[org 0x0100]

    mov ax, 6 ; bit number (0-15)
    mov bx, 0x000F ; sample value

    mov cl, al ; shift count must be in cl
    mov dx, 1 ; mask = 0000 0000 0000 0001
    shl dx, cl ; move 1 to the required position
    xor bx, dx ; complement the value of that bit in bx

    mov ax, 4C00h

