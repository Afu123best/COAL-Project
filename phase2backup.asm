[org 0x0100]
jmp start

; function convention = 
; function_name:
; labels inside the function = function_name_label_name
; for less confusiong when using jumps lol
; game title will be at Row 0, Column 2
; timer Row 0, Column 48
; Score	Row 0, Column 64
; Top boundary	Row 1
; Bottom boundary	Row 24
; Side boundaries	Columns 0 and 79
; Row 0: HUD (title, timer, score).
; Row 1: Top boundary.
; Rows 2–23: Playing area.
; Row 24: Bottom boundary.
; Columns 0 and 79: Side boundaries.

; DATA
bucket_sprite: ; player
    dw 0x0720, 0x0720, 0x0720 ; first row
    dw 0x077C, 0x0720, 0x077C ; second row
    dw 0x075C, 0x075F, 0x072F ; third row

empty_sprite:
    dw 0x0720, 0x0720, 0x0720
    dw 0x0720, 0x0720, 0x0720
    dw 0x0720, 0x0720, 0x0720

small_bullet_sprite: ; 5 points
    dw 0x0720, 0x0E7C, 0x0720
    dw 0x0720, 0x0E7C, 0x0720
    dw 0x0720, 0x0E76, 0x0720

medium_bullet_sprite: ; 10 points
    dw 0x0720, 0x0B5E, 0x0720
    dw 0x0B5B, 0x0B7C, 0x0B5D
    dw 0x0720, 0x0B76, 0x0720

large_bullet_sprite: ; 15 points
    dw 0x0A2A, 0x0A2A, 0x0A2A
    dw 0x0A5B, 0x0A23, 0x0A5D
    dw 0x0720, 0x0A7C, 0x0720

bomb_sprite: ; end game
    dw 0x0720, 0x0C2A, 0x0720
    dw 0x0C28, 0x0C4F, 0x0C29
    dw 0x0C2D, 0x0C2D, 0x0C2D

title_text: db 'AMMO CATCHER', 0
score: dw 0
time_left: dw 120
game_end_reason: db 0 ; 0 = timer expired, 1 = bomb caught
time_label: db 'TIME:', 0
score_label: db 'SCORE:', 0

bucket_col: dw 38

start_subtitle: db 'CATCH BULLETS. AVOID BOMBS!', 0
small_points_text: db '5 POINTS', 0
medium_points_text: db '10 POINTS', 0
large_points_text: db '15 POINTS', 0
avoid_text: db 'AVOID!', 0
controls_text: db 'USE LEFT AND RIGHT ARROW KEYS', 0
press_enter_text: db 'PRESS ENTER TO START', 0
bomb_caught_text: db 'BOMB CAUGHT!', 0

; timer ticks
last_tick_low: dw 0 ; previous clock tick lower word
last_tick_high: dw 0 ; previous clock tick upper word
ticks_to_second: db 18 ; count ticks to next second

; object falling ticks
last_fall_tick_low: dw 0
last_fall_tick_high: dw 0
ticks_to_fall: db 4 ; 4/18.2 = approximately 0.22 seconds
; if we wanna icnrease difficulty than we decrease this number

game_over_text: db 'GAME OVER', 0
time_up_text: db "TIME'S UP!", 0
final_score_text: db 'FINAL SCORE:', 0
exit_text: db 'PRESS ANY KEY TO EXIT', 0

; Falling objects positions
small_row: dw 4
small_col: dw 12

medium_row: dw 8
medium_col: dw 32

large_row: dw 4
large_col: dw 52

bomb_row: dw 12
bomb_col: dw 65

; FUNCTIONS

; draw sprite will take starting row, starting column and address of sprite data
; we'll simply change its column variable and call the same procedure.
draw_sprite:

    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx
    push si
    push di

    ; Calculate row offset

    mov ax, [bp+4]
    mov bx, 160
    mul bx

    mov di, ax

    ; Calculate column offset

    mov bx, [bp+6]
    shl bx, 1

    add di, bx

    ; Get sprite address

    mov si, [bp+8]

    ; Draw 3 rows

    cld
    mov dx, 3

    draw_sprite_row:

    mov cx, 3

    draw_sprite_col:

    lodsw
    stosw

    loop draw_sprite_col

    add di, 154

    dec dx
    jnz draw_sprite_row

    ; Restore registers

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax

    pop bp

    ret 6

