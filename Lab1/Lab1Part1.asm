# CS224 Lab 1 Part 1
# Section 1
# Author: Zubeyir Bodur
# Student ID: 21702382
		
		.text
# Initialize the size of the array
la $a0, ask_size
li $v0, 4
syscall
li $v0, 5
syscall
# if the size is larger than 20, truncate it to 20.
# if the size is negative, consider the size as 0.
# bgt $v0, 20, max_size
# blt $v0, 0, min_size
# jal check_bounds
	
# Local variables			
la $s2, 0($v0)	# the variable 'valid' that represents the used part of the 'array'
la $t0, array 	# the address of array[0], to be used as front_ptr

# Small problem loading array[valid-1] into $t1, 
# we don't know the adress $t1, which is equal to $t0 + 4*( valid - 1 )
# so calculate t1 off of this relation
subi $s7, $s2, 1 	# $s7 = valid - 1
li $s6, 4		# $s6 = 4
multu $s6, $s7
mflo $s7
add $s7, $t0, $s7	# $s7 will always represent the address of the last item in the array
la $t1, ($s7)		# and we will use $t1 as a pointer traversing from back of the array
			# to the middle of the array

lw $s0, 0($t0)  # the variable for array[$t0] 
lw $s1, 0($t1)  # the variable for array[$t1]
li $s3, 0	# the variable 'i'
li $s4, 1	# the bool variable 'is_palindrome',
		# will be switched to 0 if array[$t0] != array[$t1] at any time 
		# and the subprogram will stop if that's the case.
		
div $t2, $s2, 2 # the temporary var: valid / 2, int division
		
# Now that we've initialized evey piece, we can get user input
# then print the array and decide if its a palindrome
jal input_loop
jal clear
jal print_loop
jal clear
jal palind_loop

# As we have found if the array is a palindrome, 
# we can print if it is or not, then exit
jal print_palind

clear:
	la $t0, array	# set 'front_ptr' back to array's beginning address
	la $t1, ($s7)	# set 'back_ptr' back to array's last valid address
	lw $s0, ($t0)	# update array[$t0]
	lw $s1, ($t1)	# update array[$t1]
	li $s3, 0	# set 'i' back to 0
	jr $ra

input_loop:
	la $a0, ask_input
	li $v0, 4
	syscall
	li $v0, 5
	syscall 			# Ask & get the input for an integer
	sw $v0, ($t0)			# Set the i-th item in the array as $v0
	addi $s3, $s3, 1		# increment i
	addi $t0, $t0, 4		# move the pointer to the next
	blt $s3, $s2, input_loop	# check the condition, (i < valid)
	jr $ra
	
print_loop:
	la $a0, ($s0)
	li $v0, 1
	syscall				# print the item
	la $a0, wspc
	li $v0, 4
	syscall				# seperate items using a whitespace
	addi $s3, $s3, 1		# increment i
	addi $t0, $t0, 4		# move the pointer to the next
	lw $s0, ($t0)			# update array[$t0]
	blt $s3, $s2, print_loop	# check the condition, i < valid
	jr $ra
	
palind_loop:	
	bne $s0, $s1, set_not_palind	# set 'is_palindrome' to 0 if arr[$t0] != arr[$t1]
	addi $s3, $s3, 1		# increment i
	addi $t0, $t0, 4		# move the front_ptr to the next
	subi $t1, $t1, 4		# move the back_ptr to the prev
	lw $s0, ($t0)			# update arr[$t0]
	lw $s1, ($t1)			# update arr[$t1]
	blt $s3, $t2, palind_loop	# check the condition, i < (valid/2)
	jr $ra
	
print_palind:
	beq $s4, 0, print_else
	la $a0, is_palindrome	# if 'is_palindrome' is not 0, print yes
	li $v0, 4
	syscall	
	jal exit
	
print_else:
	la $a0, not_palindrome	# else, print no
	li $v0, 4
	syscall
	jal exit

# check_bounds:
	## TODO: if out of bounds, set 'valid' to a proper value
	# max_size: li $v0, 20
	# min_size: li $v0, 0
#	jr $ra
	
set_not_palind: 
	li $s4, 0
	jr $ra

exit:	
	li $v0, 10
	syscall		# exit the program as we have found if the array is a palindrome
	jr $ra
		.data
array:		.space  80 	# an array with 20 items
ask_size:	.asciiz "Enter the size of the list, 20 max: "
ask_input:	.asciiz "Enter an integer: "
is_palindrome:	.asciiz "\nThe array is a palindrome."
not_palindrome:	.asciiz "\nThe array is not a palindrome."
wspc:		.asciiz " "
