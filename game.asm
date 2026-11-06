[org 0x0100]
jmp start

; game title will be at Row 0, Column 2
; timer Row 0, Column 48
; Score	Row 0, Column 64
; Top boundary	Row 1
; Bottom boundary	Row 24
; Side boundaries	Columns 0 and 79
; Row 0: HUD (title, timer, score).
; Row 1: Top boundary.
; Rows 2–23: Playing area.
; Row 24: Bottom boundary.
; Columns 0 and 79: Side boundaries.

; DATA
bucket_sprite: ; player
    dw 0x0720, 0x0720, 0x0720 ; first row
    dw 0x077C, 0x0720, 0x077C ; second row
    dw 0x075C, 0x075F, 0x072F ; third row

small_bullet_sprite: ; 5 points
    dw 0x0720, 0x0E7C, 0x0720
    dw 0x0720, 0x0E7C, 0x0720
    dw 0x0720, 0x0E76, 0x0720

medium_bullet_sprite: ; 10 points
    dw 0x0720, 0x0B5E, 0x0720
    dw 0x0B5B, 0x0B7C, 0x0B5D
    dw 0x0720, 0x0B76, 0x0720

large_bullet_sprite: ; 15 points
    dw 0x0A2A, 0x0A2A, 0x0A2A
    dw 0x0A5B, 0x0A23, 0x0A5D
    dw 0x0720, 0x0A7C, 0x0720

bomb_sprite: ; end game
    dw 0x0720, 0x0C2A, 0x0720
    dw 0x0C28, 0x0C4F, 0x0C29
    dw 0x0C2D, 0x0C2D, 0x0C2D

title_text: db 'AMMO CATCHER', 0
score: dw 0
time_left: dw 120
time_label: db 'TIME:', 0
score_label: db 'SCORE:', 0

; FUNCTIONS


; draw sprite will take starting row, starting column and address of sprite data
; we'll simply change its column variable and call the same procedure.
draw_sprite:

    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx
    push si
    push di

    ; Calculate row offset

    mov ax, [bp+4]
    mov bx, 160
    mul bx

    mov di, ax

    ; Calculate column offset

    mov bx, [bp+6]
    shl bx, 1

    add di, bx

    ; Get sprite address

    mov si, [bp+8]

    ; Draw 3 rows

    cld
    mov dx, 3

draw_sprite_row:

    mov cx, 3

draw_sprite_col:

    lodsw
    stosw

    loop draw_sprite_col

    add di, 154

    dec dx
    jnz draw_sprite_row

    ; Restore registers

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax

    pop bp

    ret 6

draw_text:
    push bp
    mov bp, sp

    push ax
    push bx
    push dx
    push si
    push di

    ; calculate row offset
    mov ax, [bp+4]
    mov bx, 160
    mul bx
    mov di, ax

    ; column offset
    mov bx, [bp+6]
    shl bx, 1
    add di, bx

    ; text address
    mov si, [bp+8]
    ; color attribute
    mov ah, [bp+10]
    
    cld
draw_text_loop:
    lodsb
    cmp al, 0
    je draw_text_end
    stosw
    jmp draw_text_loop

draw_text_end:

    pop di
    pop si
    pop dx
    pop bx
    pop ax

    pop bp
    ret 8


draw_horizontal_line:
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push di

    ; calculate row offset
    mov ax, [bp+4]
    mov bx, 160
    mul bx
    mov di, ax

    ; col offset
    mov bx, [bp+6]
    shl bx, 1
    add di, bx

    ; character and length
    mov ax, [bp+10]
    mov cx, [bp+8]

    cld
    rep stosw

    pop di
    pop cx
    pop bx
    pop ax

    pop bp
    ret 8

draw_vertical_line:
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push di

    ; row offset
    mov ax, [bp+4]
    mov bx, 160
    mul bx
    mov di, ax
    
    ; col
    mov bx, [bp+6]
    shl bx, 1
    add di, bx

    ; character and length
    mov ax, [bp+10]
    mov cx, [bp+8]

    cld

