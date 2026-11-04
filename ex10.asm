[org 0x0100]
jmp start
arr: db 1,1,2,2,2,2,4,4,4,4,4
count: dw 11 ; There are total 11 elements in array
greatestNumber: db 0
greatestNumberCount: db 0

start: 
    mov cx, 10
    mov bx, arr
    mov dl, 1
loop1:
    mov al, [bx]
    cmp al, [bx+1]
    je equal
    jne notEqual

equal:
    inc dl
    dec cx
    add bx,1
    cmp cx, 0
    je checkLast
    jmp loop1

notEqual:
    add bx,1
    dec cx
    cmp greatestNumberCount, dl
    ; if greatestNumberCount < dl
    jc meow
    mov dl, 1
    cmp cx, 0
    je end
    jmp loop1


meow:
    ; greatestNumberCount = dl
    ; greatestNumber = ax
    mov greatestNumberCount, dl
    mov greatestNumber, al
    mov dl, 1
    cmp cx, 0
    je end
    jmp loop1

checkLast:
    cmp greatestNumberCount, dl
    jc updateAndEnd
    jmp end

updateAndEnd:
    mov greatestNumberCount, dl
    mov greatestNumber, al
    jmp end

end:
    mov ax, 4C00h
    int 0x21