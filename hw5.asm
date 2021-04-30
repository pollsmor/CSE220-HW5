############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
.text:

create_term:
	# Coefficient of 0 or negative exponent
	li $v0, -1
	beq $a0, $0, return_create_term
	blt $a1, $0, return_create_term
	
	# Allocate memory + fill coefficient/exponent
	li $a0, 12
	li $v0, 9
	syscall
	sw $a0, 0($v0)
	sw $a1, 4($v0)
	sw $0, 8($v0)

	return_create_term:
	jr $ra
	
init_polynomial:
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
