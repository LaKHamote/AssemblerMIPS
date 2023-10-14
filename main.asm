.text
		#   debugger
		#move	$a0,$v1
		#jal 	printChar
		#j	end


		
		jal	readFile
		la	$s7,fileWords 			# ponteiro para o texto
		#jal 	printArq
		jal 	consumeBlankLines
		jal 	readByte
		bne	$v1,'.',printErrorMsg
		jal	readByte
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
		
findText:	jal 	consumeBlankLines
		jal 	readByte
		bne	$v1,'.',printErrorMsg
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
		move	$a0,$t0		# passar file descriptor para fech�-lo
		syscall
		jr	$ra

readByte:	# ler um Byte (Char) e armazena em $v1, incrementando o ponteiro
		lbu	$v1,($s7)
		addi	$s7,$s7,1
		jr	$ra
		
printChar:	# mostrar na tela o conte�do de $a0 como char
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

consumeBlankLines: # consome todos os '\n'
		lbu	$t1,($s7)
		addi	$s7,$s7,1
		beq	$t1,10,consumeBlankLines
		addi	$s7,$s7,-1
		jr	$ra
		
		
dataSection:	# provavelmente a primeira coisa � label -> NAME: .STORAGEFORMAT VALUE
		jal	consumeBlankLines
		
		jal	findText
		j	end

textSection:	# provavelmente a primeira coisa eh cmd -> opcode $xx, $yy                                               #!!!!!!!!! checar se os $t estao mantendo seus valores originais

		#li	$a0,'W'
		#jal 	printChar
		
		jal	consumeBlankLines
		move	$t7,$s7				# salvo o endereco que estou lendo para comparar do zero prox opcodes
		move	$t0,$zero			# contador para indice do array dos opcodes
		move	$t1,$zero			# contador para indice do char do opcode da chave atual
lp:		lb	$t2,cmdKeys($t1)
		move	$a0,$t2
		jal 	printChar
		jal	readByte
		beq	$v1,10,match			# se lemos '/n' ou ' ' , ja lemos 
		beq	$v1,' ',match			# a palavra toda e temos um match
		bne	$t2,$v1,nextKey	
		addi	$t1,$t1,1		
		j 	lp		
match:		bne	$t2,',',nextKey			# por convencao as chaves terminam em ','. Entao garanto que li a chave toda para evitar palavras contidas: add esta em addi
		li	$a0,'V'
		jal 	printChar
		j 	end
findNextKey:	addi	$t1,$t1,1
		lb	$t2,cmdKeys($t1)
nextKey:	bne	$t2,',',findNextKey
		addi	$t1,$t1,1
		addi	$t0,$t0,4			# salvo o index do proximo word (4 bytes)
		move	$s7,$t7				# reseto o ponteiro do arq para comparar com outro opcode
		j	lp

	
		
		
		
		
	
	
	
.data
	filePath: 	.asciiz 	"D:/example_saida.asm"
	fileWords: 	.space  	1024
	errorMsg:	.asciiz 	"Comando n�o reconhecido"
	sectionKeys:	.asciiz		"data,text"
	cmdKeys:	.asciiz		"add,addi,addiu,addu,and,andi,beq,bgez,bgezal,bne,clo,div,j,jal,jr,lb,lui,lw,mfhi,mflo,movn,mul,mult,nor,or,ori,sb,sll,slt,slti,sltu,sra,srav,srl,sub,subu,sw,xor,xori"
	opCode:		.word		0x020,0x08
	
	
	
