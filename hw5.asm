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
	
	# N of 0 or less
	li $v0, 0
	ble $s2, $0, return_add_N_terms_to_polynomial

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
		bne $t0, $0, exp_exists_loop
		
		# Empty polynomial, create term and put it as head
		move $a0, $s4
		move $a1, $s5
		jal create_term
		ble $v0, $0, advance_add_terms_loop	# Can't add invalid term
		sw $v0, 0($s0)
		addi $s3, $s3, 1	# Increment terms added
		addi $s2, $s2, -1	# Decrement N
		j advance_add_terms_loop
		
		exp_exists_loop:	
			lw $t1, 4($t0)			# Get exponent of current term
			beq $t1, $s5, advance_add_terms_loop
			lw $t0, 8($t0)			# Update current term to next_term
			bne $t0, $0, exp_exists_loop	# If next_term is null, stop
					
		# Create term, then place it in the correct spot =======================================
		move $a0, $s4
		move $a1, $s5
		jal create_term
		ble $v0, $0, advance_add_terms_loop
	
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
	addi $sp, $sp, -28
	sw $ra, 0($sp)
	sw $s0, 4($sp)		# Store pointer to head of polynomial
	sw $s1, 8($sp)		# Store terms array
	sw $s2, 12($sp)		# Store N
	sw $s3, 16($sp)		# Store return value (number of terms updated)
	sw $s4, 20($sp)		# Store current coefficient
	sw $s5, 24($sp)		# Store current exponent
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	li $s3, 0	
	
	# N of 0 or less
	li $v0, 0
	ble $s2, $0, return_update_N_terms_in_polynomial
	
	# Input polynomial is empty
	lw $t0, 0($s0)
	beq $t0, $0, return_update_N_terms_in_polynomial
	update_terms_loop:	
		lw $s4, 0($s1)		# Coefficient
		lw $s5, 4($s1)		# Exponent
	
		# Check if term is (0, -1)
		bne $s4, $0, notTerminalTerm2
		li $t0, -1
		bne $s5, $t0, notTerminalTerm2			
		move $v0, $s3
		j return_update_N_terms_in_polynomial 	# Pair (0, -1) found
	
		notTerminalTerm2:					
		# Don't need to create new term, just update old one
		beq $s4, $0, advance_update_terms_loop		# Coefficient of 0
		blt $s5, $0, advance_update_terms_loop		# Exponent < 0
		
		lw $t0, 0($s0)		# First term of polynomial
		find_where_to_update_loop:
			lw $t1, 4($t0)			# Get exponent of current term
			beq $t1, $s5, spot_found2	# Replace coefficient at current term	
			lw $t0, 8($t0)			# Move to next term
			bne $t0, $0, find_where_to_update_loop
		j advance_update_terms_loop		# Exponent not found in polynomial, skip
		
		spot_found2:		
		sw $s4, 0($t0)		# Update coefficient at appropriate term
		move $t0, $sp		
		li $t1, 0		# Loop counter denoting amount of bytes to move on $sp
		sll $t2, $s3, 2		# End condition = 4 * relevant elements on $sp
		contains_loop:
			lw $t3, 0($t0)
			beq $t3, $s5, advance_update_terms_loop
			addi $t0, $t0, 4
			addi $t1, $t1, 4
			blt $t1, $t2, contains_loop
		
		addi $sp, $sp, -4
		sw $s5, 0($sp)
		addi $s3, $s3, 1	# Increment terms updated
		addi $s2, $s2, -1	# Decrement N
		# ======================================================================================
	
		advance_update_terms_loop:
		addi $s1, $s1, 8	# Increment terms array by 2 words
		bne $s2, $0, update_terms_loop

	move $v0, $s3			# In case $s2 reaches 0
	return_update_N_terms_in_polynomial:
	sll $s3, $s3, 2			# Restore stack space used to store updated exponents
	add $sp, $sp, $s3
	
	lw $ra, 0($sp)
	lw $s0, 4($sp)		
	lw $s1, 8($sp)		
	lw $s2, 12($sp)		
	lw $s3, 16($sp)		
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	addi $sp, $sp, 28
	jr $ra
	
get_Nth_term:
	# Assume no term exists
	li $v0, -1
	li $v1, 0
	ble $a1, $0, return_get_Nth_term		# Can't have negative term

	lw $t0, 0($a0)				# Get first term
	get_Nth_term_loop:
		beq $t0, $0, return_get_Nth_term	# End of polynomial reached
		addi $a1, $a1, -1
		beq $a1, $0, NthTermReached
		lw $t0, 8($t0)				# Move on to next term
		j get_Nth_term_loop
	
	NthTermReached:
	lw $v0, 4($t0)
	lw $v1, 0($t0)

	return_get_Nth_term:
	jr $ra
	