draw_text:
    push bp
    mov bp, sp

    push ax
    push bx
    push dx
    push si
    push di

    ; calculate row offset
    mov ax, [bp+4]
    mov bx, 160
    mul bx
    mov di, ax

    ; column offset
    mov bx, [bp+6]
    shl bx, 1
    add di, bx

    ; text address
    mov si, [bp+8]
    ; color attribute
    mov ah, [bp+10]
    
    cld
    draw_text_loop:
    lodsb
    cmp al, 0
    je draw_text_end
    stosw
    jmp draw_text_loop

    draw_text_end:

    pop di
    pop si
    pop dx
    pop bx
    pop ax

    pop bp
    ret 8


    draw_horizontal_line:
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx
    push di

    ; calculate row offset
    mov ax, [bp+4]
    mov bx, 160
    mul bx
    mov di, ax

    ; col offset
    mov bx, [bp+6]
    shl bx, 1
    add di, bx

    ; character and length
    mov ax, [bp+10]
    mov cx, [bp+8]

    cld
    rep stosw

    pop di
    pop dx
    pop cx
    pop bx
    pop ax

    pop bp
    ret 8

draw_vertical_line:
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx
    push di

    ; row offset
    mov ax, [bp+4]
    mov bx, 160
    mul bx
    mov di, ax
    
    ; col
    mov bx, [bp+6]
    shl bx, 1
    add di, bx

    ; character and length
    mov ax, [bp+10]
    mov cx, [bp+8]

    cld

    draw_vertical_loop:
    stosw
    add di, 158

    loop draw_vertical_loop

    pop di
    pop dx
    pop cx
    pop bx
    pop ax

    pop bp
    ret 8

draw_number:
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx
    push si
    push di

    ; row
    mov ax, [bp+6]
    mov bx, 160
    mul bx
    mov di, ax

    ; col
    ; start from the right most digit
    mov bx, [bp+8]
    add bx, [bp+10]
    dec bx
    shl bx, 1
    add di, bx

    ; get number and digit count
    mov ax, [bp+4]
    mov cx, [bp+10]
    mov bx, 10

    ; draw digits right -> left
    draw_number_loop:
    xor dx, dx
    div bx
    mov si, ax
    mov al, dl
    add al, 30h
    mov ah, [bp+12]
    mov [es:di], ax
    mov ax, si
    sub di, 2
    loop draw_number_loop

    pop di 
    pop si
    pop dx
    pop cx
    pop bx
    pop ax

    pop bp
    ret 10


draw_bucket:
    push ax

    mov ax, bucket_sprite
    push ax

    mov ax, [bucket_col]
    push ax

    mov ax, 21
    push ax
    
    call draw_sprite

    pop ax

    ret


erase_bucket:
    push ax

    mov ax, empty_sprite
    push ax

    mov ax, [bucket_col]
    push ax

    mov ax, 21
    push ax

    call draw_sprite

    pop ax

    ret

move_bucket:
    push ax

    ; check whether a key is available
    mov ah, 01h
    int 16h

    jz move_bucket_done

    ; read the available key
    mov ah, 00h
    int 16h

    ; check for left arrow (<-)
    cmp ah, 4Bh 
    je move_bucket_left
    
    ; check for right arrow (->)
    cmp ah, 4Dh
    je move_bucket_right

    jmp move_bucket_done

    move_bucket_left:

    ; first check left boundary
    cmp word [bucket_col], 1 
    jbe move_bucket_done

    call erase_bucket
    
    dec word [bucket_col]
    
    call draw_bucket

    jmp move_bucket_done

    move_bucket_right:
    
    ; check right boundary
    cmp word [bucket_col], 76
    jae move_bucket_done

    call erase_bucket

    inc word [bucket_col]

    call draw_bucket

    move_bucket_done:

    pop ax

    ret


