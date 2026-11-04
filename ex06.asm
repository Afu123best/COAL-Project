; reverse a string ($ is the terminator)
[org 0x0100]
jmp start

msg:     db 'HELLO$'
reverse: db 0,0,0,0,0,0 ; 5 characters + '$'

start:
    ; find the length (characters before the '$')
    mov si, 0
count:
    cmp byte [msg+si], '$'
    je found
    inc si
    jmp count

found: ; si = 5 here
    mov di, 0 ; index into reverse
    cmp si, 0
    je finish ; empty string: nothing to copy

copy:
    dec si ; step back to the previous character
    mov al, [msg+si]
    mov [reverse+di], al
    inc di
    cmp si, 0
    jne copy ; stop after index 0 has been copied

finish:
    mov byte [reverse+di], '$'

    mov ax, 4C00h
    int 0x21