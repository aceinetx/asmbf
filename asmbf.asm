format ELF64 executable

entry _start

include 'consts.inc'
include 'asmbf_exec.asm'
include 'asmbf_easyexec.asm'

quit:
	mov rax, SYS_EXIT
	mov rdi, 0
	syscall

_start:
	mov rdi, filename
	call asmbf_easyexec

	jmp quit


filename: db "a.bf", 0
;fd: rd 1
;stat: rb SIZEOF_STAT
;filesize: rq 1
;buf: rq 1
