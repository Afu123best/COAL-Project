[org 0x0100]
jmp start

x1 dw 10
y1 dw 5
x2 dw 20
y2 dw 15

; ---------- (i) validity check ----------
; Stack on entry (top to bottom): ret, y2, x2, y1, x1, result slot
; [bp+4]=y2  [bp+6]=x2  [bp+8]=y1  [bp+10]=x1  [bp+12]=result
checktriangle:
    push bp
    mov bp, sp
    push ax
    push bx
    mov word [bp+12], 0        ; assume invalid
    mov ax, [bp+10]            ; x1
    cmp ax, [bp+6]             ; x1 < x2 ?
    jae ctend
    mov bx, [bp+8]             ; y1
    cmp bx, [bp+4]             ; y1 < y2 ?
    jae ctend
    mov ax, [bp+6]
    sub ax, [bp+10]            ; x2 - x1
    mov bx, [bp+4]
    sub bx, [bp+8]             ; y2 - y1
    cmp ax, bx                 ; equal sides?
    jne ctend
    mov word [bp+12], 1        ; valid
ctend:
    pop bx
    pop ax
    pop bp
    ret 8

; ---------- (ii) clear screen with white background ----------
clrscr:
    push es
    push ax
    push cx
    push di
    mov ax, 0xb800
    mov es, ax
    xor di, di
    mov ax, 0x7020             ; space, black on white
    mov cx, 2000
    cld
    rep stosw
    pop di
    pop cx
    pop ax
    pop es
    ret

; ---------- (iii) generic subroutine: print one red asterisk ----------
; [bp+4]=y  [bp+6]=x
printstar:
    push bp
    mov bp, sp
    push es
    push ax
    push dx
    push di
    mov ax, 0xb800
    mov es, ax
    mov ax, 80
    mul word [bp+4]            ; y * 80
    add ax, [bp+6]             ; + x
    shl ax, 1                  ; * 2 bytes per cell
    mov di, ax
    mov word [es:di], 0x742A   ; '*' (2Ah) red on white
    pop di
    pop dx
    pop ax
    pop es
    pop bp
    ret 4

; ---------- (iii) draw triangle boundary using loops ----------
; [bp+4]=y2  [bp+6]=x2  [bp+8]=y1  [bp+10]=x1
drawtriangle:
    push bp
    mov bp, sp
    push bx
    push dx

    ; vertical side: x = x1, y = y1 .. y2
    mov bx, [bp+10]
    mov dx, [bp+8]
vloop:
    push bx
    push dx
    call printstar
    inc dx
    cmp dx, [bp+4]
    jbe vloop

    ; horizontal side: y = y2, x = x1 .. x2
    mov bx, [bp+10]
    mov dx, [bp+4]
hloop:
    push bx
    push dx
    call printstar
    inc bx
    cmp bx, [bp+6]
    jbe hloop

    ; hypotenuse: (x1,y1) -> (x2,y2)
    mov bx, [bp+10]
    mov dx, [bp+8]
dloop:
    push bx
    push dx
    call printstar
    inc bx
    inc dx
    cmp bx, [bp+6]
    jbe dloop

    pop dx
    pop bx
    pop bp
    ret 8

; ---------- (iv) main program ----------
start:
    push word 0                ; space for result
    push word [x1]
    push word [y1]
    push word [x2]
    push word [y2]
    call checktriangle
    pop ax                     ; ax = 1 if valid, 0 otherwise
    cmp ax, 1
    jne done                   ; invalid: print nothing

    call clrscr

    push word [x1]
    push word [y1]
    push word [x2]
    push word [y2]
    call drawtriangle

    mov ah, 0                  ; wait for a key so the output stays visible
    int 0x16
done:
    mov ax, 0x4c00
    int 0x21