[org 0x0100]
jmp start

start:
    mov ax, 0xb800
    mov ds, ax              ; source segment = video memory
    mov es, ax              ; destination segment = video memory

    xor si, si              ; source: row 0 (offset 0)
    mov di, 2080            ; destination: row 13 (13 * 160)
    mov cx, 960             ; 12 rows * 80 words per row
    cld                     ; copy forward
    rep movsw

    mov ah, 0               ; wait for a key so the result stays visible
    int 0x16

    mov ax, 0x4c00          ; exit
    int 0x21