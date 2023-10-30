.data
a: .word 1, 2, 3

.text
add $t0,$zero,$zero
lw $t1, a($t0)
addi $t0,$t0,4
lw $t2, a($t0)
addi $t0,$t0,4
lw $t3, a($t0)
clo $t1, $t2
add $t1, $t2, $t3
xor $t4, $t1, $t2
Label: addi $t5, $t4, 10
xori $t6, $t5, 20
sb $t4, 0($t0)
sb $t5, 4($t0)
sb $t6, 8($t0)
lb $t1, 100($t2)
movn $t1, $t2, $t3
mul $t1, $t2, $t6