# CS224 Lab 3 Part 1-2
# Section 2
# Author: Zubeyir Bodur
# ID: 21702382

		.text
la	$a0, ask_input
jal	print_str

li	$v0, 5
syscall
move	$s1, $v0	# $s1 : input to be searched

la	$a0, ask_pattern
jal	print_str

li	$v0, 5
syscall
move	$s0, $v0	# $s0 : pattern to look

la	$a0, ask_n
jal	print_str

li	$v0, 5
syscall
move	$s2, $v0	# $s2 : pattern to look

move	$a0, $s0
move	$a1, $s1
move	$a2, $s2
jal 	checkPattern
move	$s3, $v0	# $s3 : count of the pattern

la	$a0, count_msg
jal	print_str

move	$a0, $s3
jal	print_int

la	$a0, ask_sum
jal	print_str

li	$v0, 5
syscall
move	$a0, $v0	# read N and compute sum
li	$v0, 0
jal	recursiveSummation
move	$s0, $v0	# $s0 : sum from 1 to N

la	$a0, result_sum
jal	print_str

move	$a0, $s0
jal	print_int

li 	$v0, 10
syscall

# SUBPROGRAMS

# Arguments = > 
#	$a0 - pattern to find
#	$a1 - input to search
#	$a2 - size of pattern in bits
# Returns = >
# 	$v0 - num of patterns
checkPattern:
	addi 	$sp, $sp, -36
	sw	$s0, 0($sp)	# pattern to find
	sw	$s1, 4($sp)	# input to search
	sw	$s2, 8($sp)	# n
	sw	$s3, 12($sp)	# sizeRemaining
	sw	$s4, 16($sp)	# 2^n - 1
	sw	$s5, 20($sp)	# count
	sw	$s6, 24($sp)	# window
	sw	$s7, 28($sp)	# k, where 32 - k*n = sizeRemaining: k = (32 - sizeReamining) / n
	sw	$ra, 32($sp)

	move 	$s0, $a0
	move	$s1, $a1
	move	$s2, $a2
	li	$s3, 32		# sizeRemaining = 32
	
	### CALCULATE 2^n - 1 ###
	addi	$sp, $sp, -8		# allocate stack to use temporary memory
	sw	$s0, 0($sp)		# to calculate 2^n - 1
	sw	$s1, 4($sp)
	li	$s0, 1			# x = 1
	li	$s1, 1			# i = 1
	blt 	$s1, $s2, loop_2 	# i < n	
loop_2:
	sll 	$s0, $s0, 1
	addi 	$s0, $s0, 1
	addi 	$s1, $s1, 1		# i++
	blt 	$s1, $s2, loop_2 	# i < n
	move 	$s4, $s0		# store 2^n - 1
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	addi	$sp, $sp, 8		# deallocate stack
	#### END OF CALCULATION ####
	
	li	$s5, 0			# count = 0
	bgt 	$s3, $zero, loop_1	# for (sizeRemaining > 0; ....
	j endloop_1
loop_1:
	subi	$s7, $s3, 32
	neg	$s7, $s7
	div	$s7, $s7, $s2	# k is stored in $s7
	mflo	$s7
	addi	$s7, $s7, 1	# k + 1 will give the order of the pattern that is being checked
				# e.g. if k = 0, we'll have k + 1 = 1
				# so we will use k + 1 to indicate it's window 1
	la	$a0, window
	jal	print_str
	move	$a0, $s7
	jal	print_int
	la	$a0, hyphen
	jal	print_str
	

	
	and	$s6, $s1, $s4	# window = input & (2^n - 1)
	
	move	$a0, $s6	# print the current window
	li	$v0, 35		# zero extend the bits into 32-bit format
	syscall
	
	bge	$s3, $s2, if_1	# if (sizeRemaining >= n)...
	la	$a0, error_msg	# else print error
	jal	print_str
	j	endif_1
if_1:	
	beq	$s6, $s0, if_2	# if (window == pattern)...
	la	$a0, no_match	# else print no match
	jal	print_str
	j	endif_2
if_2:
				# if the input contains the pattern 
				# in its n rightmost bits
	addi	$s5, $s5, 1	# count++
	la	$a0, match	# print match
	jal	print_str
endif_2:
endif_1:
	la	$a0, endl	# print newline
	jal	print_str
	
	addi	$sp, $sp, -4		# right shift the input to go to the next pattern
	sw	$s0, 0($sp)		# save input pattern to stack	
	li	$s0, 0			# i = 0
	blt	$s0, $s2, loop_3	# i < n
	j	endloop_3
loop_3:
	srl	$s1, $s1, 1
	addi	$s0, $s0, 1
	blt	$s0, $s2, loop_3
endloop_3:
	lw	$s0, 0($sp)
	addi	$sp, $sp, 4

	sub	$s3, $s3, $s2		# decrease the size of the input
	bgt	$s3, $zero, loop_1	# sizeRemaining > 0
endloop_1:

	move	$v0, $s5		# return count 
	
	lw	$s0, 0($sp)	# restore & deallocate
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s5, 20($sp)
	lw	$s6, 24($sp)
	lw	$s7, 28($sp)
	lw	$ra, 32($sp)
	addi 	$sp, $sp, 36
	jr	$ra		# end of checkPattern

# Arguments = > 
#	$a0 - N
# Returns = >
#	$v0 - sum o integers from 1 to N
recursiveSummation:
	addi 	$sp, $sp, -12
	sw	$s0, 0($sp)	# N
	sw	$s1, 4($sp)	# 1
	sw	$ra, 8($sp)
	
	move	$s0, $a0
	li	$s1, 1
	addi	$a0, $a0, -1
	beqz	$a0, if_3
	jal	recursiveSummation
	addi	$a0, $a0, 1
	add	$v0, $v0, $s0
	j	endif_3
if_3:
	li	$v0, 1
endif_3:
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$ra, 8($sp)
	addi 	$sp, $sp, 12	 	 
	jr	$ra

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

ask_input:	.asciiz "Enter input to search a pattern: "
ask_pattern:	.asciiz "Enter the pattern: "
ask_n:		.asciiz "Enter the length of the pattern: "
ask_sum:	.asciiz "\nEnter N to compute the sum from 1 to N: "
result_sum:	.asciiz "Sum: "
window:		.asciiz "window "	
match:		.asciiz " matching"
no_match:	.asciiz " not matching"
error_msg:	.asciiz " can't match by definition"
count_msg:	.asciiz "Pattern count: "
hyphen:		.asciiz " - "
endl:		.asciiz "\n"
