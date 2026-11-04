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
    mov ax, 0x0720
    mov cx, 2000
    cld
    rep stosw
    pop di
    pop cx
    pop ax
    pop es
    ret

printchars:
    push es
    push ax
    push cx
    push di
    mov ax, 0xb800
    mov es, ax
    xor di, di
    mov cx, 256
    xor al, al
    mov ah, 0x07
    cld
next1:
    stosw
    inc al
    loop next1
    pop di
    pop cx
    pop ax
    pop es
    ret

scrollup:
    push bp
    mov bp, sp
    sub sp, 800             ; local array (5 rows * 160 bytes)
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es

    mov bx, ax              ; BX = rows
    mov ax, 160
    mul bx                  ; AX = bytes to move
    mov bx, ax              ; BX = bytes in the n rows

    ; 1) save top rows: video -> local array
    mov ax, 0xb800
    mov ds, ax
    mov ax, ss
    mov es, ax
    lea di, [bp-800]
    xor si, si
    mov cx, bx
    shr cx, 1
    cld
    rep movsw

    ; 2) shift remaining screen up: video -> video
    mov ax, 0xb800
    mov es, ax
    xor di, di
    mov si, bx
    mov cx, 4000
    sub cx, bx
    shr cx, 1
    rep movsw               ; DI ends at 4000 - BX (bottom rows)

    ; 3) saved rows -> bottom of screen
    mov ax, ss
    mov ds, ax
    lea si, [bp-800]
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
    mov sp, bp              ; free the local array
    pop bp
    ret

scrolldown:
    push bp
    mov bp, sp
    sub sp, 800
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
    mov bx, ax              ; BX = bytes in the n rows

    ; 1) save bottom rows: video -> local array
    mov ax, 0xb800
    mov ds, ax
    mov ax, ss
    mov es, ax
    lea di, [bp-800]
    mov si, 4000
    sub si, bx
    mov cx, bx
    shr cx, 1
    cld
    rep movsw

    ; 2) shift remaining screen down (copy backwards)
    mov ax, 0xb800
    mov es, ax
    mov si, 4000
    sub si, bx
    sub si, 2               ; last word of the block being moved
    mov di, 3998            ; last word of the screen
    mov cx, 4000
    sub cx, bx
    shr cx, 1
    std
    rep movsw
    cld

    ; 3) saved rows -> top of screen
    mov ax, ss
    mov ds, ax
    lea si, [bp-800]
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
    mov sp, bp
    pop bp
    ret

delay:
    push cx
    push dx
    mov dx, 20
outer:
    mov cx, 0xffff
inner:
    loop inner
    dec dx
    jnz outer
    pop dx
    pop cx
    ret

start:
    call clrscr
    call printchars

forever:
    mov bx, 5
up:                         ; scroll 5 rows up, one at a time
    mov ax, 1
    call scrollup
    call delay
    dec bx
    jnz up

    mov bx, 3
down:                       ; scroll 3 rows down, one at a time
    mov ax, 1
    call scrolldown
    call delay
    dec bx
    jnz down

    jmp forever             ; infinite loop (close DOSBox / Ctrl+C to quit)