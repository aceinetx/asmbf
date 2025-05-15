format ELF64 executable

entry _start

include 'consts.inc'
include 'asmbf_exec.asm'
include 'asmbf_easyexec.asm'

quit_noarg:
	mov rax, SYS_WRITE
	mov rdi, 1
	mov rsi, noarg
	mov rdx, noarg_len
	syscall

quit:
	mov rax, SYS_EXIT
	mov rdi, 0
	syscall

_start:
	mov rdi, [rsp+16]
	cmp rdi, 0
	je quit_noarg

	mov [filename], rdi
	call asmbf_easyexec

	jmp quit

noarg: db "usage: asmbf [filename]", 10, 0
noarg_len = $-noarg
filename: dq 1
;fd: rd 1
;stat: rb SIZEOF_STAT
;filesize: rq 1
;buf: rq 1
