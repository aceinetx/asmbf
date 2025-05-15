all: asmbf

asmbf: asmbf.asm asmbf_dofile.asm asmbf_exec.asm consts.inc
	fasm asmbf.asm