draw_falling_objects:
    push ax

    ; draw small bullet
    mov ax, small_bullet_sprite
    push ax
    mov ax, [small_col]
    push ax
    mov ax, [small_row]
    push ax
    call draw_sprite

    ; draw medium bullet
    mov ax, medium_bullet_sprite
    push ax
    mov ax, [medium_col]
    push ax
    mov ax, [medium_row]
    push ax
    call draw_sprite

    ; draw large bullet
    mov ax, large_bullet_sprite
    push ax
    mov ax, [large_col]
    push ax
    mov ax, [large_row]
    push ax
    call draw_sprite

    ; draw bomb
    mov ax, bomb_sprite
    push ax
    mov ax, [bomb_col]
    push ax
    mov ax, [bomb_row]
    push ax
    call draw_sprite

    pop ax

    ret


erase_falling_objects:
    push ax

    ; erase small bullet
    mov ax, empty_sprite
    push ax
    mov ax, [small_col]
    push ax
    mov ax, [small_row]
    push ax
    call draw_sprite

    ; erase medium bullet
    mov ax, empty_sprite
    push ax
    mov ax, [medium_col]
    push ax
    mov ax, [medium_row]
    push ax
    call draw_sprite

    ; erase large bulelt
    mov ax, empty_sprite
    push ax
    mov ax, [large_col]
    push ax
    mov ax, [large_row]
    push ax
    call draw_sprite
    
    ; erase bomb
    mov ax, empty_sprite
    push ax
    mov ax, [bomb_col]
    push ax
    mov ax, [bomb_row]
    push ax
    call draw_sprite

    pop ax

    ret


update_falling_objects:
    
    push ax
    push cx
    push dx

    ; read current BIOS clock ticks
    mov ah, 00h
    int 1Ah

    ; check whether a new tick has occurred
    cmp dx, [last_fall_tick_low]
    jne update_falling_objects_new_tick

    cmp cx, [last_fall_tick_high]
    je update_falling_objects_done

    update_falling_objects_new_tick:
    
    ; save current tick values
    mov [last_fall_tick_low], dx
    mov [last_fall_tick_high], cx

    ; count ticks until next movement
    dec byte [ticks_to_fall]
    jnz update_falling_objects_done

    ; rest falling speed counter
    mov byte [ticks_to_fall], 4

    ; erase objects at their old positions
    call erase_falling_objects

    ; move small bullet
    cmp word [small_row], 21
    jae update_small_reset

    inc word [small_row]
    jmp update_medium

    update_small_reset:
    mov word [small_row], 4

    
    ; move medium bullet
    update_medium:
    cmp word [medium_row], 21
    jae update_medium_reset

    inc word[medium_row]
    jmp update_large

    update_medium_reset:
    mov word [medium_row], 8

    
    ; move large bullet
    update_large:
    cmp word [large_row], 21
    jae update_large_reset

    inc word [large_row]
    jmp update_bomb

    update_large_reset:
    mov word [large_row], 4


    ; move bomb
    update_bomb:
    cmp word [bomb_row], 21
    jae update_bomb_reset

    inc word [bomb_row]
    jmp update_draw_objects

    update_bomb_reset:
    mov word [bomb_row], 12


    update_draw_objects:
    ; draw objects at their new positions
    call draw_falling_objects

    update_falling_objects_done:

    pop dx
    pop cx
    pop ax

    ret


; parameters
;[bp+4] = object row
;[bp+6] = object column
; returns:
; CF = 1 if collision is detected
; CF = 0 if collision is not detected
; collision detection : ObjectLeft <= BucketRight and ObjectRight >= BucketLeft
check_collision:
    push bp
    mov bp, sp

    push ax

    ; check vertical overlap
    ; calculate object's bottom row
    mov ax, [bp+4]
    add ax, 2

    ; compare with bucket's top row (21)
    cmp ax, 21
    jb check_collision_no

    ; compare object's top row with bucket's bottom row (23)
    mov ax, [bp+4]
    cmp ax, 23
    ja check_collision_no

    ; check horizontal overlap
    ; calculate object's right column
    mov ax, [bp+6]
    add ax, 2

    ; compare with bucket's left column

    cmp ax, [bucket_col]
    jb check_collision_no

    ; calculate bucket's right column

    mov ax, [bucket_col]
    add ax, 2

    ; compare with object's left column
    cmp ax, [bp+6]
    jb check_collision_no

    ; both vertical and horizontal overlap
    stc
    jmp check_collision_done


    check_collision_no:
    clc


    check_collision_done:

    pop ax
    pop bp
    ret 4


