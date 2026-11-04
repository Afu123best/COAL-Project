[org 0x0100]
jmp start

incrementCount:
	inc cx
	jmp loop1

start:
	mov ax, 1100010110100011b ; number
	mov bx, 0 ; number of iterations
	mov cx, 0 ; count
	mov dx, 0

loop1:
	cmp dx, 16
	je next
	inc dx
	shr ax, 1
	jc incrementCount
	jmp loop1

next:
	inc bx
	mov ax, cx
	xor cx, cx  ; cx = 0
	xor dx, dx ; dx = 0
	cmp ax, 1
	je end
	jmp loop1

end:
	mov ax, 4C00h
	int 0x21

