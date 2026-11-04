[org 0x0100]
    mov ax, [0025]
    mov [0FFF], ax

    mov bx, [0010]
    mov [002F], bx

    mov ax, 0x4C00
    int 0x21