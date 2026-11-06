[org 0x0100]
jmp start

; data
bucket_sprite:
    dw 0x0720, 0x0720, 0x0720 ; first row
    dw 0x077C, 0x0720, 0x077C ; second row
    dw 0x075C, 0x075F, 0x072F ; third row

; draw sprite will take starting row, starting column and address of sprite data
; we'll simply change its column variable and call the same procedure.
draw_sprite:
    push ax
    push bx
    push cx
    push dx
    push bp
    push si
    push di

    ; calculate column offset
    xor bh, bh
    mov bp, bx
    shl bp, 1

    ; calculate row offset
    xor ah, ah
    mov bx, 160
    mul bx

    add ax, bp
    mov di, ax

    ; draw 3 rows
    mov bp, 3
draw_sprite_row:
    mov cx, 3

draw_sprite_col:
    lodsw
    stosw
    loop draw_sprite_col

    add di, 154
    dec bp
    jnz draw_sprite_row

    pop di
    pop si
    pop bp
    pop dx
    pop cx
    pop bx
    pop ax
    
    ret


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
    mov ax, 0003h
    int 10h

    ; set es to video memory
    mov ax, 0xb800
    mov es, ax


    call clear_screen
    mov al, 21
    mov bl, 38
    mov si, bucket_sprite

    call draw_sprite

    ; wait for a key
    mov ah, 00h
    int 16h

    ; exit 
    mov ax, 4C00h
    int 0x21