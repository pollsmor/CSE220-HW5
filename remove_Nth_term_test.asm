.data
pair: .word 4 3
terms: .word 0 -1
terms2: .word 4 5 1 3 0 -1
p: .word 0
N: .word 3
N1: .word 1

.text:
main:
	la $a0, p
	la $a1, pair
    	jal init_polynomial

    	la $a0, p
    	la $a1, terms
    	lw $a2, N
    	jal add_N_terms_to_polynomial

    	la $a0, p
    	lw $a1, N1
    	jal remove_Nth_term

    	#write test code
    	move $a0, $v0
    	li $v0, 1
    	syscall
    	li $a0, '\n'
    	li $v0, 11
    	syscall
    	move $a0, $v1
    	li $v0, 1
    	syscall
    	li $a0, '\n'
    	li $v0, 11
    	syscall

	# Print out polynomial
	la $t0, p
	lw $t0, 0($t0)
	beq $t0, $0, skip_remove_test
	test_remove_N_terms_loop:
		lw $a0, 0($t0)		# Coefficient
		li $v0, 1
		syscall
		li $a0, ' '
		li $v0, 11
		syscall
		lw $a0, 4($t0)		# Exponent
		li $v0, 1
		syscall
		li $a0, '\n'
		li $v0, 11
		syscall
		lw $t0, 8($t0)		# Update to next_term
		bne $t0, $0, test_remove_N_terms_loop

	skip_remove_test:
	# Add from empty polynomial
	la $a0, p
    	la $a1, terms2
    	lw $a2, N
    	jal add_N_terms_to_polynomial
    	
    	# Print out polynomial
	la $t0, p
	lw $t0, 0($t0)
	
	test_remove_N_terms_loop2:
		lw $a0, 0($t0)		# Coefficient
		li $v0, 1
		syscall
		li $a0, ' '
		li $v0, 11
		syscall
		lw $a0, 4($t0)		# Exponent
		li $v0, 1
		syscall
		li $a0, '\n'
		li $v0, 11
		syscall
		lw $t0, 8($t0)		# Update to next_term
		bne $t0, $0, test_remove_N_terms_loop2
	
    	li $v0, 10
    	syscall

.include "hw5.asm"
