# CS224 Lab6
# Part 1 Question 4
# Author : Zübeyir Bodur
# ID : 21702382
# MIPS Program for a square Matrix
	.text
	
ui_loop:
	la	$a0, endl
	jal	print_str
	# PRINT 1
	la	$a0, first_option
	jal	print_str
	# PRINT 2
	la	$a0, second_option
	jal	print_str
	# PRINT 3
	la	$a0, third_option
	jal	print_str
	# PRINT 4
	la	$a0, fourth_option
	jal	print_str
	# PRINT 5
	la	$a0, fifth_option
	jal	print_str
	# PRINT 5
	la	$a0, sixth_option
	jal	print_str
	# ASK INPUT
	jal	input_int
	# BRANCH INPUTS
	beq	$v0, 1, init
	beq	$v0, 2, display
	beq	$v0, 3, displayElement
	beq	$v0, 4, rowsum
	beq	$v0, 5, colsum
	beq	$v0, 6, endui_loop
	j	ui_loop
	init:
		la	$a0, ask_n
		jal	print_str
		jal	input_int
		move	$s1, $v0	# store N in s1
		move	$a0, $s1
		jal	createMatrix	# allocate storage from heap
		move	$s0, $v0	# store arr address in s0
		move	$a0, $s0
		move	$a1, $s1
		jal	initMatrix	# fill matrix
		j	ui_loop
	display:
		move	$a0, $s0
		move	$a1, $s1
		jal	displayMatrix
		j	ui_loop
	displayElement:
		la	$a0, ask_row
		jal	print_str
		jal	input_int
		move	$a2, $v0
		la	$a0, ask_col
		jal	print_str
		jal	input_int
		move	$a3, $v0
		move	$a0, $s0
		move	$a1, $s1
		jal	getVal
		move	$s3, $v0
		## display element
		la	$a0, result
		jal	print_str
		move	$a0, $s3
		jal	print_int
		j	ui_loop
	rowsum:
		move	$a0, $s0
		move	$a1, $s1
		jal	rowMajorSum
		move	$s2, $v0	# s2 will store the sum
		la	$a0, result
		jal	print_str
		move	$a0, $s2
		jal	print_int
		j	ui_loop
	colsum:
		move	$a0, $s0
		move	$a1, $s1
		jal	colMajorSum
		move	$s2, $v0	# s2 will store the sum
		la	$a0, result
		jal	print_str
		move	$a0, $s2
		jal	print_int
		j	ui_loop
endui_loop:
li	$v0, 10
syscall

#=====SUBPROGRAMS=======

# Create an array of size N^2
# to represent a square matrix NxN
# Arguments = >
#	$a0 - N, number of rows & columns
#	in the NxN square matrix 
# Returns = >
#	$v0 - address of the array
createMatrix:
	mul	$a0, $a0, $a0	# n := n * n
	mul	$a0, $a0, 4	# n := 4 * n
	li	$v0, 9
	syscall
	jr	$ra

# Initialize the matrix in the given address
# the contents will be ....
# 1		2		3	..	N
# N+1		N+2		N+3	..	2N
# 2N+1		2N+2		2N+3	..	3N
# .		.		.	..	.
# .		.		.	..	.
# (N-1)N+1	(N-1)N+2	(N-1)N+3..	N^2
# However, the array will start from (1, 1), follows the
# rows and ends at N^2.
# Arguments = >
#	$a0 - address of the array
#	$a1 - N
# Returns = >
initMatrix:
	mul	$a1, $a1, $a1	# N := N^2
	addi	$t0, $0, 1
	addi	$a1, $a1, 1
	blt	$t0, $a1, loop_0 	# for ($t0 = 1; $t0 < N^2 + 1;...)
	j	endloop_0
loop_0:
	sw	$t0, 0($a0)	# arr[i] = $t0
	addi	$a0, $a0, 4	# i++
	addi	$t0, $t0, 1	# $t0++
	blt	$t0, $a1, loop_0
endloop_0:
	jr	$ra

# Computes the row major sum of the given 
# NxN sqr. matrix
# in address $a0
# Arguments = > 
#	$a0 - address of the array
#	$a1 - N
# Returns = >
#	$v0 - row major sum
rowMajorSum:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	addi	$v0, $0 , 0	# sum := 0
	
	addi	$t0, $0, 1	# rowno := 1
	addi	$a1, $a1, 1	# N := N + 1
	blt	$t0, $a1, loop_1 	# for (rowno = 1; rowno < N + 1;...)
	j	endloop_1
	loop_1:
		addi	$t2, $0, 0	# rowsum := 0
		addi	$t1, $0, 1	# colno := 1
		blt	$t1, $a1, loop_2 	# for (colno = 1; colno < N + 1;...)	
		j	endloop_2
		loop_2:
			addi	$sp, $sp, -24
			sw	$a0, 0($sp)
			sw	$a1, 4($sp)
			sw	$a2, 8($sp)
			sw	$a3, 12($sp)
			sw	$v0, 16($sp)
			sw	$ra, 20($sp)
			addi	$a1, $a1, -1
			move	$a2, $t0
			move	$a3, $t1
			jal	getVal		# cell = get(row, col)
			add	$t2, $t2, $v0	# rowsum += cell
			lw	$a0, 0($sp)
			lw	$a1, 4($sp)
			lw	$a2, 8($sp)
			lw	$a3, 12($sp)
			lw	$v0, 16($sp)
			lw	$ra, 20($sp)
			addi	$sp, $sp, 24
			addi	$t1, $t1, 1	# colno++
			blt	$t1, $a1, loop_2
		endloop_2:
		
		add	$v0, $v0, $t2	# sum += rowsum
		addi	$t0, $t0, 1	# rowno++
		blt	$t0, $a1, loop_1
	endloop_1:	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra
	
