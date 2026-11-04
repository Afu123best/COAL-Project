[org 0x0100]
jmp start

message: db 'You_divided_something_by_zero.', 0

clrscr:
    push es
    push ax
    push cx
    push di

    mov ax, 0xb800
    mov es, ax
    xor di, di
    mov ax, 0x0720
    mov cx, 2000
    cld 
    rep stosw                   ; <-- was just stosw

    pop di
    pop cx
    pop ax
    pop es
    ret

strlen:
    push bp
    mov bp, sp
    push es
    push cx
    push di

    les di, [bp+4]
    mov cx, 0xFFFF
    xor al, al
    repne scasb
    mov ax, 0xFFFF
    sub ax, cx
    dec ax

    pop di
    pop cx
    pop es
    pop bp
    ret 4

printstr:
    push bp
    mov bp, sp
    push es
    push ax
    push cx
    push si
    push di

    push ds
    mov ax, [bp+4]
    push ax
    call strlen
    cmp ax, 0
    jz exit
    mov cx, ax
    mov ax, 0xb800
    mov es, ax
    mov al, 80
    mul byte[bp+8]
    add ax, [bp+10]
    shl ax, 1
    mov di, ax
    mov si, [bp+4]
    mov ah, [bp+6]
    cld
nextchar:
    lodsb
    stosw
    loop nextchar

exit:
    pop di
    pop si
    pop cx
    pop ax
    pop es
    pop bp
    ret 8

myisrfor0: 
    push ax ; push all regs
    push bx
    push cx
    push dx
    push si
    push di
    push bp
    push ds
    push es
    mov bp, sp
    add word [ss:bp+18], 2
    push cs
    pop ds ; point ds to our data segment
    call clrscr ; clear the screen
    mov ax, 0
    push ax ; push x position
    mov ax, 0
    push ax ; push y position
    mov ax, 0x07 ; white on blue attribute
    push ax ; push attribute
    mov ax, message
    push ax ; push offset of message
    call printstr ; print message
    pop es
    pop ds
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    iret
genint0: 
    mov ax, 0x8432 ; load a big number in ax
    mov bl, 2 ; use a very small divisor
    div bl ; interrupt 0 will be generated
    ret

start: 
    xor ax, ax
    mov es, ax ; load zero in es
    mov word [es:0*4], myisrfor0 ; store offset at n*4
    mov [es:0*4+2], cs ; store segment at n*4+2
    call genint0 ; generate interrupt 0
    mov ax, 0x4c00 ; terminate program
    int 0x21