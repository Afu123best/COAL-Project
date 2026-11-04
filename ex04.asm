[org 0x0100]
jmp start

msg_a:     db 'Hi, You pressed a$'
msg_b:     db 'Hi, You pressed b$'
msg_wrong: db 'Hi, You entered wrong credentials$'

; clrscr: clear screen using rep stosw
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




start:
    ;  First keystroke: any key clears the screen 
    mov ah, 0x00
    int 0x16                ; wait for key (AL = ASCII)
    call clrscr

    ; put the cursor back at row 0, column 0
    mov ah, 0x02
    mov bh, 0
    xor dx, dx
    int 0x10

    ; ---- Second keystroke ----
    mov ah, 0x00
    int 0x16                ; AL = key pressed

    cmp al, 'a'
    je  pressed_a
    cmp al, 'b'
    je  pressed_b

    mov dx, msg_wrong       ; any other key
    jmp show

pressed_a:
    mov dx, msg_a
    jmp show

pressed_b:
    mov dx, msg_b

show:
    mov ah, 0x09            ; DOS print '$'-terminated string at DS:DX
    int 0x21

    ; ---- Terminate ----
    mov ax, 0x4c00
    int 0x21