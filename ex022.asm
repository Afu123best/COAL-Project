[org 0x0100]
jmp start

msg: db 'Screen data row', 0
buffer: times 800 db 0      ; global array in memory

clrscr:
    push ax
    push es
    push di
    push cx

    mov ax, 0xB800
    mov es, ax
    mov ax, 0x0720
    xor di, di
    mov cx, 2000
    cld
    rep stosw

    pop cx
    pop di
    pop es
    pop ax
    ret

printstr:                   ; push row, col, attr, string
    push bp
    mov bp, sp
    push es
    push ax
    push di
    push si

    mov ax, 0xb800
    mov es, ax
    mov al, 80
    mul byte [bp+10]        ; row * 80
    add ax, [bp+8]          ; + col
    shl ax, 1
    mov di, ax
    mov si, [bp+4]          ; string offset
    mov ah, [bp+6]          ; attribute
    cld
nextchar:
    lodsb
    cmp al, 0
    jz strdone
    stosw
    jmp nextchar
strdone:
    pop si
    pop di
    pop ax
    pop es
    pop bp
    ret 8

delay:
    push cx
    push dx
    mov dx, 40
l_outer:
    mov cx, 0xFFFF
l_inner:
    loop l_inner
    dec dx
    jnz l_outer
    pop dx
    pop cx
    ret

scrollup:                   ; AX = number of rows
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es

    mov bx, ax
    mov ax, 160
    mul bx
    mov bx, ax              ; BX = bytes in n rows

    ; save top rows: video -> buffer
    mov ax, 0xb800
    mov ds, ax
    mov ax, cs              ; destination segment = our data segment
    mov es, ax
    mov di, buffer
    xor si, si
    mov cx, bx
    shr cx, 1
    cld
    rep movsw

    ; shift remaining screen up
    mov ax, 0xb800
    mov es, ax
    xor di, di
    mov si, bx
    mov cx, 4000
    sub cx, bx
    shr cx, 1
    rep movsw

    ; buffer -> bottom of screen
    mov ax, cs
    mov ds, ax
    mov si, buffer
    mov cx, bx
    shr cx, 1
    rep movsw

    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

scrolldown:                 ; AX = number of rows
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es

    mov bx, ax
    mov ax, 160
    mul bx
    mov bx, ax

    ; save bottom rows: video -> buffer
    mov ax, 0xb800
    mov ds, ax
    mov ax, cs
    mov es, ax
    mov di, buffer
    mov si, 4000
    sub si, bx
    mov cx, bx
    shr cx, 1
    cld
    rep movsw

    ; shift remaining screen down (backwards)
    mov ax, 0xb800
    mov es, ax
    mov si, 4000
    sub si, bx
    sub si, 2
    mov di, 3998
    mov cx, 4000
    sub cx, bx
    shr cx, 1
    std
    rep movsw
    cld

    ; buffer -> top of screen
    mov ax, cs
    mov ds, ax
    mov si, buffer
    xor di, di
    mov cx, bx
    shr cx, 1
    rep movsw

    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

start:
    call clrscr

    mov bx, 0               ; top 5 rows (0 to 4)
top:
    push bx                 ; row
    xor ax, ax
    push ax                 ; col
    mov ax, 0x1F
    push ax                 ; attribute
    mov ax, msg
    push ax                 ; string
    call printstr
    inc bx
    cmp bx, 5
    jne top

    mov bx, 20              ; bottom 5 rows (20 to 24)
bottom:
    push bx
    xor ax, ax
    push ax
    mov ax, 0x4E
    push ax
    mov ax, msg
    push ax
    call printstr
    inc bx
    cmp bx, 25
    jne bottom

forever:
    call delay
    call delay

    mov bx, 3               ; 3 rows up, one at a time
up:
    call delay
    mov ax, 1
    call scrollup
    dec bx
    jnz up

    mov bx, 3               ; 3 rows down, one at a time
down:
    call delay
    mov ax, 1
    call scrolldown
    dec bx
    jnz down

    jmp forever