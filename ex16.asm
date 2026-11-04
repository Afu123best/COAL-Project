; Two Sum (count pairs): count i < j with array[i] + array[j] == target
; Output: BX = count
[org 0x0100]
jmp start

array:  db 1,5,4,6,3,2
size:   db 6
target: db 7

incrementCount:
    inc bx                  ; count++
    jmp inner               ; keep scanning

start:
    mov bx, 0               ; count = 0
    mov di, 0               ; i = 0
    mov dl, [size]
    mov dh, 0               ; DX = size (16-bit)

outer:
    mov si, di              ; j = i (inc below makes it i+1)
    mov al, [array+di]      ; AL = A[i]

inner:
    inc si                  ; j++
    cmp si, dx
    jnc next                ; j >= size: next i
    mov cl, [array+si]      ; CL = A[j]
    add cl, al              ; CL = A[i] + A[j]
    cmp cl, [target]
    je incrementCount       ; match: count++
    jmp inner

next:
    inc di                  ; i++
    cmp di, dx
    jl outer                ; i < size: repeat

    mov ax, 4C00h           ; terminate program
    int 0x21