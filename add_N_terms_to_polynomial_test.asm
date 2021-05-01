.data
pair: .word 12 5
terms: .word 2 2 4 3 5 0 0 -1
p: .word 0
N: .word 4

.text:
main:
	la $a0, p
  	la $a1, pair
    	jal init_polynomial

    	la $a0, p
    	la $a1, terms
    	lw $a2, N
    	jal add_N_terms_to_polynomial

    	#write test code
	move $a0, $v0
	li $v0, 1
	syscall
	li $a0, '\n'
	li $v0, 11
	syscall
	
	# Print out polynomial
	la $t0, p
	lw $t0, 0($t0)
	test_add_N_terms_loop:
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
		bne $t0, $0, test_add_N_terms_loop

    	li $v0, 10
    	syscall

.include "hw5.asm"
