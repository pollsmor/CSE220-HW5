.data
pair: .word 5 0
terms: .word 3 3 0 -1
new_terms: .word 1 3 0 0 0 -1
p: .word 0
N: .word 3

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
    	la $a1, new_terms
    	lw $a2, N
    	jal update_N_terms_in_polynomial
    	move $s0, $v0
    	
    	move $a0, $v0
    	li $v0, 1
    	syscall
    	li $a0, '\n'
    	li $v0, 11
    	syscall
    	beq $s0, $0, skip_update_test
    	
    	# Print out polynomial again
	la $t0, p
	lw $t0, 0($t0)
	beq $t0, $0, skip_update_test
	test_update_N_terms_loop:
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
		bne $t0, $0, test_update_N_terms_loop

	skip_update_test:
    	li $v0, 10
    	syscall

.include "hw5.asm"
