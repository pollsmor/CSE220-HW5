.data
coeff: .word 2
exp: .word -3

.text:
main:
	lw $a0, coeff
    	lw $a1, exp
    	jal create_term
    	move $s0, $v0
    	
    	move $a0, $s0
	li $v0, 1
	syscall
	li $a0, '\n'
	li $v0, 11
	syscall
    	
	blt $s0, $0, skip_create_term_test
	 
    	#write test code
	lw $a0, 0($s0)
	li $v0, 1
	syscall
	li $a0, '\n'
	li $v0, 11
	syscall
	lw $a0, 4($s0)
	li $v0, 1
	syscall
	li $a0, '\n'
	li $v0, 11
	syscall
	lw $a0, 8($s0)
	li $v0, 1
	syscall
	
	skip_create_term_test:
   	li $v0, 10
    	syscall

.include "hw5.asm"
