  .data
A:      .word    0x01234abc	
B:      .word    0x004a5f32	
res:    .word    0x00       	
  .text             
        
        lw      $s0, 0($s0)                  

        lw      $s1, 0($s1)     
        xor     $s2, $s2, $s2   
	   srav 	 $t1, $s0, $s1 
        addi    $t0, $zero, 1          
loop:   beq     $s1,$zero, fim  
        and     $t1,$s1,$t0 
        bne     $t1,$zero, soma 
volta:  srl     $s1,$s1,1        
        sll     $s0,$s0,1        
        j       loop
soma:   addu    $s2, $s2, $s0
        j       volta
fim:    
        sw      $s2, 0($t0)
aqui:   j       aqui		 
