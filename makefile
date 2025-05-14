all: asmbf

asmbf: asmbf.asm asmbf_easyexec.asm asmbf_exec.asm consts.inc
	fasm asmbf.asm
