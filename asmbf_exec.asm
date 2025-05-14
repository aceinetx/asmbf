; (char*) rdi - code
asmbf_exec:
	push rbp
	mov rbp, rsp
	sub rsp, 8

	mov qword [rbp-8], rdi ; code
	mov byte [rbp-10], 0 ; temp
	mov byte [rbp-9], 0 ; temp
	mov qword [rbp-18], rdi ; fp
	mov qword [rbp-18-64], 0 ; memory

	mov rax, rbp
	sub rax, 18+64
	mov qword [rbp-18-64-8], rax ; pointer
	mov qword [rbp-18-64-8-8], 1 ; loop counter

.loop:
	mov rax, qword [rbp-18]
	mov al, byte [rax]
	cmp al, 0
	je .quit

	mov byte [rbp-10], al

	; al - current char (also in rbp-10)

	cmp al, '+'
	je .op_inc
	cmp al, '-'
	je .op_dec
	cmp al, '>'
	je .op_right
	cmp al, '<'
	je .op_left
	cmp al, '['
	je .op_open
	cmp al, ']'
	je .op_close
	cmp al, '.'
	je .op_out

	jmp .loop_end

	.op_inc:
		mov rax, qword [rbp-18-64-8] ; pointer
		inc byte [rax]
		jmp .loop_end
	.op_dec:
		mov rax, qword [rbp-18-64-8] ; pointer
		dec byte [rax]
		jmp .loop_end
	.op_right:
		inc qword [rbp-18-64-8] ; pointer
		jmp .loop_end
	.op_left:
		dec qword [rbp-18-64-8] ; pointer
		jmp .loop_end
	.op_open:
		; mov qword [rbp-18-64-8-8], 0 ; loop counter
		mov rax, qword [rbp-18-64-8] ; pointer
		cmp byte [rax], 0
		jne .loop_end

		; current cell is 0, skip that loop
		mov qword [rbp-18-64-8-8], 2 ; loop counter
		.op_open_cmp:
			cmp qword [rbp-18-64-8-8], 1 ; loop counter
			jle .op_open_end

			inc qword [rbp-18] ; fp
			mov rax, qword [rbp-18] ; fp
			mov al, byte [rax] ; current char

			cmp al, '['
			je .op_open_inc
			cmp al, ']'
			je .op_open_dec
			jmp .op_open_cmp
			
			.op_open_inc:
				inc qword [rbp-18-64-8-8] ; loop counter
				jmp .op_open_cmp
			.op_open_dec: 
				dec qword [rbp-18-64-8-8] ; loop counter
				jmp .op_open_cmp

		.op_open_end:
		jmp .loop_end
	.op_close:
		mov rax, qword [rbp-18-64-8] ; pointer
		cmp byte [rax], 0
		je .loop_end

		mov qword [rbp-18-64-8-8], 2 ; loop counter
		.op_close_cmp:
			cmp qword [rbp-18-64-8-8], 1
			jle .op_close_end

			dec qword [rbp-18]
			mov rax, qword [rbp-18]
			mov al, byte [rax]

			cmp al, '['
			je .op_close_dec
			cmp al, ']'
			je .op_close_inc
			jmp .op_close_cmp
			
			.op_close_inc:
				inc qword [rbp-18-64-8-8]
				jmp .op_close_cmp
			.op_close_dec: 
				dec qword [rbp-18-64-8-8]
				jmp .op_close_cmp

		.op_close_end:
		jmp .loop_end
	.op_out:
		mov rax, qword [rbp-18-64-8] ; pointer
		mov al, byte [rax]

		mov byte [rbp-10], al

		mov rax, SYS_WRITE
		mov rdi, 1
		lea rsi, [rbp-10]
		mov rdx, 2
		syscall
		
		jmp .loop_end

.loop_end:
	inc qword [rbp-18]
	jmp .loop

.quit:
	add rsp, 8
	pop rbp
	ret
