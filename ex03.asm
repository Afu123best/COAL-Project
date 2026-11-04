[org 0x0100]
jmp start

oldoff: dw 0                ; saved original vector (offset)
oldseg: dw 0                ; saved original vector (segment)
msg:    db 'hello world', 0

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

printstr_isr:
    sti
    push ax
    push bx
    push si
    push ds

    push cs                 ; make sure DS = code segment
    pop ds                  ; (SI is an offset into this segment)

    mov ah, 0x02            ; set cursor position
    mov bh, 0               ; page 0
    int 0x10                ; DH = row, DL = col already set

nextchar:
    lodsb                   ; AL = [DS:SI], SI++
    cmp al, 0
    je done
    mov ah, 0x0e            ; teletype output
    mov bh, 0
    mov bl, 0x07
    int 0x10
    jmp nextchar

done:
    pop ds
    pop si
    pop bx
    pop ax
    iret

hook:
    push ax
    push es
    xor ax, ax
    mov es, ax              ; ES = 0 (interrupt vector table)
    mov ax, [es:0x60*4]     ; old offset
    mov [oldoff], ax
    mov ax, [es:0x60*4+2]   ; old segment
    mov [oldseg], ax
    cli
    mov word [es:0x60*4], printstr_isr
    mov [es:0x60*4+2], cs
    sti
    pop es
    pop ax
    ret

unhook:
    push ax
    push es
    xor ax, ax
    mov es, ax
    cli
    mov ax, [oldoff]
    mov [es:0x60*4], ax
    mov ax, [oldseg]
    mov [es:0x60*4+2], ax
    sti
    pop es
    pop ax
    ret

waitkey:
    push ax
    mov ah, 0x00
    int 0x16
    pop ax
    ret

start:
    call hook               ; install INT 0x60
    call clrscr

    ;  first line, first column ----
    mov si, msg
    mov dh, 0               ; row 0
    mov dl, 0               ; column 0
    int 0x60
    call waitkey            ; pause so the output can be seen
    call clrscr

    ; 10th line, 45th column ----
    mov si, msg
    mov dh, 9               ; 10th line (0-based = 9)
    mov dl, 44              ; 45th column (0-based = 44)
    int 0x60
    call waitkey
    call clrscr

    ; three lines, keyboard wait between them 
    mov si, msg
    mov dh, 0
    mov dl, 0
    int 0x60                ; line 1
    call waitkey            ; wait for a key (INT 16h)

    mov si, msg
    mov dh, 1
    mov dl, 0
    int 0x60                ; line 2
    call waitkey

    mov si, msg
    mov dh, 2
    mov dl, 0
    int 0x60                ; line 3
    call waitkey
    call clrscr

    call unhook             ; restore the original vector

    mov ax, 0x4c00
    int 0x21