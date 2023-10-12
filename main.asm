.text
		#   debugger
		#move	$a0,$v1
		#jal 	printChar
		#j	end


		
		jal	readFile
		la	$s7,fileWords # ponteiro para o texto
		#jal 	printArq
blackLine:	jal	readByte			# ficar em lp infinito enquanto
		beq	$v1,10,blackLine		# tiver linhas em branco ( 10 == '\n' ) 
		bne	$v1,'.',printErrorMsg
maybeData:	jal	readByte
		bne	$v1,'d',maybeText
		jal	readByte
		bne	$v1,'a',printErrorMsg
		jal	readByte
		bne	$v1,'t',printErrorMsg
		jal	readByte
		bne	$v1,'a',printErrorMsg
		jal	readByte
		bne	$v1,10,printErrorMsg
		j	dataSection
maybeText:	bne	$v1,'t',printErrorMsg
		jal	readByte
		bne	$v1,'e',printErrorMsg
		jal	readByte
		bne	$v1,'x',printErrorMsg
		jal	readByte
		bne	$v1,'t',printErrorMsg
		jal	readByte
		bne	$v1,10,printErrorMsg
		j	textSection	
		

	


end:		# parar o programa
   		li 	$v0, 10
  		syscall	



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
		move	$a0,$t0		# passar file descriptor para fechá-lo
		syscall
		jr	$ra

readByte:	# ler um Byte (Char) e armazena em $v1, incrementando o ponteiro
		lbu	$v1,($s7)
		addi	$s7,$s7,1
		jr	$ra
		
printChar:	# mostrar na tela o conteúdo de $a0 como char
		li	$v0,11
		syscall	
		jr	$ra				
						
printArq:	# mostrar na tela no o arquivo lido
		li	$v0,4
		la	$a0,fileWords
		syscall
		jr	$ra

printErrorMsg:	li	$v0,4
		la	$a0,errorMsg
		syscall
		j	end

readUntilBlank: # to pensando em tlz ler uma palavra para comparar facilmente depois
		
		
dataSection:	# provavelmente a primeira coisa é label -> NAME: .STORAGEFORMAT VALUE
		jal	readByte			# ficar em lp infinito enquanto
		beq	$v1,10,dataSection		# tiver linhas em branco ( 10 == '\n' )
		 
		j	end

textSection:	# provavelmente a primeira coisa é cmd -> opcode $, $
		jal	readByte			# ficar em lp infinito enquanto
		beq	$v1,10,dataSection		# tiver linhas em branco ( 10 == '\n' )
		
		j	end

	
		
		
		
		
	
	
	
.data
	filePath: 	.asciiz "D:/example_saida.asm"
	fileWords: 	.space  1024
	errorMsg:	.asciiz "Comando não reconhecido"
	labelsArea:	.space 1024 # ???????? Tlz separar uma área de memória apenas para as labels lidas
	 
	
	
	
