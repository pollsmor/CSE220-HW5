.data
pair: .word 2 3
p: .word 0

.text:
main:
	la $a0, p
   	la $a1, pair
   	jal init_polynomial
   	move $s0, $v0

    	#write test code
	move $a0, $s0	
	li $v0, 1
	syscall
	li $a0, '\n'
	li $v0, 11
	syscall	
	
	blt $s0, $0, skip_init_polynomial_test
	
	la $t0, p
	lw $t0, 0($t0)
	lw $a0, 0($t0)		# Coefficient
	li $v0, 1
	syscall
	li $a0, '\n'
	li $v0, 11
	syscall
	
	lw $a0, 4($t0)		# Exponent
	li $v0, 1
	syscall

	skip_init_polynomial_test:
    	li $v0, 10
    	syscall

.include "hw5.asm"