check_all_collisions:
    push ax

    ; check small bullet
    mov ax, [small_col]
    push ax
    mov ax, [small_row]
    push ax
    call check_collision
    ; basically jc small_collision_detected but due to the short jump being out of range we just write this
    jnc short check_small_no_collision
    jmp near small_collision_detected

    check_small_no_collision:

    ; check medium bullet
    mov ax, [medium_col]
    push ax
    mov ax, [medium_row]
    push ax
    call check_collision
    jnc short check_medium_no_collision_first
    jmp near medium_collision_detected

    check_medium_no_collision_first:

    ; check large bullet
    mov ax, [large_col]
    push ax
    mov ax, [large_row]
    push ax
    call check_collision
    jnc short check_large_no_collision_first
    jmp near large_collision_detected

    check_large_no_collision_first:

    ; check bomb
    mov ax, [bomb_col]
    push ax
    mov ax, [bomb_row]
    push ax
    call check_collision
    jnc short check_bomb_no_collision_first
    jmp near bomb_collision_detected

    check_bomb_no_collision_first:

    jmp check_all_collisions_done

    ; collision handlers (temporary reset)

    small_collision_detected:
    call erase_falling_objects
    ; add 5 points
    add word [score], 5
    ; update live score display
    call display_score
    ; reset small bullet
    mov word [small_row], 4
    call draw_falling_objects
    call draw_bucket

    jmp check_medium_collision

    check_medium_collision:
    mov ax, [medium_col]
    push ax
    mov ax, [medium_row]
    push ax
    call check_collision
    jnc short check_medium_no_collision_second
    jmp near medium_collision_detected

    check_medium_no_collision_second:

    jmp check_large_collision

    medium_collision_detected:
    call erase_falling_objects
    ; add 10 points
    add word [score], 10
    ; update live score display
    call display_score
    ; reset medium bullet
    mov word [medium_row], 8
    call draw_falling_objects
    call draw_bucket

    jmp check_large_collision

    check_large_collision:
    mov ax, [large_col]
    push ax
    mov ax, [large_row]
    push ax
    call check_collision
    jnc short check_large_no_collision_second
    jmp near large_collision_detected

    check_large_no_collision_second:

    jmp check_bomb_collision

    large_collision_detected:
    call erase_falling_objects
    ; add 15 points
    add word [score], 15
    ; update live score display
    call display_score
    ; reset large bullet
    mov word [large_row], 4
    call draw_falling_objects
    call draw_bucket

    jmp check_bomb_collision

    check_bomb_collision:
    mov ax, [bomb_col]
    push ax
    mov ax, [bomb_row]
    push ax
    call check_collision
    jnc short check_bomb_no_collision_second
    jmp near bomb_collision_detected

    check_bomb_no_collision_second:

    jmp check_all_collisions_done

    bomb_collision_detected:
    ; Set game-ending reason to bomb collision
    mov byte [game_end_reason], 1

    jmp check_all_collisions_done
    check_all_collisions_done:
    pop ax

    ret


