# CS224 Lab 1 Part 2
# Section 2
# Author: Zubeyir Bodur
# Student ID: 21702382

	.text
# Store the constants: a, b, c, d. Ask & get user input
la $a0, print_expression
li $v0, 4
syscall

# Get a
la $a0, ask_a
li $v0, 4
syscall
li $v0, 5
syscall
sw $v0, a

# Get b
la $a0, ask_b
li $v0, 4
syscall
li $v0, 5
syscall
sw $v0, b_

# Get c
la $a0, ask_c
li $v0, 4
syscall
li $v0, 5
syscall
sw $v0, c

# Get d
la $a0, ask_d
li $v0, 4
syscall
li $v0, 5
syscall
sw $v0, d

# Compute & print x = [a*(b-c) % d], ignore overflow.
la $a0, print_x 	# print the output message
li $v0, 4
syscall
jal compute		# compute x
la $a0, ($v0)		# print x
li $v0, 1
syscall

# exit
li $v0, 10
syscall

compute:
	lw $a0, a
	lw $a1, b_
	lw $a2, c
	lw $a3, d
	sub $t0, $a1, $a2
	mult $a0, $t0
	mflo $t0	# ignore overflow, so that we make 32-bit multiplication
	div $t0, $a3
	mfhi $v0	# the remainder of the division is the return value of the function
	jr $ra

			.data
a:			.word 0
b_:			.word 0
c:			.word 0
d:			.word 0
print_expression:	.asciiz "Calculating: x = a * (b-c) % d\n"
ask_a:			.asciiz "Enter a: "
ask_b:			.asciiz "Enter b: "
ask_c:			.asciiz "Enter c: "
ask_d:			.asciiz "Enter d: "
print_x: 		.asciiz "Result is: x = "