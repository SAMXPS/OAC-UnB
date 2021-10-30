.text

	la	t0, test
	lb	a1, (t0)
	addi	t0, t0, 1
	lb	a2, (t0)
	addi	t0, t0, 1
	lb	a3, (t0)
	addi	t0, t0, 1
	lb	a4, (t0)
	addi	t0, t0, 1
	lb	a5, (t0)
	addi	t0, t0, 1
	lb	a6, (t0)
	addi	t0, t0, 1
	lb	a7, (t0)
.data
test: .asciz "Hello World"