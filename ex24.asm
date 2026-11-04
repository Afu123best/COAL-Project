[org 0x0100]
jmp start

clrscr:
    push es
    push ax
    push cx
    push di
    
    mov ax, 0xb800
    mov es, ax
    xor di, di
    mov ax, 0x0730
    mov cx, 2000
    cld
    rep stosw
    
    pop di
    pop cx
    pop ax
    pop es
    ret

start:
    call clrscr
    mov ax, 4C00h
    int 0x21