remove_Nth_term:
	# Assume no term exists
	li $v0, -1
	li $v1, 0
	ble $a1, $0, return_get_Nth_term		# Can't have negative term

	lw $t0, 0($a0)					# Get first term
	li $t1, 1
	bne $t1, $a1, remove_Nth_term_loop
	# Handle N input of 1
	beq $t0, $0, return_remove_Nth_term		# Handle empty polynomial
	lw $v0, 4($t0)					# Exponent return value
	lw $v1, 0($t0)					# Coefficient return value
	lw $t0, 8($t0)					# Get next term of first term
	sw $t0, 0($a0)					# Store next term as new first term
	j return_remove_Nth_term
	
	remove_Nth_term_loop:
		beq $t0, $0, return_get_Nth_term	# End of polynomial reached
		addi $a1, $a1, -1
		beq $a1, $0, NthTermReached2
		move $t1, $t0				# Store previous middle term as left term (1)
		lw $t0, 8($t0)				# Move on to middle term (2)
		beq $t0, $0, reachedLastTerm
		lw $t2, 8($t0)				# Get right term (3)
		j advance_remove_Nth_term_loop
		
		reachedLastTerm:
		li $t2, 0
		advance_remove_Nth_term_loop:
		j remove_Nth_term_loop
	
	NthTermReached2:
	sw $t2, 8($t1)		# Store curr -> next as prev -> next
	lw $v0, 4($t0)		# Exponent
	lw $v1, 0($t0)		# Coefficient

	return_remove_Nth_term:
	jr $ra
	
add_poly:
	addi $sp, $sp, -44
	sw $ra, 0($sp)		
	sw $s0, 4($sp)		# Store polynomial p
	sw $s1, 8($sp)		# Store polynomial q
	sw $s2, 12($sp)		# Store polynomial r
	sw $s3, 16($sp)		# Store current term of p
	sw $s4, 20($sp)		# Store current term of q
	sw $s5, 24($sp)		# Terms array to use add_N_terms_to_polynomial
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	addi $s5, $sp, 28	# Terms array takes up bytes 28-43 (enough for 4 words)
	sw $0, 0($s2)		# Verify r is empty
	# End terms array with (0, -1)
	li $t0, -1		
	sw $0, 8($s5)
	sw $t0, 12($s5)
	
	li $v0, 0
	# Get base case out of the way: p and q both equal 0
	check_if_p_is_0:
	lw $t0, 0($s0)
	bne $t0, $0, actual_add_poly
	check_if_q_is_0:
	lw $t0, 0($s1)
	bne $t0, $0, actual_add_poly
	sw $0, 0($s2)		# Store 0 in $s2
	j return_add_poly
	
	actual_add_poly:
	li $v0, 1
	# If one polynomial is empty, return the other
	lw $s3, 0($s0)		# Get first term of p
	lw $s4, 0($s1)		# Get first term of q
	beq $s3, $0, return_q
	beq $s4, $0, return_p
	j add_poly_loop
	
	return_q:
	sw $s4, 0($s2)
	j return_add_poly
	
	return_p:
	sw $s3, 0($s2)
	j return_add_poly
	
	add_poly_loop:
		# Load exponents
		lw $t0, 4($s3)
		lw $t1, 4($s4)
		
		bgt $t0, $t1, pExpGreater
		bgt $t1, $t0, qExpGreater
		
		pAndQExpEqual:		# Obtain coefficients, add them together by calling add_terms						
		move $a0, $s2		# Argument 0: Polynomial r
		sw $t0, 4($s5)		# Exponent in 2nd word of int[] terms
		lw $t0, 0($s3)
		lw $t1, 0($s4)
		add $t0, $t0, $t1	# Coefficient
		sw $t0, 0($s5)		# Put coefficient in 1st word of int[] terms
		move $a1, $s5		# Argument 1: int[] terms
		li $a2, 1		# Argument 2: N
		jal update_N_terms_in_polynomial	# First call update terms, if 0 updated terms add		
		bne $v0, $0, skip_add_terms
		# =================================
		move $a0, $s2
		move $a1, $s5
		li $a2, 1
		jal add_N_terms_to_polynomial
		# =================================
		skip_add_terms:	
		lw $s3, 8($s3)		# Move to next term of p
		lw $s4, 8($s4)		# Move to next term of q
		j advance_add_poly_loop
		
		pExpGreater:
		move $a0, $s2		# Argument 0: Polynomial r
		sw $t0, 4($s5)		# Exponent in 2nd word of int[] terms
		lw $t0, 0($s3)
		sw $t0, 0($s5)		# Put coefficient in 1st word of int[] terms
		move $a1, $s5		# Argument 1: int[] terms
		li $a2, 1		# Argument 2: N
		jal add_N_terms_to_polynomial
		lw $s3, 8($s3)
		j advance_add_poly_loop
		
		qExpGreater:
		move $a0, $s2		# Argument 0: Polynomial r
		sw $t1, 4($s5)		# Exponent in 2nd word of int[] terms
		lw $t0, 0($s4)
		sw $t0, 0($s5)		# Put coefficient in 1st word of int[] terms
		move $a1, $s5		# Argument 1: int[] terms
		li $a2, 1		# Argument 2: N
		jal add_N_terms_to_polynomial
		lw $s4, 8($s4)		# Move to next term of q
				
		advance_add_poly_loop:		
		beq $s3, $0, terms_in_poly_q_left_over
		beq $s4, $0, terms_in_poly_p_left_over
		j add_poly_loop
	
	terms_in_poly_q_left_over:	# Link q to the end of r
	beq $s4, $0, no_terms_in_either_poly_left_over	
	lw $t0, 0($s2)
	findLastTermOfR:
		move $t1, $t0		# Store previous value of $t0
		lw $t0, 8($t0)
		bne $t0, $0, findLastTermOfR
	sw $s4, 8($t1)
	li $v0, 1
	j return_add_poly
	
	terms_in_poly_p_left_over:	# Link p to the end of r
	beq $s3, $0, no_terms_in_either_poly_left_over
	lw $t0, 0($s2)
	findLastTermOfR2:
		move $t1, $t0		# Store previous value of $t0
		lw $t0, 8($t0)		
		bne $t0, $0, findLastTermOfR2
	sw $s3, 8($t1)
	li $v0, 1
	j return_add_poly
	
	no_terms_in_either_poly_left_over:
	# Check that the output value isn't 0 (null)
	li $v0, 0
	lbu $t0, 0($s2)
	beq $t0, $0, return_add_poly
	li $v0, 1
	
	return_add_poly:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	addi $sp, $sp, 44
	jr $ra
	
