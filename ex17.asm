; Intersection: store every A[i] that also appears in B into C
; Each A[i] is stored at most once (we stop scanning B after the first match)
; Output: C = common elements, BX = how many were found
[org 0x0100]
    jmp start               ; skip over the data

A:     db 2,5,7,9
B:     db 1,5,8,9
sizeA: db 4
sizeB: db 4
C:     db 0,0,0,0           ; result array (at most sizeA entries)

start:
    mov si, 0               ; si = index into A
    mov bx, 0               ; bx = index into C (also the count of matches)
    mov cl, [sizeA]
    mov ch, 0               ; CX = sizeA as a 16-bit value
    mov dl, [sizeB]
    mov dh, 0               ; DX = sizeB as a 16-bit value

outer:
    mov di, 0               ; restart at B[0] for every A[i]
    mov ah, [A+si]          ; AH = A[i], compared against every B[j]

inner:
    cmp di, dx              ; compare j with sizeB
    jnc next                ; j >= sizeB: B exhausted, move to next A[i]
    cmp ah, [B+di]          ; A[i] == B[j]?
    je intersect            ; yes: record it
    inc di                  ; no: j++
    jmp inner               ; check the next B element

next:
    inc si                  ; i++
    cmp si, cx              ; compare i with sizeA
    jnc end                 ; i >= sizeA: all of A processed, finish
    jmp outer               ; otherwise handle the next A[i]

intersect:
    mov [C+bx], ah          ; C[count] = A[i]
    inc bx                  ; count++
    jmp next                ; first match is enough, skip the rest of B

end:
    mov ax, 4C00h           ; DOS function 4Ch: terminate, return code 0
    int 0x21