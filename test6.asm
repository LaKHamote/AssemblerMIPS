.data
vect1:      .word   89


.text
            j       Label1
            j       vect1
Label1:     nor     $v1, $s4, $s0
            