; Two Sum: find i < j such that array[i] + array[j] == target
; Output: BX = i, DX = j
[org 0x0100]
jmp start                   ; skip over the data

array:  db 11,2,7,15
size:   db 4
target: db 9

found:
    ; BX already holds i
    mov dx, si              ; DX = j
    jmp end

start:
    mov dl, [size]          ; DL = size (byte)
    mov dh, 0               ; zero DH so DX = size as a 16-bit value
    mov bx, 0               ; i = 0

outer:
    mov si, bx              ; j = i (inc below makes it i+1)
    mov al, [array+bx]      ; AL = A[i]

inner:
    inc si                  ; j++
    cmp si, dx              ; compare j with size
    jnc next                ; j >= size: no more j for this i, go to next i
    mov cl, [array+si]      ; CL = A[j] (safe, j is in range)
    add cl, al              ; CL = A[i] + A[j]
    cmp cl, [target]        ; sum == target?
    je found                ; yes: BX = i, SI = j
    jmp inner               ; no: try next j

next:
    inc bx                  ; i++
    cmp bx, dx              ; compare i with size
    jl outer                ; i < size: repeat outer loop

end:
    mov ax, 4C00h           ; DOS function: terminate program
    int 0x21