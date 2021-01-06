# CS224 Lab 2 Part 3 & 4
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
# $s0 is the address of the original array
# $s1 is the size of the original array
move $s0, $v0
move $s1, $v1

# print the original array
move $a0, $v0
move $a1, $v1
li $a2, 0
jal print_loop

# compress array for a value
la $a0, prompt_single_del
jal print_str
la $a0, ask_del_val
jal print_str
jal input_int
move $a0, $s0
move $a1, $s1
move $a2, $v0
jal compressArray
# update the original array
move $s0, $v0
move $s1, $v1

# print the newly created array
addi $sp, $sp, -4
sw $s0, 0($sp)	# store the original address
li $s2, 0
blt $s2, $s1, loop_5
j endloop_5
loop_5:
	addi $sp, $sp, -8
	sw $s0, 4($sp)			# store $s0
	sw $s2, 0($sp)			# store $s2
	lw $s0, 0($s0)			# set $s0 to contents of the address
	move $a0, $s0			# move the print argument
	jal print_int			# print the int
	la $a0, wspc			# print whitespace
	jal print_str
	
	lw $s0, 4($sp)			# restore $s0 from stack
	addi $s0, $s0, 4		# go to next adress
	addi $s2, $s2, 1		# increment i
	addi $sp, $sp, 8		# deallocate stack
	blt $s2, $s1, loop_5		# check the condition, (i < size)
endloop_5:
lw $s0, 0($sp)	# restore the original address
addi $sp, $sp, 4

# compress multiple for a range of numbers, use this operation in the original array
# take range as input, store it to the $s2-3 registers
la $a0, prompt_multiple_del
jal print_str
la $a0, ask_low_range
jal print_str
jal input_int
move $s2, $v0

la $a0, ask_high_range
jal print_str
jal input_int
move $s3, $v0

move $a0, $s0
move $a1, $s1
move $a2, $s2
move $a3, $s3
jal compressMultiple

# update the original array
move $s0, $v0
move $s1, $v1

# print the newly created array
addi $sp, $sp, -4
sw $s0, 0($sp)			# store the original address
li $s2, 0
blt $s2, $s1, loop_6
j endloop_6
loop_6:
	addi $sp, $sp, -8
	sw $s0, 4($sp)			# store $s0
	sw $s2, 0($sp)			# store $s2
	lw $s0, 0($s0)			# set $s0 to contents of the address
	move $a0, $s0			# move the print argument
	jal print_int			# print the int
	la $a0, wspc			# print whitespace
	jal print_str
	
	lw $s0, 4($sp)			# restore $s0 from stack
	addi $s0, $s0, 4		# go to next adress
	addi $s2, $s2, 1		# increment i
	addi $sp, $sp, 8		# deallocate stack
	blt $s2, $s1, loop_6		# check the condition, (i < size)
endloop_6:
lw $s0, 0($sp)	# restore the original address
addi $sp, $sp, 4

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

# Arguments: $a0 = address of the array / $a1 = size / $a2 = value to be deleted
# Returns: $v0 =  address of the new array / $v1 = size of the new array
compressArray:
	addi $sp, $sp, -48 	# allocate stack for all $s registers
	sw $ra, 44($sp)
	sw $s0, 40($sp)		# i
	sw $s1, 36($sp)		# original array address
	sw $s2, 32($sp)		# index of the given value, -1 if dne
	sw $s3, 28($sp)		# arr[i]
	sw $s4, 24($sp)		# (size - freq)
	sw $s5, 20($sp)		# newarr[j], thou j is not defined here
	sw $s6, 16($sp)
	sw $s7, 12($sp)
	sw $a2, 8($sp)
	sw $a1, 4($sp)
	sw $a0, 0($sp)
	
	li $s0, 0		# i = 0
	move $s1, $a0		# copy the array address into $s2
	li $s2, -1		# index of the value. if it stays as -1, the item doesnt exist
		
loop_2:				# find the index of the value to be deleted

	lw $s3, 0($s1)		# get the value in the address location $s1
	beq $s3, $a2, if_2	# if item is equal to the val to be deleted, the address is found
	j endif_2
if_2:
	move $s2, $s0		# set the index found and break
	j breakloop_2
endif_2:
	addi $s1, $s1, 4	# move to next adress
	addi $s0, $s0, 1	# increment i
	blt $s0, $a1, loop_2	# iterate as i < size
breakloop_2:
	move $a2, $s2		# count frequency of the value to be deleted, set $a2 to $s2
	lw $s0, 40($sp)		# restore $s0
	lw $s1, 36($sp)		# restore $s1
	lw $s2, 32($sp)		# restore $s2
	lw $s3, 28($sp)		# restore $s3
	# count the frequency of the item

	jal countFrequency	# $v0 is now frequency of the value to be deleted
	lw $ra, 44($sp)
	lw $a2, 8($sp)
	lw $a1, 4($sp)
	lw $a0, 0($sp)
	
	sub $s2, $a1, $v0	# compute new size
	move $v1, $s2		# return the new size
	mul $s2, $s2, 4		# convert it to bytes
	move $a0, $s2		# create dynamic array w/ said size
	lw $s2, 32($sp)		# restore $s2
	li $v0, 9
	syscall			# $v0 returns the address of the new array.
	lw $a0, 0($sp)
	
	move $s2, $v0		# store the address of new arr in $s2
	move $s1, $a0		# store the orig. arr address into $s1
	li $s0, 0		# reset i
loop_3:
	lw $s3, 0($s1)		# load the i-th item in the array
	bne $s3, $a2, if_3	# if the item is not the deleted one
	j endif_3
if_3:
	sw $s3, 0($s2)		# put the item to the new array
	addi $s2, $s2, 4	# go to next location in new array
endif_3:
	addi $s1, $s1, 4	# go to next location in original array
	addi $s0, $s0, 1	# increment i
	blt $s0, $a1, loop_3	# check i < size
	
	lw $ra, 44($sp)		# deallocate mem and restore registers
	lw $s0, 40($sp)		
	lw $s1, 36($sp)		
	lw $s2, 32($sp)		
	lw $s3, 28($sp)		
	lw $s4, 24($sp)		
	lw $s5, 20($sp)
	lw $s6, 16($sp)
	lw $s7, 12($sp)
	lw $a2, 8($sp)
	lw $a1, 4($sp)
	lw $a0, 0($sp)
	addi $sp, $sp, 48 	# allocate stack for all $s registers
	
	jr $ra

# Arguments: $a0 = address of the array / $a1 = size / $a2 = low range / $a3 = high range
# Returns: $v0 =  address of the new array / $v1 = size of the new array
compressMultiple:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
loop_4:				# for i in [low-high]
	jal compressArray	# call compress array for i
	move $a0, $v0		# update arguments for compressArray subprogram
	move $a1, $v1		# using its output
	addi $a2, $a2, 1	# increment i
	ble $a2, $a3, loop_4	# check if i <= high
	
	lw $ra, 0($sp)		# deallocate stack and restore read address
	addi $sp, $sp, 4
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
ask_size:		.asciiz "\nEnter size : "
ask_numbers: 		.asciiz "\nEnter values : "
ask_del_val:		.asciiz "\nEnter deletion value : "
ask_low_range:		.asciiz "\nEnter low range : "
ask_high_range: 	.asciiz "\nEnter high range : "
prompt_single_del:	.asciiz "\nEnter the value you want to delete from the set"
prompt_multiple_del:	.asciiz "\nEnter the value range you want to delete from the set"
wspc:			.asciiz " "
