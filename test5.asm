.data
vect1:      .word   -0x1234,0x11,44,5466,121111,0xffffff
vect2:      .word   0x5678
vect3:      .word   0x9abc,0
vect4:      .word   0xdef0
vect5:      .word   0x1357,  -432
vect6:      .word   0x2468, 0x0

.text
Label4:      

            addi    $t1,$s2,-1  

            sw      $0, vect1($s4)   
            lw      $t9, Label4($s1) 

            sb      $t7, -99999999($s3)  
            lb      $k0, 100($s0)