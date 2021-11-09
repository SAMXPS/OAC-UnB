.data 
vet:	.word 15 63

.text                        	
	auipc a0, 2		# a0 <= 0x2000
	auipc a1, 2		# a1 <= 0x2004
	lui  s0, 2		# s0 <= 0x2000
	lw   s1, 0(s0)      	# s1 <= 15
	lw   s2, 4(s0)      	# s2 <= 63
	add  s3, s1, s2     	# s3 <= 78
	sw   s3, 8(s0)      	# mem[0x2008] <= 78
	lw   a0, 8(s0)      	# a0 <= 78
	addi s4, zero, 0x7F0    # s4 <= 0x7F0
	addi s5, zero, 0x0FF    # s5 <= 0x0FF
	and  s6, s5, s4         # s6 <= 0x0F0
	or   s7, s5, s4         # s7 <= 0x7FF
	xor  s8, s5, s4         # x8 <= 0x70F
	addi t0, x0, -1		# t0 <= -1
	addi t1, x0, 1		# t1 <= 1
	slt  s0, t0, t1         # s0 <= 1
	slt  s1, t1, t0         # s1 <= 0
	sub  s2, t0, t1		# s2 <= -2
	sub  s3, t1, t0		# s3 <= 2
		
	jal  ra, testasub       # 
	jal  x0, next           # 
testasub:
	sub  t3, t0, t1         # t3 <= -2
	jalr x0, ra, 0          # 
next:
	addi t0, zero, -2       # t0 <= -2
beqsim: 
	addi t0, t0, 2          # t0 <= 0, 2
	beq  t0, zero, beqsim   # 
bnesim:
	addi t0, t0, -1         # t0 <= 1, 0
	bne  t0, zero, bnesim   # 
	
#
# Instrucoes do nucleo comum ^^^
#	

# GRUPO IMM

	ori  a0, zero, 0xFF     # a0 <= 0xFF
	andi a1, a0, 0xF0       # a1 <= 0xF0
	xori a2, a0, -1		# a2 <= 0xFFFFFF00
	ori  a3, a1, 0x7FF	# a3 <= 0x7FF

# GRUPO COMP
	addi t0, x0, -1		# t0 <= -1
	addi t1, x0, 1		# t1 <= 1
	slti s0, x0, -1		# s0 <= 0
	slti s1, x0, 1         	# s1 <= 1
	slti s2, t0, -1		# s2 <= 0
	sltu s3, t1, t0        	# s3 <= 1
	sltu s4, t0, t1        	# s4 <= 0
	sltiu s5, t1, -1	# s5 <= 1

# GRUPO SHIFT

	lui  t2, 0xFF000        # t2 <= 0xFF000000
	addi a0, x0, 4		# a0 <= 4
	srl  t3, t2, a0         # t3 <= 0x0FF00000
	sra  t4, t2, a0         # t4 <= 0xFFF00000
	sll  t5, t2, a0		# t5 <= 0x0FF00000

# GRUPO SHIFT Imm

	lui  t2, 0xFF000        # t2 <= 0xFF000000
	srli t3, t2, 4          # t3 <= 0x0FF00000
	srai t4, t2, 4          # t4 <= 0xFFF00000
	slli t5, t2, 4		# t5 <= 0xF0000000
	
# GRUPO BRANCH	
	
	addi t0, zero, 1	# t0 <= 1
bltadd:	
	addi t0, t0, -1         # t0 <= 0, -1
	blt  t0, zero, blton	# falha, salta
	j    bltadd		# 
blton:
	bge  t0, zero, bluton	# falha, salta
	addi t0, t0, 1		# t0 <= 0
	j blton			# 
bluton:
	bltu x0, t0, bgeuton    # falha, salta
	addi t0, t0, -1		# t0 <= -1
	j bluton
bgeuton:
	addi t1, x0, 1000
	bgeu t1, t0, bgeuton
	bgeu t0, t1, FOI
	j bgeuton
FOI:
	# encerra...

	
