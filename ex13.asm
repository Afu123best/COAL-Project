[org 0x0100]
    jmp start
arr: dw 5,7,9,10,11
target: dw 9
found: db 0

start:
    mov ax, 0 ; left
    mov bx, 8 ; right
    mov dx, [target]
loop1:
    ; if left > right, then leave the loop
    cmp ax, bx
    ja check

    mov cx, ax 
    add cx, bx ; left + right
    shr cx, 1 ; (left + right) / 2
    ; cx is mid

    ; if mid == target
    cmp [arr + cx], dx
    je equal
    ; if mid > target
    cmp [arr + cx], dx
    ja changeRight ; right = mid
    jmp changeLeft ; left = mid

changeRight:
    sub cx
    sub cx
    mov bx, cx
    jmp loop1

changeLeft:
    inc ax
    inc ax
    mov ax, cx
    jmp loop1

equal:
    mov ax, [arr+cx]
    mov [found], 1
    jmp check

check:
    ; if found == 0
    cmp [found], 0
    je notFound
    jmp end
notFound:
    mov ax, 0
    jmp end

end:
    mov ax, 4C00h
    int 0x21