.text


		
		jal	getPath		
						
								
										
												
														
																
																				
end:		# parar o programa
   		li 	$v0, 10
  		syscall	
  		
  		
  		
  		
  		
  		
  		
  		
  		
  		
getPath:	li	$v0,54
		la	$a0,msgGetPath
		la	$a1,filePath
		li	$a2,64
		syscall	
		la	$t7,filePath
asciizFormat:	lb	$t0,($t7)
		addi 	$t7,$t7,1
		beqz	$t0,getPath		# apenas ser 0 se nao for digitado nada
		bne	$t0,10,asciizFormat	# procurar \n
		sb	$zero,-1($t7)		# substituir o o último '\n' que, por algum motivo é lido, por 0 para ficar no formato asciiz
		# ler o filePath 
		li	$v0,13
		la	$a0,filePath
		li	$a1,0
		syscall
		move 	$t0,$v0  	# armazenar file descriptor
		# armazenar o texto com $a1 de ponteiro
		li 	$v0,14
		move	$a0,$t0		# passar file descriptor
		la	$a1,fileWords
		la	$a2,4096
		syscall
		# fechar arquivo 
		li 	$v0,16
		move	$a0,$t0		# passar file descriptor para fecha-lo
		syscall
		la	$t7,fileWords
		lb	$t0,($t7)
		beqz	$t0,emptyArq
		jr	$ra
emptyArq:	li	$v0,50
		la	$a0,msgNoArq
		syscall
		beqz	$a0,getPath
		j	end
	
		
		
		
		
		
		


.data
		filePath:	.space		64
		openTextFile:	.space		64
		openDataFile:	.space		64
		fileWords: 	.space  	4096
		msgGetPath:	.asciiz		"Por favor digite o PATH completo pro arquivo asm a ser lido."
		msgNoArq:	.asciiz		"Arquivo não encontrado ou vazio. Gostaria de informar outro path?"
		
