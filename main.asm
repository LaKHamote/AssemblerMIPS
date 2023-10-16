.text
		#   debugger
		#move	$a0,$v1
		#jal 	printChar
		#j	end
add $t0, $s0, $s1
addu $t1, $s2, $s3
and $t2, $s4, $s5
movn $t3, $s6, $s7
nor $t4, $s3, $s5
or $t5, $s0, $s1
slt $t6, $s2, $s3
sltu $t7, $s4, $s5
sub $t8, $s6, $s7
subu $t9, $s0, $t9
xor $t0, $s0, $s1
add $t2, $s1, $s3
addu $t3, $s5, $s7
and $t4, $s2, $s6
movn $t5, $s7, $s4
nor $t6, $s3, $s6
or $t7, $s0, $s5
slt $t8, $s4, $s1
sltu $t9, $s6, $s2
sub $t0, $s7, $s3
subu $t1, $s6, $s5
xor $t6, $s5, $s0






		

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
		jal	readNotNullByte
		bne	$v1,10,printErrorMsg		# checo se depos de ler data nao ha nenhum char significativo
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
		jal	readNotNullByte
		bne	$v1,10,printErrorMsg		# checo se depos de ler text nao ha nenhum char significativo
		j	textSection	
		
dataSection:	# provavelmente a primeira coisa eh label -> NAME: .STORAGEFORMAT VALUE
		jal	consumeBlankLines
		
		jal	findText
		j	end

textSection:	# provavelmente a primeira coisa eh cmd -> cmd $xx,$yy,$zz                                              
		jal	consumeBlankLines
		
		lb	$t0,($s7)
		beq	$t0,0,end
# pra cima, temos a condicao de parada
		
		la	$a0,valuesA
		la	$a1,keysA
		li	$a2,1				# numero de values por key
		jal	getValueAddr			# pega o endereco relativo a chave passada
		beq	$v0, $zero,typeB
		lb	$s0,($v0)			# pego o funct do cmd lido
# pra cima, li o cmd e peguei seu codigo unico -> funct

		jal 	getRegCode
		move	$s2,$v0			# salvo o codigo do registrador rd lido
# pra cima, li o primeito regs e peguei seu codigo unico -> rd
		
		jal 	getRegCode
		move	$s4,$v0			# salvo o codigo do registrador rs lido
# pra cima, li o segundo regs e peguei seu codigo unico -> rs

		jal 	getRegCode
		move	$s3,$v0			# salvo o codigo do registrador rt lido
# pra cima, li o terceiro regs e peguei seu codigo unico -> rt

		addi	$s7,$s7,-1
		jal	readNotNullByte
		bne	$v1,10,printErrorMsg	# muitos parametros
# garanto que terminei de ler a linha toda sem achar mais registradores

		addi	$sp,$sp,-24
		sb	$s0,20($sp)	# funct
		sb	$zero,16($sp) 	# shamt
		sb	$s2,12($sp) 	# rd
		sb	$s3,8($sp)	# rt
		sb	$s4,4($sp)	# rs
		sb	$zero,0($sp)	# opcode
# pra cima, coloco os codigos na pilha

		jal	assemblerR
		move	$t6,$v0
#pra cima, armazeno em $t6 o hexa montado pra instr tipo R		
		
		move	$a0,$t6
		jal	printHexa
		li	$a0,10
		jal	printChar
		
		
# pra cima, escrevo no arquivo a compilacao: PC: hexa
		j 	textSection
		
					
		
		
typeB:		
typeC:###...

					
	


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

readNotNullByte:# ler proxs Bytes (Char) ate achar um (!= ' ') e armazena em $v1, incrementando o ponteiro
		lbu	$v1,($s7)
		addi	$s7,$s7,1
		beq	$v1,' ',readNotNullByte
		jr	$ra
		
printChar:	# mostrar na tela o conteudo de $a0 como char
		li	$v0,11
		syscall	
		jr	$ra
		
printHexa:	# mostrar na tela o conteudo de $a0 como hexadecimal
		li	$v0,34
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

consumeBlankLines: # consome todos os ' ' e '\n' seguidos
		lbu	$t1,($s7)
		addi	$s7,$s7,1
		beq	$t1,' ',consumeBlankLines
		beq	$t1,10,consumeBlankLines
		addi	$s7,$s7,-1			# volta em 1 o ponteiro do arq para lermos o char != '\n' depois
		jr	$ra

consumeSpaces: # consome todos os ' '
		lbu	$t1,($s7)
		addi	$s7,$s7,1
		beq	$t1,' ',consumeSpaces
		addi	$s7,$s7,-1 			# volta em 1 o ponteiro do arq para lermos o char != ' ' depois
		jr	$ra

endInColon:	# ve se uma palavra termina em ':', retorna 1 caso Vdd e 0 Falso
		move	$v0,$zero 			# assumo que nao termina em ':'
		move 	$t7,$s7
		lbu	$t0,($t7)
		addi	$t7,$t7,1
		bne	$t0,' ',endInColon
		lb	$t0,-1($t7)
		bne	$t0,':',noColon
		li	$v0,1
