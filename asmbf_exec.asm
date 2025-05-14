; (char*) rdi - code
asmbf_exec:
	push rbp
	mov rbp, rsp
	sub rsp, 8

	mov qword [rbp-8], rdi ; code
	mov byte [rbp-10], 0 ; temp
	mov byte [rbp-9], 0 ; temp
	mov qword [rbp-18], rdi

.loop:
	mov rax, qword [rbp-18]
	mov al, byte [rax]
	cmp al, 0
	je .quit

	mov byte [rbp-10], al

	mov rax, SYS_WRITE
	mov rdi, 1
	lea rsi, [rbp-10]
	mov rdx, 2
	syscall

	; al - current char

	inc qword [rbp-18]
	jmp .loop

.quit:
	add rsp, 8
	pop rbp
	ret
