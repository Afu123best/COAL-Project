[org 0x0100]
jmp start

array: db 5,7,9,10,15
size: dw 5
target: db 7

found:
    mov ax, 1
    jmp end

changeRight:
    mov di, bx
    dec di
    jmp loop1

changeLeft:
    mov si, bx
    inc si
    jmp loop1

start:
    mov si, 0 ; left = si
    mov di, [size]; right = di
    dec di ; right is INDEX
    mov ax, 0 ; not found. ax is the flag
    mov dl, [target] ; dl = target

loop1:
    cmp si, di
    ja end
    mov bx, si ; calculate mid, bx = mid
    add bx, di ; bx = left + right
    shr bx, 1 ; bx = (left + right) / 2
    cmp [array+bx], dl ; if (array[mid] == target)
    je found
    cmp [array+bx], dl ; if (array[mid] > target)
    jg changeRight
    jmp changeLeft

end:
    mov ax, 4C00h
    int 0x21