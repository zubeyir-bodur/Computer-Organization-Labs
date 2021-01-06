# CS224 Lab 1 Part 4
# Section 2
# Author: Zubeyir Bodur
# Student ID: 21702382

	.text
# Store the constants: b, c, d. Ask & get user input
la $a0, print_expression
li $v0, 4
syscall

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

# Compute & print A = (B * (C mod D) + C / B) - B, ignore overflow.
la $a0, print_a 	# print the output message
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
	lw $a0, b_
	lw $a1, c
	lw $a2, d
	
	div $a1, $a2
	mfhi $t0		# set $t0 contents to (c mod d)
	mult $t0, $a0
	mflo $t0		# set $t0 contents to b * (c mod d)
	div $a1, $a0
	mflo $t1		# set $t1 contents to c/b
	add $t0, $t0, $t1	
	sub $v0, $t0, $a0	# return ($t0) + ($t1) - b
	jr $ra

			.data
b_:			.word 0
c:			.word 0
d:			.word 0
print_expression:	.asciiz "Calculating: A = (B * (C mod D) + C / B) - B\n"
ask_b:			.asciiz "Enter B: "
ask_c:			.asciiz "Enter C: "
ask_d:			.asciiz "Enter D: "
print_a: 		.asciiz "Result is: A = "
