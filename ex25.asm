; CATCH OR CRASH - PHASE I ONLY
; NASM 8088 / DOSBox
; Assemble: nasm -f bin CATCH_OR_CRASH_PHASE1.asm -o PHASE1.COM
; Run: PHASE1.COM
;
; ENTER = start the game
; S = add 5 points (score display test only)
; E = show the end screen
; ENTER = restart from the end screen
; ESC = quit from the end screen
;
; Phase I does NOT include player movement or falling objects.

[org 0x0100]
cpu 8086
jmp start

; ------------------------ DATA ------------------------
gameName    db 'CATCH OR CRASH',0
startText1  db 'Catch rewards and avoid bombs!',0
startText2  db 'Coin = 5   Gold = 10   Diamond = 15',0
startText3  db 'Bomb = instant game over',0
startPrompt db 'PRESS ENTER TO START',0

scoreLabel  db 'SCORE: ',0
scoreDigits db '00000',0
timeText    db 'TIME: 02:00',0
legendText  db 'o = 5     $ = 10     * = 15     X = BOMB',0
phaseText   db 'PHASE I DEMO: S = +5 POINTS   E = END SCREEN',0

endTitle    db 'G A M E   O V E R',0
finalLabel  db 'FINAL SCORE: ',0
endPrompt   db 'ENTER = RESTART        ESC = QUIT',0

; Each object occupies a 3x3 grid.
coinShape   db ' o ', 'ooo', ' o '
goldShape   db '$$$', '$ $', '$$$'
gemShape    db ' * ', '***', ' * '
bombShape   db 'XXX', 'X!X', 'XXX'
playerShape db '[ ]', '[_]', '|_|'

score       dw 0
secondsLeft dw 120
startLow    dw 0
startHigh   dw 0

; ---------------------- MAIN --------------------------
start:
    mov ax,cs
    mov ds,ax
    cld
    mov ax,0003h
    int 10h

showStart:
    call DrawStartScreen

waitEnter:
    mov ah,00h
    int 16h
    cmp al,13
    jne waitEnter

    mov word [score],0
    mov word [secondsLeft],120
    call FormatTime
    call DrawGameScreen

    ; Record starting BIOS clock ticks.
    mov ah,00h
    int 1Ah
    mov [startLow],dx
    mov [startHigh],cx

gameLoop:
    call UpdateTimer

    ; Check keyboard without blocking the timer.
    mov ah,01h
    int 16h
    jz gameLoop

    mov ah,00h
    int 16h

    cmp al,'s'
    je addDemoScore
    cmp al,'S'
    je addDemoScore
    cmp al,'e'
    je showEnd
    cmp al,'E'
    je showEnd
    jmp gameLoop

addDemoScore:
    add word [score],5
    call DrawScore
    jmp gameLoop

showEnd:
    call DrawEndScreen

waitEndKey:
    mov ah,00h
    int 16h
    cmp al,13
    je showStart
    cmp al,27
    jne waitEndKey

    mov ax,4C00h
    int 21h

; -------------------- SCREENS -------------------------
DrawStartScreen:
    call ClearScreen

    mov si,gameName
    mov dh,5
    mov dl,32
    mov bl,0Eh
    call DrawText

    mov si,startText1
    mov dh,9
    mov dl,23
    mov bl,0Fh
    call DrawText

    mov si,startText2
    mov dh,11
    mov dl,21
    call DrawText

    mov si,startText3
    mov dh,12
    mov dl,25
    call DrawText

    ; Display sample objects.
    mov si,coinShape
    mov dh,15
    mov dl,20
    mov bl,07h
    call Draw3x3

    mov si,goldShape
    mov dh,15
    mov dl,34
    mov bl,0Eh
    call Draw3x3

    mov si,gemShape
    mov dh,15
    mov dl,48
    mov bl,0Bh
    call Draw3x3

    mov si,startPrompt
    mov dh,21
    mov dl,30
    mov bl,0Ah
    call DrawText

    ret

DrawGameScreen:
    call ClearScreen

    mov si,gameName
    mov dh,1
    mov dl,31
    mov bl,0Eh
    call DrawText

    mov si,timeText
    mov dh,1
    mov dl,2
    mov bl,0Fh
    call DrawText

    call DrawScore

    mov si,legendText
    mov dh,3
    mov dl,18
    mov bl,07h
    call DrawText

    ; Coin - 5 points
    mov si,coinShape
    mov dh,7
    mov dl,8
    mov bl,07h
    call Draw3x3

    ; Gold - 10 points
    mov si,goldShape
    mov dh,11
    mov dl,28
    mov bl,0Eh
    call Draw3x3

    ; Diamond - 15 points
    mov si,gemShape
    mov dh,6
    mov dl,49
    mov bl,0Bh
    call Draw3x3

    ; Bomb - game-ending object
    mov si,bombShape
    mov dh,12
    mov dl,68
    mov bl,0Ch
    call Draw3x3

    ; Catcher - 3x3, stationary in Phase I.
    mov si,playerShape
    mov dh,20
    mov dl,39
    mov bl,0Ah
    call Draw3x3

    mov si,phaseText
    mov dh,24
    mov dl,13
    mov bl,0Fh
    call DrawText

    ret

