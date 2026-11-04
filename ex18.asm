; Difference A - B: store every A[i] that does NOT appear in B into C
; Output: C = elements only in A, BX = how many were stored
[org 0x0100]
    jmp start               ; skip over the data

A:     db 2,5,7,9
B:     db 1,5,8,9
sizeA: db 4
sizeB: db 4
C:     db 0,0,0,0           ; result array (at most sizeA entries)

start:
    mov si, 0               ; si = index into A
    mov bx, 0               ; bx = index into C (also the count)
    mov cl, [sizeA]
    mov ch, 0               ; CX = sizeA as a 16-bit value
    mov dl, [sizeB]
    mov dh, 0               ; DX = sizeB as a 16-bit value

outer:
    mov di, 0               ; restart at B[0] for every A[i]
    mov ah, [A+si]          ; AH = A[i]
    mov al, 0               ; found = false (reset for every A[i])

inner:
    cmp di, dx              ; compare j with sizeB
    jae check               ; j >= sizeB: B fully scanned, decide
    cmp ah, [B+di]          ; A[i] == B[j]?
    je matched              ; yes: remember it
    inc di                  ; no: j++
    jmp inner               ; check the next B element

matched:
    mov al, 1               ; found = true, stop scanning (falls into check)

check:
    cmp al, 0               ; was A[i] found in B?
    je place                ; no: A[i] is only in A, store it
                            ; yes: fall through and skip the store
next:
    inc si                  ; i++
    cmp si, cx              ; compare i with sizeA
    jb outer                ; i < sizeA: handle the next A[i]
    jmp end                 ; all of A processed

place:
    mov [C+bx], ah          ; C[count] = A[i]
    inc bx                  ; count++
    jmp next

end:
    mov ax, 4C00h           ; DOS function 4Ch: terminate, return code 0
    int 0x21