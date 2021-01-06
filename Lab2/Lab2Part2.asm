# CS224 Lab 2 Part 2
# Section 2
# Author: Zubeyir Bodur
# ID: 21702382

	.text

# get input
la $a0, ask_size
jal print_str
jal input_int

li $a0, 4	# load byte multiplier into subrogram as $a0
move $a1, $v0	# set size to $a1 of the subprogram
jal createPopulateArray
# $s0 is the address of the array
# $s1 is the size of the array
move $s0, $v0
move $s1, $v1

# print if the array is a palindrome
jal checkPalindrome

la $a0, print_freq_list1
jal print_str
jal input_int

# restore $a0-$a1 registers from the stack
move $a0, $s0
move $a1, $s1
move $a2, $v0	# set $a2 to asked index

jal countFrequency

move $s2, $v0	# save freq into $s3
la $a0, print_freq_list2
jal print_str

move $a0, $s2 	# load count frequency into $a0
jal print_int

li $v0, 10	# exit
syscall

# Subprograms

# a0 = byte multiplier constant, 4
# a1 = the size of the array
# returns v0 the address of the array
#    "    v1 the size of the array
# status: working
createPopulateArray:
	mult $a0, $a1	# calculate bytes required for array
	mflo $a0
	li $v0, 9
	syscall
	move $a0, $v0	# set $a0 to adress of the array
	li $a2, 0	# reset $a2
	
	addi $sp, $sp, -16	# allocate mem from stack
	sw $a0, 12($sp)	# store the address into the stack
	sw $a1, 8($sp)	# store the address into the stack
	sw $a2, 4($sp) 	# use $a2 as i, store it to stack
	sw $ra, 0($sp)	# store the read address of create populate array
	jal input_loop
	lw $a0, 12($sp) # restore the address from the stack
	lw $a1, 8($sp) 	# restore the address from the stack
	lw $a2, 4($sp) 	# restore i from the stack
	lw $ra, 0($sp)	# restore createpop array's read address
	addi $sp, $sp, 16	# deallocate mem from stack
	
	move $v0, $a0	# return the array address 
	move $v1, $a1	# return the size
	jr $ra

# Arguments: $a0 = address of array/ $a1 = size of array/ $a2 = i
# Returns:   there is none
# status: working
input_loop:
	addi $sp, $sp, -8		# allocate mem from stack
	sw $a0, 4($sp)			# store the i-th array address
	sw $ra, 0($sp)			# store the read address
	
	la $a0, ask_numbers		# Input for an integer
	jal print_str
	lw $a0, 4($sp)			# Restore $a0 to ith array address
	lw $ra, 0($sp)			# restore the read address
	
	jal input_int
	lw $ra, 0($sp)			# restore the read address
	
	sw $v0, 0($a0)			# Set the input $v0 as the ith item in the array
	addi $a0, $a0, 4		# go to next adress
	addi $a2, $a2, 1		# increment i
	addi $sp, $sp, 8		# deallocate mem from stack
	blt $a2, $a1, input_loop	# check the condition, (i < size)
	jr $ra
	
# Arguments: $a0 = address / $a1 = size
# Returns: there is none
# status: working
checkPalindrome:
	li $a2, 0	# set i to 0
	addi $sp, $sp, -28	# allocate stack
	sw $ra, 24($sp) # store return address
	sw $s0, 20($sp) # store $s0
	sw $s1, 16($sp) # store $s1
	sw $a0, 12($sp) # store $a0
	sw $a1, 8($sp)  # store $a1
	sw $a2, 4($sp)  # store $a2
	jal print_loop
	lw $ra, 24($sp) # restore return address
	lw $a0, 12($sp) # restore $a0
	lw $a1, 8($sp)  # restore $a1
	lw $a2, 4($sp)  # restore $a2

	move $a3, $a0	# get the address of the last item and store it to $a3
	li $s0, 4	# $a3 = $a0 + (4 * [$a1 - 1])
	addi $a1, $a1, -1
	mult  $a1, $s0
	mflo $s0
	add $a3, $a3, $s0
	sw $a3, 0($sp)	# store $a3
	
	lw $s0, 20($sp)	# restore $s0
	lw $s1, 16($sp)	# restore $s1
	lw $a1, 8($sp)	# restore $a1
	
	div $a1, $a1, 2	# set $a1 to size/2 as half iteration is enough for palindrome checking
	li $v0, 1	# load 1 to $v0, if v0 changes the array is not palindrome
	jal palind_loop
	sw $v0, 28($sp)	# save the result of the subrogram into stack
	
	la $a0, is_palind 	# print the results
	jal print_str
	
	lw $v0, 28($sp)		# restore $v0
	beq $v0, 1, if_2
	la $a0, no
	jal print_str
	j endif_2