mult_poly:
	addi $sp, $sp, -52
	sw $ra, 0($sp)
	sw $s0, 4($sp)		# Store polynomial p
	sw $s1, 8($sp)		# Store polynomial q
	sw $s2, 12($sp)		# Store polynomial r
	sw $s3, 16($sp)		# Store current term in p
	sw $s4, 20($sp)		# Store current term in q
	sw $s5, 24($sp)		# Store address of 4-word long array for pair array
	sw $s6, 28($sp)		# Store temporary monomial address
	sw $s7, 32($sp)		# Store temporary output polynomial (r')
	move $s0, $a0			
	move $s1, $a1			
	move $s2, $a2			
	addi $s5, $sp, 36	# Pair array is from 36($sp) to 51($sp)
	sw $0, 0($s2)		# Verify r is empty
	# Store (0, -1) in the last two words
	li $t0, -1
	sw $0, 8($s5)
	sw $t0, 12($s5)
	# Allocate space for blank output polynomial (r')
	li $v0, 9
	li $a0, 4
	syscall
	move $s7, $v0
	sw $0, 0($s7)

	li $v0, 1
	# If either p or q are null, return the other.
	lw $t0, 0($s0)
	lw $t1, 0($s1)
	beq $t0, $0, return_q_mult
	beq $t1, $0, return_p_mult
	j actual_mult_poly
	
	return_q_mult:
	beq $t1, $0, return_0
	sw $t1, 0($s2)
	j return_mult_poly
	
	return_p_mult:
	sw $t0, 0($s2)
	j return_mult_poly
	
	return_0:
	li $v0, 0
	j return_mult_poly
	
	actual_mult_poly:
	lw $s3, 0($s0)			# First term in p
	mult_poly_p_loop:		# Loop through each element in p
		lw $s4, 0($s1)			# Reset q to start
		mult_poly_q_loop:		# Loop through each element in q
			# Call init_polynomial then add that polynomial to r
			# Need to allocate memory for $a0: polynomial argument
			li $v0, 9
			li $a0, 4
			syscall
			move $s6, $v0		# Need this polynomial again to call add_poly later
			
			lw $t0, 4($s3)		# Exponent of term in p
			lw $t1, 4($s4)		# Exponent of term in q
			add $t0, $t0, $t1	# exp_new = exp_p + exp_q
			sw $t0, 4($s5)		# Store exponent in word 4-7 of pair array
			lw $t0, 0($s3)		# Coefficient of term in p
			lw $t1, 0($s4)		# Coefficient of term in q
			mult $t0, $t1
			mflo $t0		# Move product into $t0
			sw $t0, 0($s5)		# Store coefficient in word 0-3 of pair array
			move $a0, $s6
			move $a1, $s5		# Pairs array
			jal init_polynomial
			ble $v0, $0, advance_mult_poly_q_loop	# Shouldn't ever happen? Just in case
			
			# result_poly is now poly_p
			move $t0, $s7
			
			# Allocate memory for new location of r
			li $v0, 9
			li $a0, 4
			syscall
			move $s7, $v0
			
			# Call add_poly with r and the newly initiated monomial																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																				
			move $a0, $t0
			move $a1, $s6
			move $a2, $s7
			jal add_poly
			
			advance_mult_poly_q_loop:
			lw $s4, 8($s4)		# Advance to next term of q	
			bne $s4, $0, mult_poly_q_loop
	
		lw $s3, 8($s3)		# Advance to next term of p
		bne $s3, $0, mult_poly_p_loop

	li $v0, 1
	lw $t0, 0($s7)
	sw $t0, 0($s2)	# Put final address of $s7 (temporary output polynomial) into r for returning
	
	return_mult_poly:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	lw $s6, 28($sp)
	lw $s7, 32($sp)
	addi $sp, $sp, 52
	jr $ra
