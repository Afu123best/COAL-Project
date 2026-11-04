; 4 bit multiplication algorithm
[org 0x0100]
    jmp start
multiplicand: db 13 ; 4 bit multiplicand
multiplier: db 5 ; 4 bit multiplier
result: db 0 ; 8 bit result


start:
    mov cl, 4 ; initialise bit count to 4
    mov bl, [multiplicand]
    mov dl, [multiplier]

checkBit:
    shr dl, 1 ; shift right most bit in carry flag
    jnc skip ; if carry flag = 0, then just skip

    add [result], bl ; accumulate result

skip:
    shl bl, 1 ; shift multiplicand left
    dec cl ; decrement bit count
    jnz checkBit ; repeat if bits left

    mov ax, 4C00h
    int 0x21