if_2:	
	la $a0, yes
	jal print_str
endif_2:
	
	lw $ra, 24($sp)	# restore read address
	lw $s0, 20($sp) # restore $s0
	lw $s1, 16($sp) # restore $s1
	lw $a0, 12($sp) # restore $a0
	lw $a1, 8($sp)  # restore $a1
	lw $a2, 4($sp)  # restore $a2
	lw $a3, 0($sp)	# restore $a3
	addi $sp, $sp, 28	# deallocate the stack	
	jr $ra
	
# Arguments: $a0 = address / $a1 = size / $a2 = i
# Returns: none
print_loop:
	addi $sp, $sp, -8
	sw $a0, 4($sp)			# store $a0
	sw $ra, 0($sp)			# store read address
	
	lw $a0, ($a0)			# set $a0 to contents of the address
	jal print_int			# print the int
	la $a0, wspc			# print whitespace
	jal print_str
	
	lw $a0, 4($sp)			# restore $a0
	lw $ra, 0($sp)			# restore read address
	addi $a0, $a0, 4		# go to next adress
	addi $a2, $a2, 1		# increment i
	addi $sp, $sp, 8		# deallocate stack
	blt $a2, $a1, print_loop	# check the condition, (i < size)
	jr $ra

# Arguments: $a0 = address / $a1 = size/2 / $a2 = i / $a3 = last address
#returns: $v0 = true if its a palindrome, false otherwise
palind_loop:
	addi $sp, $sp, -12		# allocate stack
	sw $s0, 8($sp)			# store $s0
	sw $s1, 4($sp)			# store $s1
	sw $s2, 0($sp)			# store $s2
	lw $s0, 0($a0)			# $s0 is now first integer in the array
	lw $s1, 0($a3)			# $s1 is now last integer in the array
	bne $s0, $s1, not_palindrome	# return 1 if all pairs are equal
	and $v0, $v0, 1			# and $v0 with 1 as the pairs are equal
	j end_if
not_palindrome:
	li $v0, 0			# if v0 is toggled, bitwise and will always return zero
end_if:
	addi $a2, $a2, 1		# increment i
	addi $a0, $a0, 4		# move the front_ptr to the next
	addi $a3, $a3, -4		# move the back_ptr to the prev
	addi $sp, $sp, 12		# deallocate stack
	blt $a2, $a1, palind_loop	# check the condition, i < (size/2)
	lw $s0, 8($sp)			# restore $s0-2 when the loop ends
	lw $s1, 4($sp)
	lw $s2, 0($sp)
	jr $ra
	
# Arguments: $a0 = adress of the array / $a1 = size / $a2 = index of the item to be counted	
# Returns: $v0 = count of the item in the index
countFrequency:
	addi $sp, $sp, -16	# save $s registers and allocate memory
	sw $s0, 12($sp)
	sw $s1, 8($sp)
	sw $s2, 4($sp)
	sw $s3, 0($sp)
	
	li $s2, 0	# i = 0
	li $s3, 4	# byte multiplier = 4
	li $v0, 0	# count = 0
	bne $a2, -1, if_0	# if index is not -1 count the freq
	j endif_0
if_0:
	mult $a2, $s3
	mflo $a2
	add $a2, $a0, $a2	# $a2 is now the address of the index
loop_1:
	lw $s0, 0($a0)		# load the value on address $a0
	lw $s1, 0($a2)		# load the value on the index
	beq $s0, $s1, if_1
	j endif_1
if_1:
	addi $v0, $v0, 1
endif_1:
	addi $a0, $a0, 4	# go to next address in the array
	addi $s2, $s2, 1	# increment i
	blt $s2, $a1, loop_1	# continue iteration if i < size
	
endif_0:
	lw $s3, 0($sp)		# restore $s registers and deallocate memory
	lw $s2, 4($sp)
	lw $s1, 8($sp)
	lw $s0, 12($sp)
	addi $sp, $sp, 16
	jr $ra
	
# Syscall subprograms
print_str:
	li $v0, 4
	syscall
	jr $ra
print_int:
	li $v0, 1
	syscall
	jr $ra
input_int:
	li $v0, 5
	syscall
	jr $ra
	
		.data
ask_size:	.asciiz "\nEnter size: "
ask_numbers: 	.asciiz "\nEnter values: "
is_palind:	.asciiz "\nIs Palindrome : "
yes:		.asciiz "yes"
no:		.asciiz "no"
print_freq_list1:.asciiz "\nFrequency at index "
print_freq_list2:.asciiz " : "
wspc:		.asciiz " "
