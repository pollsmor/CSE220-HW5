############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
.text:

create_term:
	move $t0, $a0		# Store $a0 as I need it for sbrk

	# Coefficient of 0 or negative exponent
	li $v0, -1
	beq $t0, $0, return_create_term
	blt $a1, $0, return_create_term
	
	# Allocate memory + fill coefficient/exponent
	li $a0, 12
	li $v0, 9
	syscall
	sw $t0, 0($v0)
	sw $a1, 4($v0)
	sw $0, 8($v0)

	return_create_term:
	jr $ra
	
init_polynomial:
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $s0, 4($sp)		# Store polynomial pointer
	move $s0, $a0

	lw $a0, 0($a1)		# Coefficient
	lw $a1, 4($a1)		# Exponent
	# Coefficient of 0 or negative exponent
	li $v0, -1
	beq $a0, $0, return_init_polynomial
	blt $a1, $0, return_init_polynomial
	
	jal create_term		# Call create_term with $a0 and $a1 containing the correct args already
	sw $v0, 0($s0)		# Store address of polynomial in p -> head_term
	li $v0, 1

	return_init_polynomial:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	addi $sp, $sp, 8
	jr $ra
	
add_N_terms_to_polynomial:
	# N of 0 or less
	li $v0, 0
	ble $a2, $0, return_add_N_terms_to_polynomial

	addi $sp, $sp, -28
	sw $ra, 0($sp)
	sw $s0, 4($sp)		# Store pointer to head of polynomial
	sw $s1, 8($sp)		# Store terms array
	sw $s2, 12($sp)		# Store N
	sw $s3, 16($sp)		# Store return value (number of terms added)
	sw $s4, 20($sp)		# Store current coefficient
	sw $s5, 24($sp)		# Store current exponent
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	li $s3, 0	

	add_terms_loop:	
		lw $s4, 0($s1)		# Coefficient
		lw $s5, 4($s1)		# Exponent
	
		# Check if term is (0, -1)
		bne $s4, $0, notTerminalTerm
		li $t0, -1
		bne $s5, $t0, notTerminalTerm
		move $v0, $s3
		j return_add_N_terms_to_polynomial 	# Pair (0, -1) found
	
		notTerminalTerm:		
		# Check exponent is not already in the polynomial
		lw $t0, 0($s0)
		exp_exists_loop:
			lw $t1, 4($t0)			# Get exponent of current term
			beq $t1, $s5, advance_add_terms_loop
			lw $t0, 8($t0)			# Update current term to next_term
			bne $t0, $0, exp_exists_loop	# If next_term is null, stop
					
		# Create term, then place it in the correct spot =======================================
		move $a0, $s4
		move $a1, $s5
		jal create_term
		blt $v0, $0, advance_add_terms_loop
	
		# Special case for first term in polynomial
		lw $t0, 0($s0)		# Get first term of polynomial
		lw $t1, 4($t0)		# Get exponent of first term
		blt $s5, $t1, find_spot_to_insert_loop
		# Exponent is larger than first term, set it as the new head		
		sw $t0, 8($v0)		# Set original first term as next_term of just created term
		sw $v0, 0($s0)		# Replace head with new, now largest, term
		addi $s3, $s3, 1	# Increment terms added
		addi $s2, $s2, -1	# Decrement N
		j advance_add_terms_loop
		
		find_spot_to_insert_loop:
			beq $t0, $0, spot_found		# Reached end of polynomial, insert at the end
			lw $t1, 4($t0)			# Get exponent of current term
			blt $t1, $s5, spot_found	# Insert in the middle		
			move $t2, $t0			# Store previous term
			lw $t0, 8($t0)			# Move to next term
			j find_spot_to_insert_loop
		
		spot_found:		
		sw $t0, 8($v0)		# $t0 is the largest term smaller than the one being added -> next
		sw $v0, 8($t2)		# $t2 is the smallest term larger than the one being added -> prev
		addi $s3, $s3, 1	# Increment terms added
		addi $s2, $s2, -1	# Decrement N
		# ======================================================================================
	
		advance_add_terms_loop:
		addi $s1, $s1, 8	# Increment terms array by 2 words
		bne $s2, $0, add_terms_loop

	move $v0, $s3			# In case $s2 reaches 0
	return_add_N_terms_to_polynomial:
	lw $ra, 0($sp)
	lw $s0, 4($sp)		
	lw $s1, 8($sp)		
	lw $s2, 12($sp)		
	lw $s3, 16($sp)		
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	addi $sp, $sp, 28
	jr $ra

update_N_terms_in_polynomial:
	

	jr $ra
	
get_Nth_term:
	jr $ra
	
remove_Nth_term:
	jr $ra
	
add_poly:
	jr $ra
	
mult_poly:
	jr $ra
