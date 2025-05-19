format ELF64 executable

entry _start

include 'consts.inc'
include 'asmbf_exec.asm'
include 'asmbf_dofile.asm'

quit_read:
	mov rax, SYS_WRITE
	mov rdi, 1
	mov rsi, readerr
	mov rdx, readerr_len
	syscall
	jmp quit

quit_noarg:
	mov rax, SYS_WRITE
	mov rdi, 1
	mov rsi, noarg
	mov rdx, noarg_len
	syscall

quit_invalid_size:
	mov rax, SYS_WRITE
	mov rdi, 1
	mov rsi, invalid_size
	mov rdx, invalid_size_len
	syscall

quit:
	mov rax, SYS_EXIT
	mov rdi, 0
	syscall

_start:
	mov rdi, [rsp+16]
	cmp rdi, 0
	je quit_noarg

	;mov [filename], rdi
	call asmbf_dofile
	cmp rax, DOFILE_READ
	je quit_read
	cmp rax, DOFILE_SIZE
	je quit_invalid_size

	jmp quit

noarg: db "usage: asmbf [filename]", 10, 0
noarg_len = $-noarg
readerr: db "read fail", 10, 0
readerr_len = $-readerr
invalid_size: db "invalid size", 10, 0
invalid_size_len = $-invalid_size
filename: dq 1
;fd: rd 1
;stat: rb SIZEOF_STAT
;filesize: rq 1
;buf: rq 1
