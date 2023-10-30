.data
vect1:      .word   -0x1234,0x11,44,5466,121111,0xffffff
vect2:      .word   0x5678
vect3:      .word   0x9abc,0
vect4:      .word   0xdef0
vect5:      .word   0x1357,  -432
vect6:      .word   0x2468, 0x0

.text
Label4:     add     $31,$5,$s1
            addi    $t1,$s2,0x10a 
            addiu   $t2,$v0,5   
            addu    $t3,$a3,$s5
            and     $t4,$s6,$s7
Label2:     
            andi    $t5, $s4, 255
            beq     $s0, $s1, Label5
            bgez    $s2, Label2   
            addi    $t1,$s2,-1  
            bgezal  $s3, Label3 
            bne     $s4, $s5, Label4
            clo     $t6, $s6

            div     $7, $s4
            j       Label5 
Label1:     nor     $v1, $s4, $s0
            jal     Label6
            jr      $ra
            lui     $a1, 0xffff
            mfhi    $t0
Label6:     slt     $t9, $s5, $7
            mflo    $t1
Label3:     movn    $t2, $s2, $s3
            mul     $sp, $s4, $s5
            mult    $22, $s7
            sll     $t8, $s4, 2
            slti    $t0, $s7, 0
            sltu    $fp, $s4, $s0
            sra     $t2, $s0, 3 

            srav    $t3, $s1, $s2
Label5:     srl     $at, $s3, 2  
            sub     $zero, $s4, $s5
            subu    $t6, $s6, $s7 
            or      $t5, $s0, $s1
            xor     $t8, $s0, $s0 
            xori    $t9, $3, 0xff
            ori     $t6, $s2, 255

            sw      $0, vect1($s4)   
            lw      $t9, vect5($s1) 

            sb      $t7, -99999999($s3)  
            lb      $k0, 100($s0)