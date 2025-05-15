; (char*) rdi - filename
asmbf_dofile:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	sub rsp, SIZEOF_STAT

	mov qword [rbp-8], rdi ; filename
	mov qword [rbp-8-8], 0 ; fd
	mov qword [rbp-8-8-8], 0 ; filesize
	mov qword [rbp-8-8-8-8], 0 ; buf
	mov qword [rbp-8-8-8-8-SIZEOF_STAT], 0 ; stat

	; open the file
	mov rax, SYS_OPEN
	mov rdi, [rbp-8]
	mov rsi, 0
	mov rdx, 0
	syscall

	; exit if failed to read
	cmp rax, -1
	je .quit_read

	mov qword [rbp-8-8], rax ; fd

	; get info about the file
	mov rax, SYS_FSTAT
	mov rdi, qword [rbp-8-8]
	lea rsi, [rbp-8-8-8-8-SIZEOF_STAT] ; stat

	syscall

	; get file size
	lea rax, [rbp-8-8-8-8-SIZEOF_STAT] ; stat
	add rax, OFFSET_STAT_ST_SIZE
	mov rax, [rax]
	mov qword [rbp-8-8-8], rax ; filesize

	; allocate the buffer for the file
	; mmap(NULL, filesize, PROT_READ|PROT_WRITE, MAP_PRIVATE, fd, 0);
	mov rax, SYS_MMAP
	mov rdi, 0
	mov rsi, qword [rbp-8-8-8] ; filesize
	mov rdx, PROT_RW
	mov r10, MAP_PRIVATE
	mov r8, qword [rbp-8-8] ; fd
	mov r9, 0
	syscall

	; quit if failed
	cmp rax, MAP_FAILED
	je .quit_mmap

	mov qword [rbp-8-8-8-8], rax ; buf

	; run the code
	mov rdi, qword [rbp-8-8-8-8] ; buf
	call asmbf_exec

	; deallocate the buffer
	mov rax, SYS_MUNMAP
	mov rdi, qword [rbp-8-8-8-8] ; buf
	mov rsi, qword [rbp-8-8-8] ; filesize
	syscall

	; close the file
	mov rax, SYS_CLOSE
	mov rdi, qword [rbp-8-8] ; fd
	syscall

.quit_mmap:
	mov rax, DOFILE_MMAP
	jmp .quit
.quit_read:
	mov rax, DOFILE_READ
	jmp .quit
.quit:
	add rsp, 32
	add rsp, SIZEOF_STAT
	pop rbp
	ret
