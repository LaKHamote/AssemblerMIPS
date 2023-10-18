.text

reler:		li	$v0,54
		la	$a0,usrmsg
		la	$a1,filePath
		li	$a2,64
		syscall
		
		la	$t7,filePath
lp:		lb	$t0,($t7)
		addi 	$t7,$t7,1
		beq	$t0,0,reler		# apenas será 0 se não for digitado nada
		bne	$t0,10,lp		#
		li	$t0,0			# 
		sb	$t0,-1($t7)		# substituir o o último '\n' que, por algum motivo é lido, por 0 para indicar que li tudo
		
		
readFile:	# ler o filePath 
		li	$v0,13
		la	$a0,filePath
		li	$a1,0
		syscall
		move 	$t0,$v0  	# armazenar file descriptor
		# armazenar o texto com $a1 de ponteiro
		li 	$v0,14
		move	$a0,$t0		# passar file descriptor
		la	$a1,fileWords
		la	$a2,1024
		syscall
		# fechar arquivo 
		li 	$v0,16
		move	$a0,$t0		# passar file descriptor para fecha-lo
		syscall
		
		
		
		
		
		

end:		# parar o programa
   		li 	$v0, 10
  		syscall	

.data
		filePath:	.space		64
		fileWords: 	.space  	1024
		usrmsg:		.asciiz		"Por favor digite o PATH completo pro arquivo a ser lido"