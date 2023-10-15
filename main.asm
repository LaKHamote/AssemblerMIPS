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
		
dataSection:	# provavelmente a primeira coisa eh label -> NAME: .STORAGEFORMAT VALUE
		jal	consumeBlankLines
		
		jal	findText
		j	end

textSection:	# provavelmente a primeira coisa eh cmd -> cmd $xx,$yy,$zz                                              
		jal	consumeBlankLines
		la	$a0,valuesA
		la	$a1,keysA
		jal	getValueAddr			# pega o endereco relativo a chave passada
		beq	$v0, $zero, proxString
		lb	$s0,($v0)			# salvo o funct do cmd lido
		j 	proxString
proxString:	
	


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
		move	$a0,$t0		# passar file descriptor para fecha-lo
		syscall
		jr	$ra

readByte:	# ler um Byte (Char) e armazena em $v1, incrementando o ponteiro
		lbu	$v1,($s7)
		addi	$s7,$s7,1
		jr	$ra
		
printChar:	# mostrar na tela o conteudo de $a0 como char
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
		addi	$s7,$s7,-1			# volta em 1 o ponteiro do arq para lermos o char != '\n' depois
		jr	$ra

consumeSpaces: # consome todos os ' '
		lbu	$t1,($s7)
		addi	$s7,$s7,1
		beq	$t1,' ',consumeSpaces
		addi	$s7,$s7,-1 			# volta em 1 o ponteiro do arq para lermos o char != ' ' depois
		jr	$ra

		
		
		
		
		
		
		
		
#!!!!!!!!! checar se os $t estao mantendo seus valores originais        
getValueAddr:	# le a palavra atual e retorna, se achar, o ponteiro para o hexa opcode($v0) e fucntion ($v0+1) ou 0 se nao achar
		move	$v0,$zero	      		# a principio assumo que nao achou e altero $v0 apenas se achar
		move	$t7,$s7				# salvo o endereco que estou lendo para comparar do inicio para os proximos comandos da string
		move	$t0,$a0				# ponteiro para indice do array dos opcodes (Hexas)
		move	$t1,$a1				# ponteiro para indice do char a ser lido da string de comandos
checkByte:	lb	$t2,($t1)			# byte lido da string de comandos
		lbu	$t3,($s7)			# byte lido do arq
		addi	$s7,$s7,1
		beq	$t3,' ',match			# se achamos ' ', entao ja lemos palavra toda e temos um match
		bne	$t2,$t3,nextKey	
		addi	$t1,$t1,1		
		j 	checkByte		
findNextKey:	addi	$t1,$t1,1
		lb	$t2,($t1)
		beq	$t2,0,ret			# se achar zero, ja leu a string toda sem achar o comando
nextKey:	bne	$t2,',',findNextKey
		addi	$t1,$t1,1
		addi	$t0,$t0,1			# salvo o index dos proximos byte !!!!!!!!!!!!!!!!!!
		move	$s7,$t7				# reseto o ponteiro do arq para comparar com outro opcode
		j	checkByte
match:		bne	$t2,',',nextKey			# por convencao as chaves terminam em ','. Entao garanto que li a chave toda para evitar palavras contidas: add esta em addi
		move	$v0,$t0
ret:		jr 	$ra

	
		
		
		
		
	
	
	
.data
	filePath: 	.asciiz 	"D:/example_saida.asm"
	fileWords: 	.space  	1024
	errorMsg:	.asciiz 	"Comando nao reconhecido"
	keysA:		.asciiz		"add,addu,and,mfhi,mflo,movn,nor,or,slt,sltu,sub,subu,xor"
	valuesA:	.byte		0x20,0x21,0x24,0x10,0x12,0xb,0x27,0x25,0x2a,0x2b,0x22,0x23,0x26	
