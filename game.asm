[org 0x0100]

jmp start

clear_screen:
    push ax
    push cx
    push di

    xor di, di

    mov ax, 0x0720
    mov cx, 2000

    cld 
    rep stosw

    pop di
    pop cx
    pop ax
    ret

start:

    ; set 80x25 color text mode
    int ax, 0003h
    int 10h

    ; set es to video memory
    mov ax, 0xb800
    mov es, ax


    call clear_screen

    ; wait for a key
    mov ah, 00h
    int 16h

    ; exit 
    mov ax, 4C00h
    int 0x21