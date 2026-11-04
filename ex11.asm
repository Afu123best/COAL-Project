; maximum and minimum number from an array of 10 numbers
[org 0x0100]
    jmp start
arr: db 5,8,6,2,4,7,1,10,11,12
max: db 0
min: db 255
start:
    mov bx, 0

loop1:
    mov al, [arr+bx]
    cmp al, [max] ; if al >= max
    jnc changeMax

    cmp al, [min] ; if al <= min
    jna changeMin

    ; no jump
    inc bx
    cmp bx, 11
    je end
    jmp loop1

changeMax:
    mov [max], al
    inc bx
    cmp bx, 11
    je end
    
    jmp loop1

changeMin:
    mov [min], al
    inc bx
    cmp bx, 11
    je end

    jmp loop1

end:
    mov ax, 4C00h
    int 0x21