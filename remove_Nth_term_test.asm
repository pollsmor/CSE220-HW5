.data
pair: .word 12 8
terms: .word 16 5 1 8 0 -1
p: .word 0
N: .word 3
N1: .word 2

.text:
main:
    la $a0, p
    la $a1, pair
    jal init_polynomial

    la $a0, p
    la $a1, terms
    lw $s2, N
    jal add_N_terms_to_polynomial

    la $a0, p
    lw $a1, N1
    jal remove_Nth_term

    #write test code

    li $v0, 10
    syscall

.include "hw5.asm"