start_screen:
    call clear_screen
    
    ; Game title
    mov ax, 0x0E
    push ax
    mov ax, title_text
    push ax
    mov ax, 34
    push ax
    mov ax, 4
    push ax
    call draw_text

    ; Subtitle
    mov ax, 0x0F
    push ax
    mov ax, start_subtitle
    push ax
    mov ax, 26
    push ax
    mov ax, 7
    push ax
    call draw_text

    ; small bullet
    mov ax, small_bullet_sprite
    push ax
    mov ax, 18
    push ax
    mov ax, 10
    push ax
    call draw_sprite

    ; medium bullet
    mov ax, medium_bullet_sprite
    push ax
    mov ax, 31
    push ax
    mov ax, 10
    push ax
    call draw_sprite

    ; large bullet
    mov ax, large_bullet_sprite
    push ax
    mov ax, 44
    push ax
    mov ax, 10
    push ax
    call draw_sprite

    ; bomb
    mov ax, bomb_sprite
    push ax
    mov ax, 60
    push ax
    mov ax, 10
    push ax
    call draw_sprite

    ; small bullet points
    mov ax, 0x0F
    push ax
    mov ax, small_points_text
    push ax
    mov ax, 15
    push ax
    mov ax, 14
    push ax
    call draw_text

    ; medium bulelt points
    mov ax, 0x0F
    push ax
    mov ax, medium_points_text
    push ax
    mov ax, 28
    push ax
    mov ax, 14
    push ax
    call draw_text

    ; large bullet points
    mov ax, 0x0F
    push ax
    mov ax, large_points_text
    push ax
    mov ax, 41
    push ax
    mov ax, 14
    push ax
    call draw_text

    ; bomb warning
    mov ax, 0x0C
    push ax
    mov ax, avoid_text
    push ax
    mov ax, 58
    push ax
    mov ax, 14
    push ax
    call draw_text

    ; bucket
    mov ax, bucket_sprite
    push ax
    mov ax, 38
    push ax
    mov ax, 15
    push ax
    call draw_sprite

    ; controls
    mov ax, 0x0F
    push ax
    mov ax, controls_text
    push ax
    mov ax, 24
    push ax
    mov ax, 20
    push ax
    call draw_text

    ; enter prompt
    mov ax, 0x0E
    push ax
    mov ax, press_enter_text
    push ax
    mov ax, 30
    push ax
    mov ax, 22
    push ax
    call draw_text

    start_screen_wait:
    mov ah, 00h
    int 16h
    cmp al, 0x0D
    jne start_screen_wait
    ret

display_timer:
    push ax
    
    ; color attribute
    mov ax, 0x0F
    push ax

    ; number of digits
    mov ax, 3
    push ax

    ; column
    mov ax, 52
    push ax

    ; row
    mov ax, 0
    push ax
    
    ; current timer value
    mov ax, [time_left]
    push ax

    call draw_number

    pop ax
    ret


initialize_timer:

    push ax
    push cx
    push dx

    ; Initialize tick counter
    mov byte [ticks_to_second], 18

    ; Initialize falling speed counter
    mov byte [ticks_to_fall], 4

    ; Get initial BIOS clock ticks
    mov ah, 00h
    int 1Ah

    mov [last_tick_low], dx
    mov [last_tick_high], cx

    ; initialise falling object clock
    mov [last_fall_tick_low], dx
    mov [last_fall_tick_high], cx

    pop dx
    pop cx
    pop ax

    ret

update_timer:

    push ax
    push bx
    push cx
    push dx

    ; Read current BIOS clock ticks
    mov ah, 00h
    int 1Ah

    ; Check for a new tick
    cmp dx, [last_tick_low]
    jne new_tick

    cmp cx, [last_tick_high]
    je update_timer_end


    new_tick:

    ; Save current clock ticks
    mov [last_tick_low], dx
    mov [last_tick_high], cx

    ; Don't decrease below zero
    cmp word [time_left], 0
    je update_timer_end

    ; Count the tick
    dec byte [ticks_to_second]
    jnz update_timer_end

    ; One second has passed
    dec word [time_left]

    call display_timer

    ; Reset tick counter
    mov byte [ticks_to_second], 18


update_timer_end:

    pop dx
    pop cx
    pop bx
    pop ax

    ret

clear_screen:
    push ax
    push cx
    push di

    xor di, di
    mov ax, 0x0720
    mov cx, 2000
    cld 
    rep stosw

    pop di
    pop cx
    pop ax
    ret