# Computes the column major sum of the given 
# NxN sqr. matrix
# in address $a0
# Arguments = > 
#	$a0 - address of the array
#	$a1 - N
# Returns = >
#	$v0 - row major sum
colMajorSum:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	addi	$v0, $0 , 0	# sum := 0
	
	addi	$t0, $0, 1	# colno := 1
	addi	$a1, $a1, 1	# N := N + 1
	blt	$t0, $a1, loop_3 	# for (colno = 1; colno < N + 1;...)
	j	endloop_3
	loop_3:
		addi	$t2, $0, 0	# colsum := 0
		addi	$t1, $0, 1	# rowno := 1
		blt	$t1, $a1, loop_4 	# for (rowno = 1; rowno < N + 1;...)	
		j	endloop_4
		loop_4:
			addi	$sp, $sp, -24
			sw	$a0, 0($sp)
			sw	$a1, 4($sp)
			sw	$a2, 8($sp)
			sw	$a3, 12($sp)
			sw	$v0, 16($sp)
			sw	$ra, 20($sp)
			addi	$a1, $a1, -1
			move	$a2, $t1
			move	$a3, $t0
			jal	getVal		# cell = get(row, col)
			add	$t2, $t2, $v0	# colsum += cell
			lw	$a0, 0($sp)
			lw	$a1, 4($sp)
			lw	$a2, 8($sp)
			lw	$a3, 12($sp)
			lw	$v0, 16($sp)
			lw	$ra, 20($sp)
			addi	$sp, $sp, 24
			addi	$t1, $t1, 1	# rowno++
			blt	$t1, $a1, loop_4
		endloop_4:
		
		add	$v0, $v0, $t2	# sum += colsum
		addi	$t0, $t0, 1	# colno++
		blt	$t0, $a1, loop_3
	endloop_3:
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra
	
# Displays the given NxN square matrix
# Arguments = > 
#	$a0 - address of the array
#	$a1 - N
# Returns = >
displayMatrix:
	addi	$t0, $0, 0	# index := 0
	mul	$t3, $a1, $a1	# N := N^2
	blt	$t0, $t3, loop_5 	# for ($t0 = 0; $t0 < N^2;...)
	j	endloop_5
	loop_5:
		lw	$t1, 0($a0)	# $t1 := arr[index]
		addi	$sp, $sp, -8
		sw	$a0, 0($sp)
		sw	$ra, 4($sp)
		move	$a0, $t1
		jal	print_int	# print arr[i]
		div	$t0, $a1
		mfhi	$t2		# $t2 := index % N
		addi	$t4, $a1, -1	# $t4 := N - 1
		
		beq	$t2, $t4, if_0
			la	$a0, tab	# print wspc otherwise
			j	endif_0
		if_0:
			la	$a0, endl	# print \n if end of row
		endif_0:
		jal	print_str
		lw	$a0, 0($sp)
		lw	$ra, 4($sp)
		addi	$sp, $sp, 8
		addi	$a0, $a0, 4	# next adress
		addi	$t0, $t0, 1	# index++
		blt	$t0, $t3, loop_5
	endloop_5:
	jr	$ra

# Gets the value in (row, col)
# in the given matrix
# Arguments = > 
#	$a0 - address of the array
#	$a1 - N
#	$a2 - row no.
#	$a3 - col no.
# Returns = >
#	$v0 - value read from matrix array
getVal:
	# compute offset = N * (row no. - 1) + col no. - 1
	addi	$a2, $a2, -1
	addi	$a3, $a3, -1
	mul	$a2, $a1, $a2
	add	$a2, $a2, $a3	# $a2 = # of indexes to add
	mul	$a2, $a2, 4	# $a2 = offset
	add	$a0, $a0, $a2
	lw	$v0, 0($a0)	# get the value
	jr	$ra

# Arguments = > 
# Returns = >
#	$v0 - int read
input_int:
	li $v0, 5
	syscall
	jr $ra

# Arguments = > 
#	$a0 - str to print
# Returns = >
print_str:
	li $v0, 4
	syscall
	jr $ra
	
# Arguments = > 
#	$a0 - int to print
# Returns = >
print_int:
	li $v0, 1
	syscall
	jr $ra
	
		.data
first_option:	.asciiz "1- Create a square matrix with N # of rows\n"
second_option:	.asciiz "2- Display the square matrix\n"
third_option:	.asciiz "3- Display an element\n"
fourth_option:	.asciiz "4- Display sum of elements row-major\n"
fifth_option:	.asciiz "5- Display sum of elements column-major\n"
sixth_option:	.asciiz "6- Quit\n"
ask_n:		.asciiz "Enter N : "
ask_row:	.asciiz "Enter row no. : "
ask_col:	.asciiz "Enter col no. : "
result:		.asciiz "Result : "
hyphen:		.asciiz " - "
endl:		.asciiz "\n"
wspc:		.asciiz " "
tab:		.asciiz "\t"
