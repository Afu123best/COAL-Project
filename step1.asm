; ============================================================
; Step 1: two players, two rectangles, one keyboard
;   Player 1: W A S D       Player 2: arrow keys       Esc: quit
; Build:  nasm -f bin step1.asm -o step1.com
; Run:    in DOSBox, type  step1
; 8086 instructions only (no push imm, no shl reg,imm other than 1)
; ============================================================
[org 0x0100]
    jmp start                   ; skip over data and procedures

SPEED   equ 2                   ; pixels moved per frame
MAX_X   equ 304                 ; 320 - 16 (rectangle width)
MAX_Y   equ 184                 ; 200 - 16 (rectangle height)
KEY_ESC equ 01h

; ---------- data ----------
; player layout: +0 x (dw), +2 y (dw), +4 up, +5 down, +6 left, +7 right, +8 color
p1: dw 40, 92
    db 11h, 1Fh, 1Eh, 20h, 12   ; W S A D, red
p2: dw 264, 92
    db 48h, 50h, 4Bh, 4Dh, 11   ; Up Down Left Right, cyan

keys:    times 128 db 0         ; keys[scancode] = 1 while that key is held
old_off: dw 0                   ; saved original keyboard handler
old_seg: dw 0

; ---------- keyboard interrupt handler (runs on every key press/release) ----------
new_isr:
    push ax
    push bx
    in al, 60h                  ; AL = scancode (bit 7 set = key released)
    mov bl, al
    and bl, 7Fh                 ; BL = scancode without the release bit
    mov bh, 0                   ; BX = table index
    test al, 80h
    jnz .released
    mov byte [cs:keys+bx], 1    ; pressed: mark down
    jmp .done
.released:
    mov byte [cs:keys+bx], 0    ; released: mark up
.done:
    mov al, 20h
    out 20h, al                 ; tell the interrupt controller we're finished
    pop bx
    pop ax
    iret

; ---------- wait_vsync: block until the start of a vertical retrace ----------
wait_vsync:
    push ax
    push dx
    mov dx, 3DAh
.wait_end:                      ; if we're already in a retrace, wait for it to end
    in al, dx
    test al, 8
    jnz .wait_end
.wait_start:                    ; then wait for the next one to begin
    in al, dx
    test al, 8
    jz .wait_start
    pop dx
    pop ax
    ret

; ---------- draw_player: BX = player, AL = color; draws a 16x16 square ----------
draw_player:
    push ax
    push cx
    push dx
    push di
    mov di, [bx+2]              ; DI = y
    mov dx, di                  ; DX = y
    mov cl, 8
    shl di, cl                  ; DI = y * 256
    mov cl, 6
    shl dx, cl                  ; DX = y * 64
    add di, dx                  ; DI = y * 320
    add di, [bx]                ; DI = y * 320 + x  (pixel offset in video memory)
    mov dx, 16                  ; DX = rows left to draw
.row:
    mov cx, 16
    rep stosb                   ; one row of 16 pixels, DI advances by 16
    add di, 304                 ; jump to the start of the next row (320 - 16)
    dec dx
    jnz .row
    pop di
    pop dx
    pop cx
    pop ax
    ret

; ---------- move_player: BX = player; reads the keys table, then clamps to screen ----------
move_player:
    push ax
    push si
    mov ah, 0                   ; AH stays 0 so AX = AL below

    mov al, [bx+4]              ; up key
    mov si, ax
    cmp byte [keys+si], 0
    je .no_up
    sub word [bx+2], SPEED
.no_up:
    mov al, [bx+5]              ; down key
    mov si, ax
    cmp byte [keys+si], 0
    je .no_down
    add word [bx+2], SPEED
.no_down:
    mov al, [bx+6]              ; left key
    mov si, ax
    cmp byte [keys+si], 0
    je .no_left
    sub word [bx], SPEED
.no_left:
    mov al, [bx+7]              ; right key
    mov si, ax
    cmp byte [keys+si], 0
    je .no_right
    add word [bx], SPEED
.no_right:

    cmp word [bx], 0            ; clamp x to 0..MAX_X
    jge .x_lo_ok
    mov word [bx], 0
.x_lo_ok:
    cmp word [bx], MAX_X
    jle .x_hi_ok
    mov word [bx], MAX_X
.x_hi_ok:
    cmp word [bx+2], 0          ; clamp y to 0..MAX_Y
    jge .y_lo_ok
    mov word [bx+2], 0
.y_lo_ok:
    cmp word [bx+2], MAX_Y
    jle .y_hi_ok
    mov word [bx+2], MAX_Y
.y_hi_ok:
    pop si
    pop ax
    ret

; ---------- main program ----------
start:
    ; save the original keyboard handler (interrupt 9), then install ours
    mov ax, 3509h
    int 21h                     ; returns the old vector in ES:BX
    mov [old_off], bx
    mov [old_seg], es
    mov dx, new_isr
    mov ax, 2509h
    int 21h                     ; set interrupt 9 to DS:DX

    mov ax, 0013h
    int 10h                     ; video mode 13h: 320x200, 256 colors
    mov ax, 0A000h
    mov es, ax                  ; ES = video memory segment
    cld                         ; make rep stosb move forward

game_loop:
    call wait_vsync             ; keeps the speed steady

    mov al, 0                   ; erase both squares at their old positions
    mov bx, p1
    call draw_player
    mov bx, p2
    call draw_player

    mov bx, p1                  ; update positions from the keys
    call move_player
    mov bx, p2
    call move_player

    mov bx, p1                  ; draw both squares at their new positions
    mov al, [bx+8]
    call draw_player
    mov bx, p2
    mov al, [bx+8]
    call draw_player

    cmp byte [keys+KEY_ESC], 0
    je game_loop                ; Esc not held: next frame

    ; ---- cleanup: restore text mode and the original keyboard handler ----
    mov ax, 0003h
    int 10h
    mov dx, [old_off]
    mov ax, [old_seg]
    push ds
    mov ds, ax
    mov ax, 2509h
    int 21h                     ; interrupt 9 = old_seg:old_off
    pop ds
    mov ax, 4C00h               ; DOS terminate, return code 0
    int 21h