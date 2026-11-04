; string copy
[org 0x0100]
jmp start
msg: db 'Assembly Rocks$', 0
buffer: db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; 15 characters + the final 0 = 16 bytes

start:
    mov si, 0

next:
    mov al, [msg+si]
    mov [buf+si], al
    inc si
    cmp al, 0
    jne next ; stop after copying 0 terminator

    mov ax, 4C00h
    int 0x21