draw_vertical_loop:
    stosw
    add di, 158

    loop draw_vertical_loop

    pop di
    pop cx
    pop bx
    pop ax

    pop bp
    ret 8

draw_number:
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx
    push si
    push di

    ; row
    mov ax, [bp+6]
    mov bx, 160
    mul bx
    mov di, ax

    ; col
    ; start from the right most digit
    mov bx, [bp+8]
    add bx, [bp+10]
    dec bx
    shl bx, 1
    add di, bx

    ; get number and digit count
    mov ax, [bp+4]
    mov cx, [bp+10]
    mov bx, 10

    ; draw digits right -> left
draw_number_loop:
    xor dx, dx
    div bx
    mov si, ax
    mov al, dl
    add al, 30h
    mov ah, [bp+12]
    mov [es:di], ax
    mov ax, si
    sub di, 2
    loop draw_number_loop

    pop di 
    pop si
    pop dx
    pop cx
    pop bx
    pop ax

    pop bp
    ret 10

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

; main
start:

    ; set 80x25 color text mode
    mov ax, 0003h
    int 10h

    ; set es to video memory
    mov ax, 0xb800
    mov es, ax


    call clear_screen
    
    ; top boundary
    mov ax, 0x0F2D
    push ax
    mov ax, 80
    push ax
    mov ax, 0
    push ax
    mov ax, 1
    push ax
    call draw_horizontal_line
    
    ; bottom boundary
    mov ax, 0x0F2D
    push ax
    mov ax, 80
    push ax
    mov ax, 0
    push ax
    mov ax, 24
    push ax
    call draw_horizontal_line

    ; left boundary
    mov ax, 0x0F7C
    push ax
    mov ax, 22
    push ax
    mov ax, 0
    push ax
    mov ax, 2
    push ax
    call draw_vertical_line

    ; right boundary
    mov ax, 0x0F7C
    push ax
    mov ax, 22
    push ax
    mov ax, 79
    push ax
    mov ax, 2
    push ax
    call draw_vertical_line

    ; Draw bucket

    mov ax, bucket_sprite   
    push ax
    mov ax, 38
    push ax
    mov ax, 21
    push ax
    call draw_sprite


    ; Draw small bullet

    mov ax, small_bullet_sprite
    push ax
    mov ax, 12
    push ax
    mov ax, 4
    push ax
    call draw_sprite


    ; Draw medium bullet

    mov ax, medium_bullet_sprite
    push ax
    mov ax, 32
    push ax
    mov ax, 8
    push ax
    call draw_sprite


    ; Draw large bullet

    mov ax, large_bullet_sprite
    push ax
    mov ax, 52
    push ax
    mov ax, 4
    push ax
    call draw_sprite


    ; Draw bomb

    mov ax, bomb_sprite
    push ax
    mov ax, 65
    push ax
    mov ax, 12
    push ax
    call draw_sprite

    ; draw game title
    mov ax, 0x07
    push ax
    mov ax, title_text
    push ax
    mov ax, 2
    push ax
    mov ax, 0
    push ax
    call draw_text

    ; time label
    mov ax, 0x0F
    push ax
    mov ax, time_label
    push ax
    mov ax, 46
    push ax
    mov ax, 0
    push ax
    call draw_text

    ; time value
    mov ax, 0x0F
    push ax
    mov ax, 3
    push ax
    mov ax, 52
    push ax
    mov ax, 0
    push ax
    mov ax, [time_left]
    push ax
    call draw_number

    ; score label
    mov ax, 0x0F
    push ax
    mov ax, score_label
    push ax
    mov ax, 63
    push ax
    mov ax, 0
    push ax
    call draw_text

    ; score value
    mov ax, 0x0F
    push ax
    mov ax, 5
    push ax
    mov ax, 70
    push ax
    mov ax, 0
    push ax
    mov ax, [score]
    push ax
    call draw_number

    ; wait for a key
    mov ah, 00h
    int 16h

    ; exit 
    mov ax, 4C00h
    int 0x21