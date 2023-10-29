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
		sb	$zero,-1($t7)		# substituir o o �ltimo '\n' que, por algum motivo � lido, por 0 para ficar no formato asciiz
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
mi		la	$t0,filePath
		la	$t1,openTextFile
		la	$t2,openDataFile
getArqName:	lb	$t3,($t0)
		beq	$t3,'.',setArqMif
		sb	$t3,($t1)
		sb	$t3,($t2)
		addi 	$t0,$t0,1
		addi 	$t1,$t1,1
		addi 	$t2,$t2,1
		j	getArqName
setArqMif:	li	$t3,'_'
		sb	$t3,($t1)
		li	$t3,'t'
		sb	$t3,1($t1)
		li	$t3,'e'
		sb	$t3,2($t1)
		li	$t3,'x'
		sb	$t3,3($t1)
		li	$t3,'t'
		sb	$t3,4($t1)
		li	$t3,'_'
		sb	$t3,($t2)
		li	$t3,'d'
		sb	$t3,1($t2)
		li	$t3,'a'
		sb	$t3,2($t2)
		li	$t3,'t'
		sb	$t3,3($t2)
		li	$t3,'a'
		sb	$t3,4($t2)
		li	$t3,'.'
		sb	$t3,5($t1)
		sb	$t3,5($t2)
		li	$t3,'m'
		sb	$t3,6($t1)
		sb	$t3,6($t2)
		li	$t3,'i'
		sb	$t3,7($t1)
		sb	$t3,7($t2)
		li	$t3,'f'
		sb	$t3,8($t1)
		sb	$t3,8($t2)
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
		msgNoArq:	.asciiz		"Arquivo n�o encontrado ou vazio. Gostaria de informar outro path?"
		
