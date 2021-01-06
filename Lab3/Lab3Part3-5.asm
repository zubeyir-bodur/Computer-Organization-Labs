# CS224 Lab 3 Part 3-5
# Section 2
# Author: Zubeyir Bodur
# ID: 21702382
		.text

jal 	createLinkedList
move 	$s0, $v0	# $s0 : address of the given linked list by user


la	$a0, orig_reverse
jal	print_str

move	$a0, $s0
jal	displayReverseOrderRecursive


move	$a0, $s0
jal	duplicateListIterative
move	$s1, $v0	# $s1 : iterative copy of the original LL

la	$a0, iter_reverse
jal	print_str

move	$a0, $s1
jal	displayReverseOrderRecursive


move	$a0, $s0
addi	$sp, $sp, -4
sw	$s1, 0($sp)
li	$s1, 0
jal	duplicateListRecursive
lw	$s1, 0($sp)
addi	$sp, $sp, 4
move	$s2, $v0	# $s2 : recursive copy of the original LL

la	$a0, recur_reverse
jal	print_str

move	$a0, $s2
jal	displayReverseOrderRecursive

li 	$v0, 10
syscall

# SUBPROGRAMS

# Arguments = > 
# Returns = >	$v0 - address of the head node
createLinkedList:
	addi	$sp, $sp, -20
	sw	$s0, 0($sp)	# head
	sw	$s1, 4($sp)	# number
	sw	$s2, 8($sp)	# cur
	sw	$s3, 12($sp)
	sw	$ra, 16($sp)
	
	la	$a0, ask_input
	jal	print_str	# cout << "enter number 0 to stop"
	li	$v0, 5
	syscall
	move	$s1, $v0	# cin >> number
	move	$s0, $zero	# head = null
	move	$s2, $s0	# cur = head
	
	bnez	$s1, if_1	# if ( number != 0 )
	j	endif_1
if_1:
	li	$a0, 8
	li	$v0, 9
	syscall
	move	$s0, $v0	# head = new Node
	sw	$s1, 4($s0)	# head.item = number
	sw	$zero, 0($s0)	# head.next = null
	move	$s2, $s0	# cur = head
	
	la	$a0, ask_input
	jal	print_str	# cout << "enter number 0 to stop"
	li	$v0, 5
	syscall
	move	$s1, $v0	# cin >> number
	
	bnez	$s1, loop_1	# while ( number != 0 )
	j	endloop_1
loop_1:
	
	li	$a0, 8
	li	$v0, 9
	syscall
	sw	$v0, 0($s2)	# cur.next = new Nod
	lw	$s2, 0($s2)	# cur = cur.next
	sw	$s1, 4($s2)	# cur.item = number
	sw	$zero, 0($s2)	# cur.next = null
	la	$a0, ask_input
	jal	print_str	# cout << "enter number 0 to stop"
	li	$v0, 5
	syscall
	move	$s1, $v0	# cin >> number
	bnez	$s1, loop_1
endloop_1:
	
endif_1:	
	move	$v0, $s0
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$ra, 16($sp)
	addi	$sp, $sp, 20
	jr	$ra


# Arguments = > 
#	$a0 - address of the head node
# Returns = >
displayReverseOrderRecursive:
	addi	$sp, $sp, -16
	sw	$s0, 0($sp)	# head
	sw	$ra, 12($sp)
	move	$s0, $a0
	bne	$s0, $zero, if_2
	j	endif_2
if_2:
	lw	$a0, 0($s0)	# displayReverseOrderRecursive(head.next)
	jal	displayReverseOrderRecursive
	lw	$a0, 4($s0)	# cout << head.item << " "
	jal	print_int
	la	$a0, wspc	
	jal	print_str	
endif_2:

	lw	$s0, 0($sp)
	lw	$ra, 12($sp)
	addi	$sp, $sp, 16
	jr	$ra

# Arguments = > 
#	$a0 - address of the head node of the original LL
# Returns = >
#	$v0 - address of the head node of the duplicate LL
duplicateListIterative:
	addi	$sp, $sp, -20
	sw	$s0, 0($sp)	# head
	sw	$s1, 4($sp)	# copy
	sw	$s2, 8($sp)	# cur
	sw	$s3, 12($sp)	# cur2
	sw	$s4, 16($sp)	# cur2Item
	sw	$ra, 20($sp)
	
	move	$s0, $a0
	li	$a0, 8
	li	$v0, 9
	syscall
	move	$s1, $v0	# copy = new Node
	move	$s2, $s1	# cur = copy
	move	$s3, $s0	# cur2 = head
	bnez	$s3, loop_2	# cur2 != NULL
	j	endloop_2
loop_2:
	li	$a0, 8
	li	$v0, 9
	syscall
	sw	$v0, 0($s2)	# cur.next = new Node
	lw	$s4, 4($s3)	# cur2Item = cur2.item
	sw	$s4, 4($s2)	# cur.item = curr2Item
	lw	$s3, 0($s3)	# cur2 = cur2.next
	beqz	$s3, if_3	# if (cur2 == NULL)
	j	endif_3
if_3:
	sw	$zero, 0($s2)	# cur = NULL
endif_3:
	lw	$s2, 0($s2)	# cur = cur.next
	bnez	$s3, loop_2	# cur2 != NULL
endloop_2:
	move	$v0, $s1	# return copy
	
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$ra, 20($sp)
	jr	$ra

# Arguments = > 
#	$a0 - address of the head node of the original LL
# Returns = >
#	$v0 - address of the head node of the duplicate LL
duplicateListRecursive:
	addi	$sp, $sp, -16
	sw	$s0, 0($sp)	# head
	sw	$s1, 4($sp)	# copy
	sw	$s2, 8($sp)	# headItem
	sw	$ra, 12($sp)
	
	move	$s0, $a0	# save $a0
	beqz	$s0, if_4	# if ( head == NULL)
	li	$a0, 8
	li	$v0, 9
	syscall			
	move	$s1, $v0	# copy = new Node
	move	$a0, $s0	# restore $a0
	lw	$s2, 4($s0)	# headItem = head.item
	sw	$s2, 4($s1)	# copy.item = headItem
	lw	$a0, 0($a0)
	jal	duplicateListRecursive
	sw	$v0, 0($s1)	# copy.next = duplicateListRecursive(head.next)
	move	$v0, $s1	# return copy
	j	endif_4
if_4:
	move	$v0, $zero
endif_4:

	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$ra, 12($sp)
	addi	$sp, $sp, 16
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

ask_input:	.asciiz "Enter integer, 0 to stop : "
orig_reverse:	.asciiz "\nReverse of the orignal list : "
iter_reverse:	.asciiz "\nReverse of the iterative duplicate : "
recur_reverse:	.asciiz "\nReverse of the recursive duplcicate : "
hyphen:		.asciiz " - "
endl:		.asciiz "\n"
wspc:		.asciiz " "