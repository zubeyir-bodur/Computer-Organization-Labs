# CS224 Lab 2 Part 1
# Section 2
# Author: Zubeyir Bodur
# ID: 21702382

		.text
la $a0, intro
li $v0, 4
syscall
j complement
complement:
	addi $sp, $sp, -20
	sw $s4, 16($sp)
	sw $s3, 12($sp)
	sw $s2, 8($sp)
	sw $s1, 4($sp)
	sw $s0, 0($sp)
	
	la $a0, ask_number	# Ask and get for number to be manipulated
	li $v0, 4
	syscall
	li $v0, 5
	syscall
	move $s0, $v0		# s0 holds the number
	beq $s0, -1, exit
	la $a0, ask_n 		# Ask and get for number of bits
	li $v0, 4
	syscall
	li $v0, 5
	syscall
	move $s1, $v0 		# $s1 holds the num of bits
	addi $a0, $s1, -1	# pass n - 1 to the iteration amount of the for loop
	li $a1, 1
	jal find_constant
	move $s2, $v0		# $s2 is the bitstring to xor with the number
	xor $s3, $s2, $s0 	# $s3 is the result
	la $a0, print		# print the result
	li $v0, 4
	syscall
	move $a0, $s3
	li $v0, 1
	syscall
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	addi $sp, $sp, 20
	j complement
find_constant:
	sll $a1, $a1, 1
	addi $a1, $a1, 1
	addi $s4, $s4, 1		# update i
	blt $s4, $a0, find_constant 	# check i < n
	move $v0, $a1
	jr $ra
exit:
	li $v0, 10
	syscall
	
		.data
intro:		.asciiz "Convert last n bits of a hexadecimal number\n"
ask_number: 	.asciiz "\nEnter a number, enter -1 to stop: "
ask_n:		.asciiz "Enter \# of bits: "
print:		.asciiz "Result: "