noColon:	jr	$ra
		
#!!!!!!!!! checar se os $t estao mantendo seus valores originais        
getValueAddr:	# le a palavra atual e retorna, se achar, o ponteiro para o(s) valor(es) em $v0(+$a2) ou 0 se nao achar
		move	$v0,$zero	      		# a principio assumo que nao achou e altero $v0 apenas se achar
		move	$t7,$s7				# salvo o endereco que estou lendo para comparar do inicio para os proximos comandos da string
		move	$t0,$a0				# ponteiro para indice do array dos opcodes (Hexas)
		move	$t1,$a1				# ponteiro para indice do char a ser lido da string de comandos
checkByte:	lb	$t2,($t1)			# byte lido da string de comandos
		lbu	$t3,($s7)			# byte lido do arq
		addi	$s7,$s7,1
		beq	$t3,' ',match			# SE achamos ' ', entao ja lemos palavra toda e temos um match
		beq	$t3,',',match			# OU se achamos ',', entao ja lemos palavra toda e temos um match
		beq	$t3,10,match			# OU se achamos '\n', entao ja lemos palavra toda e temos um match
		bne	$t2,$t3,nextKey	
		addi	$t1,$t1,1		
		j 	checkByte		
findNextKey:	addi	$t1,$t1,1
		lb	$t2,($t1)
		beq	$t2,0,notFound			# se achar zero, ja leu a string toda sem achar o comando
nextKey:	bne	$t2,',',findNextKey
		addi	$t1,$t1,1
		add	$t0,$t0,$a2			# pulo os valores da chave atual e indexo os da prox chave
		move	$s7,$t7				# reseto o ponteiro do arq para comparar com outro opcode
		j	checkByte
match:		bne	$t2,',',nextKey			# por convencao as chaves terminam em ','. Entao garanto que li a chave toda para evitar palavras contidas: add esta em addi
		move	$v0,$t0
notFound:	jr 	$ra

#!!! ainda nao ta prft, se tiver espaco entre reg e ',', ele nao consegue compilar	
getRegCode:	# le o registrador atual, se achar, e retorna o codigo em $v0 ou da erro por falta de parametros(registradores)
		addi	$sp,$sp,-4
		sw	$ra,0($sp)
		jal 	readNotNullByte	
		beq	$v1,10,printErrorMsg		# se ler um '\n', ! poucos parametros
		bne	$v1,'$',printErrorMsg		# registradores comecam com $
		lbu	$t1,($s7)
		bltu	$t1,48,printErrorMsg		# aqui lemos um caracter que nao existe nos registradores
		la	$a1,regKeysNaN			# assumo que o registrador esta escrito com seu 'apelido':  $9 -> $t2
		bge	$t1,58,keepKeys			# aqui lemos um caracter nao numerico entao acertamos na assun��o acima
		la	$a1,regKeysNum			# aqui lemos um caracter nao numerico entao erramos na assun��o
keepKeys:	la	$a0,regValues			# agr temos que achar o valor desse registrador
		li	$a2,1				# numero de values por key
		jal	getValueAddr			# pega o endereco relativo a chave passada
		beq	$v0, $zero,printErrorMsg	# registrador inexistente
		lb	$v0,($v0)
		lw	$ra,0($sp)
		addi	$sp,$sp,4	
		jr	$ra	
		
assemblerR:	# desempilho a pilha e monto o codigo de instrucao tipo R em $v0: opcode(6bits) & rs(5bits) & rt(5bits) & rd(5bits) & shamt(5bits) & funct(6bits)
		move	$t0,$zero
		lb	$a0,0($sp)
		add	$t0,$t0,$a0
		sll	$t0,$t0,5
		lb	$a0,4($sp)
		add	$t0,$t0,$a0
		sll	$t0,$t0,5
		lb	$a0,8($sp)
		add	$t0,$t0,$a0
		sll	$t0,$t0,5
		lb	$a0,12($sp)
		add	$t0,$t0,$a0
		sll	$t0,$t0,5
		lb	$a0,16($sp)
		add	$t0,$t0,$a0
		sll	$t0,$t0,6
		lb	$a0,20($sp)
		add	$t0,$t0,$a0
		add 	$sp,$sp,24
		move	$v0,$t0
		jr 	$ra	
		
	
	
	
.data
	filePath: 	.asciiz 	"D:/example_saida.asm"
	fileWords: 	.space  	1024
	errorMsg:	.asciiz 	"Comando nao reconhecido"
	regKeysNum:	.asciiz		"0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,"
	regKeysNaN:	.asciiz		"zero,at,v0,v1,a0,a1,a2,a3,t0,t1,t2,t3,t4,t5,t6,t7,s0,s1,s2,s3,s4,s5,s6,s7,t8,t9,k0,k1,gp,sp,fp,ra,"
	regValues:	.byte		0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
	keysA:		.asciiz		"add,addu,and,movn,nor,or,slt,sltu,sub,subu,xor,"
	valuesA:	.byte		0x20,0x21,0x24,0xb,0x27,0x25,0x2a,0x2b,0x22,0x23,0x26	
