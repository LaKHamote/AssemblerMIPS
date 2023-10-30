.data
vect1:      .word   -86777


.text
Label4:      

            addi    $t1,$s2,0xff   

            sb      $t7, -99999999($s3)  
            lb      $k0, vect1($s0)