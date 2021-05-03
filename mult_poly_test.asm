.data
p_pair: .word 5 2
p_terms: .word 7 1 1 3 0 -1
q_pair: .word 3 3
q_terms: .word 1 8 0 -1
p: .word 0
q: .word 0
r: .word 0
N: .word 2

.text:
main:
	la $a0, p
	la $a1, p_pair
    	jal init_polynomial

    	la $a0, p
    	la $a1, p_terms
    	lw $a2, N
    	jal add_N_terms_to_polynomial
    	
    	la $a0, q
    	la $a1, q_pair
    	jal init_polynomial

    	la $a0, q
    	la $a1, q_terms
    	lw $a2, N
    	jal add_N_terms_to_polynomial

    	la $a0, p
    	la $a1, q
    	la $a2, r
    	jal mult_poly
    	move $s0, $v0

   	#write test code
   	move $a0, $v0
   	li $v0, 1
   	syscall
   	li $a0, '\n'
   	li $v0, 11
   	syscall
   	
   	beq $s0, $0, skip_test_mult

	# Print out polynomial
	la $t0, r
	lw $t0, 0($t0)
	test_mult_poly_loop:
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
		bne $t0, $0, test_mult_poly_loop

	skip_test_mult:
    	li $v0, 10
    	syscall

.include "hw5.asm"
