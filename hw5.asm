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
