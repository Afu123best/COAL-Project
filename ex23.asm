[org 0x0100]
jmp start

; ---------------------------------------------------------
; clrscr: clears the screen with a white background
; (space character, attribute 0x70 = white bg, black fg)
; ---------------------------------------------------------
clrscr:
    push ax
    push cx
    push di
    push es
    mov ax, 0xb800
    mov es, ax
    xor di, di
    mov ax, 0x7020          ; 0x70 = attribute, 0x20 = space
    mov cx, 2000            ; 80 x 25 characters
    cld
    rep stosw
    pop es
    pop di
    pop cx
    pop ax
    ret

; ---------------------------------------------------------
; printstar: prints a red '*' on a white background at (x, y)
; push x, push y, call printstar
; ---------------------------------------------------------
printstar:
    push bp
    mov bp, sp
    push ax
    push dx
    push di
    push es

    ; [bp+4] = y, [bp+6] = x
    mov ax, 0xb800
    mov es, ax
    mov ax, 80
    mul word [bp+4]         ; ax = y * 80
    add ax, [bp+6]          ; ax = y * 80 + x
    shl ax, 1               ; 2 bytes per character
    mov di, ax
    mov word [es:di], 0x742A ; 0x74 = red on white, 0x2A = '*'

    pop es
    pop di
    pop dx
    pop ax
    pop bp
    ret 4

; ---------------------------------------------------------
; triangle: push x1, y1, x2, y2, call triangle
; ---------------------------------------------------------
triangle:
    push bp
    mov bp, sp
    push ax
    push bx
    push cx

    ; [bp+4] = y2, [bp+6] = x2, [bp+8] = y1, [bp+10] = x1

    ; condition (a): x1 < x2 and y1 < y2
    mov ax, [bp+10]
    cmp ax, [bp+6]
    jae done                ; x1 >= x2, so print nothing
    mov ax, [bp+8]
    cmp ax, [bp+4]
    jae done                ; y1 >= y2, so print nothing

    ; condition (b): (x2 - x1) == (y2 - y1)
    mov ax, [bp+6]
    sub ax, [bp+10]         ; ax = x2 - x1
    mov bx, [bp+4]
    sub bx, [bp+8]          ; bx = y2 - y1
    cmp ax, bx
    jne done

    call clrscr             ; valid input, so clear the screen

    mov cx, ax              ; cx = d = x2 - x1
    xor bx, bx              ; bx = i = 0

draw:
    ; vertical side: (x1, y1 + i)
    push word [bp+10]
    mov ax, [bp+8]
    add ax, bx
    push ax
    call printstar

    ; horizontal side: (x1 + i, y2)
    mov ax, [bp+10]
    add ax, bx
    push ax
    push word [bp+4]
    call printstar

    ; hypotenuse: (x1 + i, y1 + i)
    mov ax, [bp+10]
    add ax, bx
    push ax
    mov ax, [bp+8]
    add ax, bx
    push ax
    call printstar

    inc bx
    cmp bx, cx
    jbe draw                ; repeat for i = 0 .. d

done:
    pop cx
    pop bx
    pop ax
    pop bp
    ret 8

; ---------------------------------------------------------
start:
    push word 7             ; x1
    push word 8             ; y1
    push word 10            ; x2
    push word 11            ; y2
    call triangle

    jmp $                   ; stay here (no int 0x21 allowed)