end_screen:

    call clear_screen

    ; GAME OVER
    mov ax, 0x0C
    push ax
    mov ax, game_over_text
    push ax
    mov ax, 35
    push ax
    mov ax, 7
    push ax
    call draw_text

    ; Check why the game ended
    cmp byte [game_end_reason], 1
    je short end_screen_bomb


    ; TIME'S UP
    mov ax, 0x0F
    push ax
    mov ax, time_up_text
    push ax
    mov ax, 35
    push ax
    mov ax, 9
    push ax
    call draw_text

    jmp end_screen_reason_done


    end_screen_bomb:

    ; BOMB CAUGHT
    mov ax, 0x0C
    push ax
    mov ax, bomb_caught_text
    push ax
    mov ax, 34
    push ax
    mov ax, 9
    push ax
    call draw_text


    end_screen_reason_done:

    ; FINAL SCORE label
    mov ax, 0x0F
    push ax
    mov ax, final_score_text
    push ax
    mov ax, 31
    push ax
    mov ax, 12
    push ax
    call draw_text

    ; FINAL SCORE value
    mov ax, 0x0F
    push ax
    mov ax, 5
    push ax
    mov ax, 44
    push ax
    mov ax, 12
    push ax
    mov ax, [score]
    push ax
    call draw_number

    ; Exit instruction
    mov ax, 0x0E
    push ax
    mov ax, exit_text
    push ax
    mov ax, 29
    push ax
    mov ax, 17
    push ax
    call draw_text

    ; Wait for a key
    mov ah, 00h
    int 16h

    ret

display_score:
    push ax

    ; color attribute
    mov ax, 0x0F
    push ax

    ; number of digits
    mov ax, 5
    push ax

    ; col
    mov ax, 70
    push ax

    ; row
    mov ax, 0
    push ax

    ; current score
    mov ax, [score]
    push ax

    call draw_number

    pop ax
    ret


; main
start:

    ; set 80x25 color text mode
    mov ax, 0003h
    int 10h

    ; set es to video memory
    mov ax, 0xb800
    mov es, ax


    call start_screen
    ; clear screen before displaying gameplay
    call clear_screen
    
    ; top boundary
    mov ax, 0x0F2D
    push ax
    mov ax, 80
    push ax
    mov ax, 0
    push ax
    mov ax, 1
    push ax
    call draw_horizontal_line
    
    ; bottom boundary
    mov ax, 0x0F2D
    push ax
    mov ax, 80
    push ax
    mov ax, 0
    push ax
    mov ax, 24
    push ax
    call draw_horizontal_line

    ; left boundary
    mov ax, 0x0F7C
    push ax
    mov ax, 22
    push ax
    mov ax, 0
    push ax
    mov ax, 2
    push ax
    call draw_vertical_line

    ; right boundary
    mov ax, 0x0F7C
    push ax
    mov ax, 22
    push ax
    mov ax, 79
    push ax
    mov ax, 2
    push ax
    call draw_vertical_line

    ; Draw bucket

    call draw_bucket

    ; Draw all falling objects

    call draw_falling_objects

    ; draw game title
    mov ax, 0x07
    push ax
    mov ax, title_text
    push ax
    mov ax, 2
    push ax
    mov ax, 0
    push ax
    call draw_text

    ; time label
    mov ax, 0x0F
    push ax
    mov ax, time_label
    push ax
    mov ax, 46
    push ax
    mov ax, 0
    push ax
    call draw_text

    ; time value
    call display_timer

    ; score label
    mov ax, 0x0F
    push ax
    mov ax, score_label
    push ax
    mov ax, 63
    push ax
    mov ax, 0
    push ax
    call draw_text

    ; score value
    call display_score

    ; Initialize timer
    call initialize_timer


game_loop:

    call update_timer

    call update_falling_objects

    call move_bucket

    call check_all_collisions

    ; Check whether bomb was caught
    cmp byte [game_end_reason], 1
    je game_end

    ; Check whether timer expired
    cmp word [time_left], 0
    jne game_loop


game_end:

    ; Display end screen
    call end_screen

    ; display end screen
    call end_screen

    mov ax, 4C00h
    int 0x21