DrawEndScreen:
    call ClearScreen

    mov si,endTitle
    mov dh,8
    mov dl,30
    mov bl,0Ch
    call DrawText

    mov si,finalLabel
    mov dh,12
    mov dl,28
    mov bl,0Eh
    call DrawText

    call FormatScore

    mov si,scoreDigits
    mov dh,12
    mov dl,41
    mov bl,0Eh
    call DrawText

    mov si,endPrompt
    mov dh,18
    mov dl,23
    mov bl,0Fh
    call DrawText

    ret

; ---------------- TIMER / SCORE -----------------------
UpdateTimer:
    push ax
    push bx
    push cx
    push dx

    mov ah,00h
    int 1Ah

    ; Calculate elapsed clock ticks.
    mov ax,dx
    mov bx,cx
    sub ax,[startLow]
    sbb bx,[startHigh]

    ; Handle BIOS clock rollover at midnight.
    test bx,8000h
    jz .elapsed
    add ax,00B0h
    adc bx,0018h

.elapsed:
    or bx,bx
    jnz .zero
    cmp ax,2184
    jae .zero

    ; Convert elapsed ticks into seconds.
    mov bx,10
    mul bx
    mov bx,182
    div bx

    mov bx,120
    sub bx,ax
    jmp .save

.zero:
    xor bx,bx

.save:
    cmp bx,[secondsLeft]
    je .done

    mov [secondsLeft],bx
    call FormatTime

    mov si,timeText
    mov dh,1
    mov dl,2
    mov bl,0Fh
    call DrawText

.done:
    pop dx
    pop cx
    pop bx
    pop ax
    ret

FormatTime:
    push ax
    push bx
    push dx

    mov ax,[secondsLeft]
    xor dx,dx
    mov bx,60
    div bx

    ; Minutes
    add al,'0'
    mov [timeText+7],al

    ; Seconds
    mov ax,dx
    mov bl,10
    div bl

    add al,'0'
    mov [timeText+9],al
    add ah,'0'
    mov [timeText+10],ah

    pop dx
    pop bx
    pop ax
    ret

DrawScore:
    call FormatScore

    mov si,scoreLabel
    mov dh,1
    mov dl,65
    mov bl,0Eh
    call DrawText

    mov si,scoreDigits
    mov dh,1
    mov dl,72
    mov bl,0Eh
    call DrawText

    ret

FormatScore:
    push ax
    push bx
    push cx
    push dx
    push di

    mov ax,[score]
    mov bx,10
    mov cx,5
    mov di,scoreDigits+4

.nextDigit:
    xor dx,dx
    div bx
    add dl,'0'
    mov [di],dl
    dec di
    loop .nextDigit

    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ---------------- VIDEO ROUTINES ----------------------
ClearScreen:
    push ax
    push cx
    push di
    push es

    mov ax,0B800h
    mov es,ax
    xor di,di
    mov ax,0720h
    mov cx,2000
    cld
    rep stosw

    pop es
    pop di
    pop cx
    pop ax
    ret

; Draw zero-terminated string.
; DS:SI = string
; DH = row, DL = column
; BL = color attribute
DrawText:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es

    mov ax,0B800h
    mov es,ax

    ; Offset = (row * 80 + column) * 2
    xor ax,ax
    mov al,dh
    mov cx,80
    mul cx
    xor cx,cx
    mov cl,dl
    add ax,cx
    shl ax,1
    mov di,ax

.nextChar:
    lodsb
    test al,al
    jz .finished

    mov ah,bl
    stosw
    jmp .nextChar

.finished:
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; Draw a 3x3 object.
; DS:SI = 9 bytes
; DH = top row, DL = left column
; BL = color attribute
Draw3x3:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es

    mov ax,0B800h
    mov es,ax

    ; Calculate first screen location.
    xor ax,ax
    mov al,dh
    mov cx,80
    mul cx
    xor cx,cx
    mov cl,dl
    add ax,cx
    shl ax,1
    mov di,ax

    mov dx,3

.nextRow:
    mov cx,3

.nextColumn:
    lodsb
    mov ah,bl
    stosw
    loop .nextColumn

    ; Move to same starting column on next row.
    add di,154
    dec dx
    jnz .nextRow

    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret