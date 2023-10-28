.data
vect1: .word  0x1234
vect2: .word 0x5678
vect3: .word 0x9abc
vect4: .word 0xdef0
vect5: .word 0x1357
vect6: .word 0x2468

.text
Label4:add $t0, $s0, $s1
addi $t1, $s2, 10
addiu $t2, $s3, 5
addu $t3, $s4, $s5
and $t4, $s6, $s7
Label2:andi $t5, $s4, 255
beq $s0, $s1, Label1
bgez $s2, Label2
bgezal $s3, Label3
bne $s4, $s5, Label4
clo $t6, $s6
div $s7, $s4
j Label5 
Label1: nor $t4, $s4, $s0
jal Label6
jr $ra
Label5: lb $t7, 100($s0)
lui $t8, 0xffff
#lw $t9, vect5($s1)
mfhi $t0
Label6: slt $t9, $s5, $s6
mflo $t1
Label3:movn $t2, $s2, $s3
mul $t3, $s4, $s5
mult $s6, $s7

sll $t8, $s4, 2
slti $t0, $s7, 10
sltu $t1, $s4, $s0



#sb $t7, 555($s3)
sra $t2, $s0, 3
srav $t3, $s1, $s2
srl $t4, $s3, 2
sub $t5, $s4, $s5
subu $t6, $s6, $s7
 or $t5, $s0, $s1
#sw $t7, vect1($s4)
xor $t8, $s0, $s0
xori $t9, $s1, 255
ori $t6, $s2, 255



		jal	readFile
		la	$s7,fileWords 			# ponteiro para o texto
		jal 	consumeBlankLines
		jal 	readByte
		bne	$v1,'.',errorNoSection
		jal	readByte
		bne	$v1,'d',maybeText
		jal	readByte
		bne	$v1,'a',errorNoSection
		jal	readByte
		bne	$v1,'t',errorNoSection
		jal	readByte
		bne	$v1,'a',errorNoSection
		li	$s6,0			# 'nosso pc' contador da memoria de dados
		la 	$a0,openDataFile   		# endereço da string que contém o nome do arquivo
		jal	writeHeader
		jal	readNotNullByte
		beq	$v1,10,dataSection		# checo se depos de ler text nao ha nenhum char significativo
		beq	$v1,0,end
		j	errorNoSection
		
		jal 	consumeBlankLines
findText:	jal 	readByte
		bne	$v1,'.',errorNoSection
		jal 	readByte
maybeText:	bne	$v1,'t',errorNoSection
		jal	readByte
		bne	$v1,'e',errorNoSection
		jal	readByte
		bne	$v1,'x',errorNoSection
		jal	readByte
		bne	$v1,'t',errorNoSection
		la 	$a0,openTextFile    # endereço da string que contém o nome do arquivo
		jal	writeHeader
		li	$s6,0x400000			# 'nosso pc' contador da memoria de instrucoes
		jal	readNotNullByte
		beq	$v1,10,textSection		# checo se depos de ler text nao ha nenhum char significativo
		beq	$v1,0,end
		j	errorNoSection	
		
dataSection:	# programa principal para tratamento da area .data
		jal	consumeBlankLines
		lb	$t0,($s7)
		beq	$t0,'.',findText
		beq	$t0,0,end		# nao tem area .text
		
		jal 	checkIfIsLabel
		beq	$v0,$zero,errorWrongParam
		la	$a0,dataLabelKeys
		jal	storeLabel
		la	$t0,dataLabelValues
		add	$t0,$t0,$v0
		sw	$s6,($t0)
		jal	readNotNullByte
		beq	$v1,10,dataSection
		bne	$v1,'.',errorWStorageType
		jal 	readByte
		bne	$v1,'w',errorWStorageType
		jal	readByte
		bne	$v1,'o',errorWStorageType
		jal	readByte
		bne	$v1,'r',errorWStorageType
		jal	readByte
		bne	$v1,'d',errorWStorageType
dataLine:	jal	readNotNullByte
		beq	$v1,10,dataSection
		addi	$s7,$s7,-1
		jal	writePC
		li	$a3,','
		jal	getNumberValue
		move	$a0,$v0
		jal	writeInstr
		addi	$s6,$s6,4			# 4 pq trato de words
		lb	$t0,-1($s7)			# checar o último Byte lido
		beq	$t0,10,dataSection
		j	dataLine
		
		
textSection:	# programa principal para tratamento da area .text
		move	$s5,$s7				# salvo o ponteiro para o inicio do .text
		jal 	storeAllTextLabels
		move	$s7,$s5				# restoro o pornteito para reler o .text de novo focado nas instrucoes	
		li	$s6,0x400000			# restauro o contador de instr
textLine:	                   
		jal	consumeBlankLines
		
		lb	$t0,($s7)
		beq	$t0,0,end
# pra cima, temos a condicao de parada
		jal 	checkIfIsLabel
		beq	$v0,$zero,typeRA
skipLabel:	lb	$t0,($s7)
		addi 	$s7,$s7,1
		bne	$t0,':',skipLabel
		
		jal 	consumeBlankLines
		 
		lb	$t0,($s7)
		beq	$t0,0,end
# pra cima vemos se temos uma Label na linha antes de tudo e pulamos ela
		
typeRA:		la	$a0,valuesRA
		la	$a1,keysRA
		li	$a2,1			# numero de values por key
		li	$a3,' '
		jal	getValueAddr		# pega o endereco relativo a chave passada
		beq	$v0,$zero,typeRB
		# Achei a instr, agora so empilhar na pilha: funct:5($sp) shamt(4) rd(3) rt(2) rs(1) opcode:0($sp)
		addi	$sp,$sp,-8		# desloco 8 Bytes, mas nunca uso 6 ou 7($sp)
		lb	$t0,($v0)		# pego o funct do cmd lido
		sb	$t0,5($sp)		# empilhar funct
		li	$a3,','
		jal 	getRegCode		# pegar cod do rd
		sb	$v0,3($sp) 		# empilhar rd
		li	$a3,','
		jal 	getRegCode		# pegar cod do rs
		sb	$v0,1($sp)		# empilhar rs
		li	$a3,10
		jal 	getRegCode		# pegar cod do rt
		sb	$v0,2($sp) 		# empilhar rt
		jal	checkManyParams
		sb	$zero,4($sp) 		# empilhar shamt
		sb	$zero,0($sp)		# empilhar opcode
		
		jal	writePC
		jal	assemblerR
		move	$a0,$v0
		jal	writeInstr

		addi	$s6,$s6,4
		j 	textLine


typeRB:		la	$a0,valuesRB
		la	$a1,keysRB
		li	$a2,1			# numero de values por key
		li	$a3,' '
		jal	getValueAddr		# pega o endereco relativo a chave passada
		beq	$v0,$zero,typeRC
		# Achei a instr, agora so empilhar na pilha: funct:5($sp) shamt(4) rd(3) rt(2) rs(1) opcode:0($sp)
		addi	$sp,$sp,-8
		lb	$t0,($v0)
		sb	$t0,5($sp)		# empilhar funct
		li	$a3,','
		jal 	getRegCode
		sb	$v0,1($sp)		# empilhar rs
		li	$a3,10
		jal 	getRegCode
		sb	$v0,2($sp)		# empilhar rt
		jal	checkManyParams
		sb	$zero,4($sp) 		# empilhar shamt
		sb	$zero,3($sp) 		# empilhar rd
		sb	$zero,0($sp)		# empilhar opcode
		
		jal	writePC
		jal	assemblerR
		move	$a0,$v0
		jal	writeInstr

		addi	$s6,$s6,4
		j 	textLine
		
		
typeRC:		la	$a0,valuesRC
		la	$a1,keysRC
		li	$a2,1			# numero de values por key
		li	$a3,' '
		jal	getValueAddr		# pega o endereco relativo a chave passada
		beq	$v0,$zero,typeRD
		# Achei a instr, agora so empilhar na pilha: funct:5($sp) shamt(4) rd(3) rt(2) rs(1) opcode:0($sp)
		addi	$sp,$sp,-8
		lb	$t0,($v0)
		sb	$t0,5($sp)		# empilhar funct
		li	$a3,10
		jal 	getRegCode
		sb	$v0,1($sp)		# empilhar rs
		jal	checkManyParams
		sb	$zero,4($sp) 		# empilhar shamt
		sb	$zero,3($sp) 		# empilhar rd
		sb	$zero,2($sp) 		# empilhar rt
		sb	$zero,0($sp)		# empilhar opcode
		
		jal	writePC
		jal	assemblerR
		move	$a0,$v0
		jal	writeInstr

		addi	$s6,$s6,4
		j 	textLine
		
		
typeRD:		la	$a0,valuesRD
		la	$a1,keysRD
		li	$a2,2			# numero de values por key
		li	$a3,' '
		jal	getValueAddr		# pega o endereco relativo a chave passada
		beq	$v0,$zero,typeRE
		# Achei a instr, agora so empilhar na pilha: funct:5($sp) shamt(4) rd(3) rt(2) rs(1) opcode:0($sp)
		addi	$sp,$sp,-8		# desloco 8 Bytes, mas nunca uso 6 ou 7($sp)
		lb	$t0,($v0)		# pego o opcode do cmd lido
		sb	$t0,0($sp)		# empilhar opcode
		lb	$t0,1($v0)		# pego o funct do cmd lido
		sb	$t0,5($sp)		# empilhar funct
		li	$a3,','
		jal 	getRegCode		# pegar cod do rd
		sb	$v0,3($sp) 		# empilhar rd
		li	$a3,','
		jal 	getRegCode		# pegar cod do rs
		sb	$v0,1($sp)		# empilhar rs
		li	$a3,10
		jal 	getRegCode		# pegar cod do rt
		sb	$v0,2($sp) 		# empilhar rt
		jal	checkManyParams
		sb	$zero,4($sp) 		# empilhar shamt
		
		jal	writePC
		jal	assemblerR
		move	$a0,$v0
		jal	writeInstr

		addi	$s6,$s6,4
		j 	textLine


typeRE:		la	$a0,valuesRE
		la	$a1,keysRE
		li	$a2,2			# numero de values por key
		li	$a3,' '
		jal	getValueAddr		# pega o endereco relativo a chave passada
		beq	$v0,$zero,typeRF
		# Achei a instr, agora so empilhar na pilha: funct:5($sp) shamt(4) rd(3) rt(2) rs(1) opcode:0($sp)
		addi	$sp,$sp,-8		# desloco 8 Bytes, mas nunca uso 6 ou 7($sp)
		lb	$t0,($v0)		# pego o opcode do cmd lido
		sb	$t0,0($sp)		# empilhar opcode
		lb	$t0,1($v0)		# pego o funct do cmd lido
		sb	$t0,5($sp)		# empilhar funct
		li	$a3,','
		jal 	getRegCode
		sb	$v0,3($sp)		# empilhar rd
		li	$a3,10
		jal 	getRegCode
		sb	$v0,1($sp)		# empilhar rs
		jal	checkManyParams
		sb	$zero,4($sp) 		# empilhar shamt
		sb	$zero,2($sp) 		# empilhar rt
		
		jal	writePC
		jal	assemblerR
		move	$a0,$v0
		jal	writeInstr

		addi	$s6,$s6,4
		j 	textLine


typeRF:		la	$a0,valuesRF
		la	$a1,keysRF
		li	$a2,1			# numero de values por key
		li	$a3,' '
		jal	getValueAddr		# pega o endereco relativo a chave passada
		beq	$v0,$zero,typeRG
		# Achei a instr, agora so empilhar na pilha: funct:5($sp) shamt(4) rd(3) rt(2) rs(1) opcode:0($sp)
		addi	$sp,$sp,-8		# desloco 8 Bytes, mas nunca uso 6 ou 7($sp)
		lb	$t0,0($v0)
		sb	$t0,5($sp)		# empilhar funct
		li	$a3,','
		jal 	getRegCode
		sb	$v0,3($sp)		# empilhar rd
		li	$a3,','
		jal 	getRegCode
		sb	$v0,2($sp)		# empilhar rt
		li	$a3,' '
		jal	getNumberValue
		bgeu	$v0,0x20,errorOutOfRange# deve caber em 5 bits
		sb	$v0,4($sp)		# empilhar shamt
		jal	checkManyParams
		sb	$zero,1($sp) 		# empilhar rs
		sb	$zero,0($sp) 		# empilhar opcode
		
		jal	writePC
		jal	assemblerR
		move	$a0,$v0
		jal	writeInstr

		addi	$s6,$s6,4
		j 	textLine



typeRG:		la	$a0,valuesRG
		la	$a1,keysRG
		li	$a2,1			# numero de values por key
		li	$a3,' '
		jal	getValueAddr		# pega o endereco relativo a chave passada
		beq	$v0,$zero,typeRH
		# Achei a instr, agora so empilhar na pilha: funct:5($sp) shamt(4) rd(3) rt(2) rs(1) opcode:0($sp)
		addi	$sp,$sp,-8		# desloco 8 Bytes, mas nunca uso 6 ou 7($sp)
		lb	$t0,($v0)		# pego o funct do cmd lido
		sb	$t0,5($sp)		# empilhar funct
		li	$a3,','
		jal 	getRegCode		# pegar cod do rd
		sb	$v0,3($sp) 		# empilhar rd
		li	$a3,','
		jal 	getRegCode		# pegar cod do rt
		sb	$v0,2($sp)		# empilhar rt
		li	$a3,10
		jal 	getRegCode		# pegar cod do rs
		sb	$v0,1($sp) 		# empilhar rs
		jal	checkManyParams
		sb	$zero,4($sp) 		# empilhar shamt
		sb	$zero,0($sp)		# empilhar opcode
		
		jal	writePC
		jal	assemblerR
		move	$a0,$v0
		jal	writeInstr

		addi	$s6,$s6,4
		j 	textLine


typeRH:		la	$a0,valuesRH
		la	$a1,keysRH
		li	$a2,1			# numero de values por key
		li	$a3,' '
		jal	getValueAddr		# pega o endereco relativo a chave passada
		beq	$v0,$zero,typeIA
		# Achei a instr, agora so empilhar na pilha: funct:5($sp) shamt(4) rd(3) rt(2) rs(1) opcode:0($sp)
		addi	$sp,$sp,-8
		lb	$t0,($v0)
		sb	$t0,5($sp)		# empilhar funct
		li	$a3,10
		jal 	getRegCode
		sb	$v0,3($sp)		# empilhar rd
		jal	checkManyParams
		sb	$zero,4($sp) 		# empilhar shamt
		sb	$zero,2($sp) 		# empilhar rt
		sb	$zero,1($sp) 		# empilhar rs
		sb	$zero,0($sp)		# empilhar opcode
		
		jal	writePC
		jal	assemblerR
		move	$a0,$v0
		jal	writeInstr

		addi	$s6,$s6,4
		j 	textLine

typeIA:		la	$a0,valuesIA
		la	$a1,keysIA
		li	$a2,1			# numero de values por key
		li	$a3,' '
		jal	getValueAddr		# pega o endereco relativo a chave passada
		beq	$v0,$zero,typeIB
		# Achei a instr, agora so empilhar na pilha: imm:4-7($sp) rt(2) rs(1) opcode:0($sp)
		addi	$sp,$sp,-8		# desloco 8 Bytes e nunca uso 3($sp)
		lb	$t0,($v0)
		sb	$t0,0($sp)		# empilhar opcode
		li	$a3,','
		jal 	getRegCode
		sb	$v0,2($sp)		# empilhar rt
		li	$a3,','
		jal 	getRegCode
		sb	$v0,1($sp) 		# empilhar rs
		li	$a3,' '
		jal	getNumberValue
		bgeu	$v0,0x10000,errorOutOfRange# deve caber em 16 bits
		sw	$v0,4($sp)		# empilhar imm
		jal	checkManyParams
		
		jal	writePC
		jal	assemblerI
		move	$a0,$v0
		jal	writeInstr

		addi	$s6,$s6,4
		j 	textLine
		

typeIB:		la	$a0,valuesIB
		la	$a1,keysIB
		li	$a2,1			# numero de values por key
		li	$a3,' '
		jal	getValueAddr		# pega o endereco relativo a chave passada
		beq	$v0,$zero,typeIC
		# Achei a instr, agora so empilhar na pilha: addr:4-7($sp) rt(2) rs(1) opcode:0($sp)
		addi	$sp,$sp,-8		# desloco 8 Bytes e nunca uso 3($sp)
		lb	$t0,($v0)
		sb	$t0,0($sp)		# empilhar opcode
		li	$a3,','
		jal 	getRegCode
		sb	$v0,1($sp)		# empilhar rs
		li	$a3,','
		jal 	getRegCode
		sb	$v0,2($sp) 		# empilhar rt
		
		li	$a3,10
		jal 	getTextLabelCode
		subu	$t0,$v0,$s6
		addi	$t0,$t0,-4
		srl	$t0,$t0,2		#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! nao sei pq tem q dividir por 4, mas funciona
		sw	$t0,4($sp)		# empilhar addr
		jal	checkManyParams
		
		jal	writePC
		jal	assemblerI
		move	$a0,$v0
		jal	writeInstr

		addi	$s6,$s6,4
		j 	textLine
		
		
typeIC:		la	$a0,valuesIC
		la	$a1,keysIC
		li	$a2,1			# numero de values por key
		li	$a3,' '
		jal	getValueAddr		# pega o endereco relativo a chave passada
		beq	$v0,$zero,typeID
		# Achei a instr, agora so empilhar na pilha: addr:4-7($sp) rt(2) rs(1) opcode:0($sp)
		addi	$sp,$sp,-8		# desloco 8 Bytes e nunca uso 3($sp)
		lb	$t0,($v0)
		sb	$t0,0($sp)		# empilhar opcode
		li	$a3,','
		jal 	getRegCode
		sb	$v0,2($sp)		# empilhar rt
		li	$a3,'('
		jal 	getDataLabelCode
		#srl	$t0,$t0,2		#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! nao sei pq tem q dividir por 4, mas funciona
		sw	$v0,4($sp)		# empilhar addr
		li	$a3,')'
		jal 	getRegCode
		sb	$v0,1($sp) 		# empilhar rs
		addi	$s7,$s7,1		# quero pular a verificacao do ')'
		jal	checkManyParams
		
		jal	writePC
		jal	assemblerI
		move	$a0,$v0
		jal	writeInstr

		addi	$s6,$s6,4
		j 	textLine
		
		
typeID:		la	$a0,valuesID
		la	$a1,keysID
		li	$a2,1			# numero de values por key
		li	$a3,' '
		jal	getValueAddr		# pega o endereco relativo a chave passada
		beq	$v0,$zero,typeIE
		# Achei a instr, agora so empilhar na pilha: imm:4-7($sp) rt(2) rs(1) opcode:0($sp)
		addi	$sp,$sp,-8		# desloco 8 Bytes e nunca uso 3($sp)
		lb	$t0,($v0)
		sb	$t0,0($sp)		# empilhar opcode
		li	$a3,','
		jal 	getRegCode
		sb	$v0,2($sp)		# empilhar rt
		li	$a3,'('
		jal	getNumberValue
		bgeu	$v0,0x10000,errorOutOfRange# deve caber em 16 bits
		sw	$v0,4($sp)		# empilhar imm
		li	$a3,')'
		jal 	getRegCode
		sb	$v0,1($sp) 		# empilhar rs
		addi	$s7,$s7,1		# quero pular a verificacao do ')'
		jal	checkManyParams
		
		jal	writePC
		jal	assemblerI
		move	$a0,$v0
		jal	writeInstr

		addi	$s6,$s6,4
		j 	textLine

typeIE:		la	$a0,valuesIE
		la	$a1,keysIE
		li	$a2,1			# numero de values por key
		li	$a3,' '
		jal	getValueAddr		# pega o endereco relativo a chave passada
		beq	$v0,$zero,typeIF
		# Achei a instr, agora so empilhar na pilha: imm:4-7($sp) rt(2) rs(1) opcode:0($sp)
		addi	$sp,$sp,-8		# desloco 8 Bytes e nunca uso 3($sp)
		lb	$t0,($v0)
		sb	$t0,0($sp)		# empilhar opcode
		li	$a3,','
		jal 	getRegCode
		sb	$v0,2($sp)		# empilhar rt
		li	$a3,' '
		jal	getNumberValue
		bgeu	$v0,0x10000,errorOutOfRange# deve caber em 16 bits
		sw	$v0,4($sp)		# empilhar imm
		jal	checkManyParams
		sb	$zero,1($sp)
		jal	writePC
		jal	assemblerI
		move	$a0,$v0
		jal	writeInstr

		addi	$s6,$s6,4
		j 	textLine

typeIF:		la	$a0,valuesIF
		la	$a1,keysIF
		li	$a2,2			# numero de values por key
		li	$a3,' '
		jal	getValueAddr		# pega o endereco relativo a chave passada
		beq	$v0,$zero,typeJA
		# Achei a instr, agora so empilhar na pilha: addr:4-7($sp) rt(2) rs(1) opcode:0($sp)
		addi	$sp,$sp,-8		# desloco 8 Bytes e nunca uso 3($sp)
		lb	$t0,($v0)
		sb	$t0,0($sp)		# empilhar opcode
		lb	$t0,1($v0)
		sb	$t0,2($sp)		# empilhar rt
		li	$a3,','
		jal 	getRegCode
		sb	$v0,1($sp)		# empilhar rs
		
		li	$a3,10
		jal 	getTextLabelCode
		subu	$t0,$v0,$s6
		addi	$t0,$t0,-4
		srl	$t0,$t0,2		#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! nao sei pq tem q dividir por 4, mas funciona
		sw	$t0,4($sp)		# empilhar addr
		
		jal	checkManyParams
		
		jal	writePC
		jal	assemblerI
		move	$a0,$v0
		jal	writeInstr

		addi	$s6,$s6,4
		j 	textLine


typeJA:		la	$a0,valuesJA
		la	$a1,keysJA
		li	$a2,1			# numero de values por key
		li	$a3,' '
		jal	getValueAddr		# pega o endereco relativo a chave passada
		beq	$v0,$zero,noInstr
		# Achei a instr, agora so empilhar na pilha: addr:4($sp) & opcode:0($sp) 
		lb	$t0,($v0)
		sb	$t0,0($sp)
		
		li	$a3,10
		jal 	getTextLabelCode
		srl	$t0,$v0,2		#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! nao sei pq tem q dividir por 4, mas funciona
		sw	$t0,4($sp)
			
		jal	checkManyParams
		
		jal	writePC
		jal 	assemblerJ
		move	$a0,$v0
		jal	writeInstr

		addi	$s6,$s6,4
		j 	textLine

noInstr:	jal	errorNoSuchOperator

		
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


writeHeader:	# escrever no openFilePath
		# abrir o arquivo para escrita (modo de escrita)
		# recebe em $a0, o PATH para criar arquivo
    		li 	$v0,13           	# código da chamada do sistema para abrir o arquivo
    		li	$a1, 1            	# modo de escrita (1)
    		li 	$a2, 0
    		syscall
    		move 	$s0, $v0        	# armazenar o descritor de arquivo retornado
    		
    		# escrever no arquivo .mif
    		li	$v0, 15            	# código da chamada do sistema para escrever no arquivo
    		move 	$a0, $s0
    		la 	$a1, header
    		li 	$a2, 80         	# comprimento da string
    		syscall
    		jr 	$ra 
    		
writePC:    	# escrever o valor do PC:
		# converter o conteudo do registrador para hexa
		addi 	$sp, $sp, -4
    		sw 	$ra, 0($sp)
    		move 	$a0, $s6    # PC
    		la 	$a1, buffer 	 # buffer para o valor
    		li 	$a2, 9        # tamanho do buffer
    		jal 	binToHex
    		
    		li 	$v0, 15            	# código da chamada do sistema para escrever no arquivo
    		move 	$a0, $s0
    		la 	$a1, buffer
    		li 	$a2, 8         	# comprimento da string
    		syscall 
    		
    		# escrever o separador " : "
    		li 	$v0, 15            	# código da chamada do sistema para escrever no arquivo
    		move 	$a0, $s0
    		la 	$a1, separador
    		li 	$a2, 3         	# comprimento da string
    		syscall
    		
    		lw 	$ra, 0($sp)
    		addi 	$sp, $sp, 4
    		jr 	$ra
    		
writeInstr:   	# escrever o valor da instrucao
		# recebe em $a0 a instrucao pra repassar pra intToHex
		move 	$a0,$a0
    		la 	$a1, buffer 	 # buffer para o valor
    		li 	$a2, 9        # tamanho do buffer
    		addi 	$sp, $sp, -4
    		sw 	$ra, 0($sp)
    		jal 	binToHex
    		
    		li 	$v0, 15            	# código da chamada do sistema para escrever no arquivo
    		move 	$a0, $s0
    		la 	$a1, buffer
    		li 	$a2, 8         	# comprimento da string
    		syscall 
    		
    		# escrever o ";" no fim da linha
    		li 	$v0, 15            	# código da chamada do sistema para escrever no arquivo
    		move 	$a0, $s0
    		la 	$a1, fimLinha
    		li 	$a2, 2         	# comprimento da string
    		syscall
    		
    		lw	$ra, 0($sp)
    		addi 	$sp, $sp, 4
    		jr 	$ra
    		
closeFile:  	# fechar o arquivo .MIF
    		li 	$v0, 16            # código do sistema para fechar um arquivo
    		li 	$a0, 0             # identificador do arquivo ????????????????????????????????????????????????????
    		syscall
    		jr 	$ra


readByte:	# ler um Byte (Char) e armazena em $v1, incrementando o ponteiro
		lbu	$v1,($s7)
		addi	$s7,$s7,1
		jr	$ra

readNotNullByte:# ler proxs Bytes (Char) ate achar um (!= ' ') e armazena em $v1, incrementando o ponteiro
		lbu	$v1,($s7)
		addi	$s7,$s7,1
		beq	$v1,' ',readNotNullByte
		#beq	$v1,9,readNotNullByte
		jr	$ra
		
printChar:	# mostrar na tela o conteudo de $a0 como char
		li	$v0,11
		syscall	
		jr	$ra

printInt:	# mostrar na tela o conteudo de $a0 como int
		li	$v0,1
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

binToHex:
    		li 	$t3, 8       		# $t3 = numero de caracteres (8)
    		li  	$t4, 16      		# $t4 = base hexadecimal
    		addi	$a1, $a1, 8   		# aponta pro final do buffer
    		sb  	$zero, 0($a1)
convertLoop:	remu	$t2, $a0, $t4 	# $t2 = $a0 % 16
    		lb  	$t2,hexaSymbols($t2)
    		sb   	$t2, -1($a1)  		# Store the ASCII character
    		srl  	$a0,$a0,4  		# $a0 = $a0 / 16
    		subi 	$a1, $a1, 1   		# Move the buffer pointer left
    		subi 	$t3, $t3, 1   		# Decrement character count
    		bnez 	$t3, convertLoop
    		jr   	$ra             # Return

consumeBlankLines: # consome todos os ' ' e '\n' seguidos
		lbu	$t1,($s7)
		addi	$s7,$s7,1
		beq	$t1,' ',consumeBlankLines	# ignorar spaces
		#beq	$t1,9,consumeBlankLines		# ignorar tabs
		beq	$t1,10,consumeBlankLines	# ignorar quebras de linha em linhas vazias
		addi	$s7,$s7,-1			# volta em 1 o ponteiro do arq para lermos o char != '\n' depois
		jr	$ra

consumeSpaces: # consome todos os ' '
		lbu	$t1,($s7)
		addi	$s7,$s7,1
		beq	$t1,' ',consumeSpaces
		#beq	$t1,9,consumeSpaces
		addi	$s7,$s7,-1 			# volta em 1 o ponteiro do arq para lermos o char != ' '
		jr	$ra

checkManyParams: # indica erro se tiver mais parametros numa linha
		addi	$s7,$s7,-1			# pra tambe½m checar o indicador do final da palavra
		addi	$sp,$sp,-4
		sw	$ra,0($sp)	
		jal	readNotNullByte
		lw	$ra,0($sp)
		addi	$sp,$sp,4
		bne	$v1,10,checkEndFile
		jr	$ra
checkEndFile:	bne	$v1,0,errorManyParams
		addi	$s7,$s7,-1			# pra reler o 0 na condicao de parada do loop
		jr 	$ra
	
		      
getValueAddr:	# recebe $a0(array dos valores), $a1(array das chaves), $a2(num de valor por chave) e $a3(indicador do final da palavra)
		# le a palavra atual e retorna, se achar, o ponteiro para o(s) valor(es) em $v0(+) ou 0 se nao achar
		move	$t7,$s7				# salvo o endereco que estou lendo para comparar do inicio para os proximos instrucoes da string
		move	$t0,$a0				# ponteiro para indice do array dos Hexas
		move	$t1,$a1				# ponteiro para indice do char a ser lido da string de instrucoes
checkByte:	lb	$t2,($t1)			# byte lido da string de instrucoes
		lbu	$t3,($s7)			# byte lido do arq
		addi	$s7,$s7,1
		beq	$t3,' ',match			# SE achamos ' ', entao ja lemos palavra toda e temos um match
		#beq	$v1,9,match          		# SE achamos '\t' , entao ja lemos palavra toda e temos um match
		beq	$t3,$a3,match			# OU se achamos nosso indicador -> ',' ou '\n' ou ')'
		beq	$t3,0,match			# OU se achamos o 0 indicando fim de arquivo
		bne	$t2,$t3,nextKey	
		addi	$t1,$t1,1		
		j 	checkByte		
findNextKey:	beq	$t2,0,notFound			# se achar zero, ja leu a string toda sem achar o comando
		addi	$t1,$t1,1
		lb	$t2,($t1)
nextKey:	bne	$t2,',',findNextKey
		addi	$t1,$t1,1
		add	$t0,$t0,$a2			# pulo os valores da chave atual e indexo os da prox chave
		move	$s7,$t7				# reseto o ponteiro do arq para comparar com outro opcode
		j	checkByte
match:		bne	$t2,',',nextKey			# por convencao as chaves terminam em ','. Entao garanto que li a chave toda para evitar palavras contidas: add esta em addi
		move	$v0,$t0
		jr 	$ra
notFound:	move	$v0,$zero
		move	$s7,$t7				# reseto o ponteiro do arq para comparar com outra string de instrucoes
		jr 	$ra
		
	
getRegCode:	# recebe em $a3 o indicador do getValueAddr apenas para repassar para ele
		# le o registrador atual do arquivo e, se achar, retorna o codigo em $v0 ou da erro por falta de parametros(registradores)
		#move	$t3,$a3
		addi	$sp,$sp,-4
		sw	$ra,0($sp)
		jal 	readNotNullByte	
		#beq	$v1,10,errorFewParams		# se ler um '\n', ! poucos parametros !!!!!!!!!!!!!!!!OBS:ACHO QUE PODE RETIRAR COM A ADICAO DO $A3
		bne	$v1,'$',errorWrongParam	# registradores comecam com $
		lbu	$t1,($s7)
		bltu	$t1,48,errorNoSuchOperator	# aqui lemos um caracter que nao existe nos registradores
		la	$a1,regKeysNaN			# assumo que o registrador esta escrito com seu 'apelido':  $9 -> $t2
		bgeu	$t1,58,keepNaNKeys		# aqui lemos um caracter nao numerico entao acertamos na assuncao acima
		la	$a1,regKeysNum			# aqui lemos um caracter nao numerico entao erramos na assunï¿½cao
keepNaNKeys:	la	$a0,numValues			# agr temos que achar o valor desse registrador
		li	$a2,1				# numero de values por key
		#move	$a3,$t3
		jal	getValueAddr			# pega o endereco relativo a chave passada
		beq	$v0, $zero,errorNoSuchOperator	# registrador inexistente
		lb	$v0,($v0)
		lw	$ra,0($sp)
		addi	$sp,$sp,4	
		jr	$ra


getNumberValue:	# receve em $a3 um indicador de fim de numero
		# retorna em $v0 o valor numerico de um numero decimal escrito no arquivo
		addi	$sp,$sp,-4
		sw	$ra,0($sp)
		move	$t9,$zero			# flag de numero negativo, assumo sem sinal
		move	$v0,$zero			# valor de retorno da funcao
		jal	readNotNullByte
		bne	$v1,'-',noFlag
		addiu	$t9,$zero,1			# ativo a flag de numero com sinal
		jal	readByte
noFlag:		bne	$v1,'0',dec
		jal	readByte
		beq	$v1,'x',hexa			# nao começa com 0x, deve ser decimal. Poderia tratar como octal, mas não será feito
		addi 	$s7,$s7,-1
		j	dec
hexa:		move	$t7,$s7				# salvo o endereço do MSB
		la	$t0,hexaSymbols
		li	$t1,16
		j	findLSB
dec:		addi	$t7,$s7,-1			# salvo o endereço do MSB
		la	$t0,decSymbols
		li	$t1,10
findLSB:	jal	readByte
		beq	$v1,' ',LSB
		beq	$v1,10,LSB
		beq	$v1,0,LSB
		beq	$v1,$a3,LSB			# quando ler no .data, passar ',' . PAssar ' ' ou 10 c.c.
		j	findLSB
LSB:		addi	$t8,$s7,-2			# vetor $t8 aponta pro LSB
		move	$t4,$zero			# expoente $t4 da base $t1
nextDigit:	move	$t5,$zero			# index do digito na lista de simbolos. Note que o index = valor do numero
		lb	$t2,($t8)
findSymbol:	lb	$t3,($t0)			# simbolo de index $t5
		beq	$t3,0,errorInvSymbol
		beq	$t2,$t3,foundValue
		addi	$t0,$t0,1
		addi	$t5,$t5,1
		j 	findSymbol
foundValue:	subu	$t0,$t0,$t5			# reseto o $t0 para o priiro elemento da lista
		addi	$sp,$sp,-1
		sb	$t4,0($sp)			# salvar o valor do expoente
exponential:	beq	$t4,$zero,gotDigitValue		# calculei  $t5*$t1^($t4) e armazenei em $t5
		mul	$t5,$t5,$t1
		mfhi	$t6				# checar se passou de 32 bits
		bne	$t6,$zero,errorOutOfRange
		addi	$t4,$t4,-1
		j	exponential
gotDigitValue:	lb	$t4,0($sp)			# recupero o expoente(peso) do ultimo digito 
		addi	$sp,$sp,1
		add	$v0,$v0,$t5
		addi	$t4,$t4,1
		beq	$t8,$t7,retNumber
		addi	$t8,$t8,-1
		j	nextDigit
retNumber:	beq	$t9,$zero,unsigned
		not	$v0,$v0
		addi	$v0,$v0,1
unsigned:	lw	$ra,0($sp)
		addi	$sp,$sp,4
		jr	$ra



getDataLabelCode: # recebe em $a3 o parametros do getLabelCode apenas para repassar para ele
		  # chama getLabelCode com os parametros da secao .text e trata erros
		addi	$sp,$sp,-4
		sw	$ra,0($sp)
		la	$a0,dataLabelValues
		la	$a1,dataLabelKeys
		jal	getLabelAddr
		beq	$v0,$zero,errorDataLabel
		lw	$v0,($v0)
		lw	$ra,0($sp)
		addi	$sp,$sp,4
		jr	$ra	
errorDataLabel:	la	$a0,textLabelValues
		la	$a1,textLabelKeys
		move	$a2,$zero			# nao me importo em pegar o endereco
		jal	getValueAddr
		beq	$v0,$zero,errorNoSuchLabel
		j	errorInvMemory	


getTextLabelCode:# recebe em $a3 o parametros do getLabelCode apenas para repassar para ele
 		 # chama getLabelCode com os parametros da secao .text e trata erros
		addi	$sp,$sp,-4
		sw	$ra,0($sp)
		la	$a0,textLabelValues
		la	$a1,textLabelKeys
		jal	getLabelAddr
		beq	$v0,$zero,errorTextLabel
		lw	$v0,($v0)
		lw	$ra,0($sp)
		addi	$sp,$sp,4
		jr	$ra	
errorTextLabel:	la	$a0,dataLabelValues
		la	$a1,dataLabelKeys
		move	$a2,$zero			# nao me importo em pegar o endereco
		jal	getValueAddr
		beq	$v0,$zero,errorNoSuchLabel
		j	errorInvSkip	
				
						
										
getLabelAddr:	# recebe em $a0,$a1,$a3 o parametros do getValueAddr apenas para repassar para ele
		# retorna em $v0, o endereco do valor da label(PC) da secao escolhida pelos parametros $a0 e $a1 ou 0 caso nao ache.
		addi	$sp,$sp,-4
		sw	$ra,0($sp)
		jal 	consumeSpaces
		lb	$t0,($s7)
		beq	$t0,'$',errorWrongParam
		li	$a2,4				# cada valor esta em Words (4 Bytes) 
		jal	getValueAddr
		lw	$ra,0($sp)
		addi	$sp,$sp,4
		jr 	$ra	
		
assemblerR:	# desempilho a pilha - funct:5($sp) shamt(4) rd(3) rt(2) rs(1) opcode:0($sp) - e monto o codigo de instrucao tipo R em $v0
		lb	$a0,0($sp)
		move	$t0,$a0
		sll	$t0,$t0,5
		lb	$a0,1($sp)
		add	$t0,$t0,$a0
		sll	$t0,$t0,5
		lb	$a0,2($sp)
		add	$t0,$t0,$a0
		sll	$t0,$t0,5
		lb	$a0,3($sp)
		add	$t0,$t0,$a0
		sll	$t0,$t0,5
		lb	$a0,4($sp)
		add	$t0,$t0,$a0
		sll	$t0,$t0,6
		lb	$a0,5($sp)
		add	$t0,$t0,$a0
		add 	$sp,$sp,8
		move	$v0,$t0
		jr 	$ra	
		

assemblerI:	# desempilho a pilha - addr:4-7($sp) rt(2) rs(1) opcode:0($sp) - e monto o codigo de instrucao tipo I em $v0
		lb	$a0,0($sp)
		move	$t0,$a0
		sll	$t0,$t0,5
		lb	$a0,1($sp)
		add	$t0,$t0,$a0
		sll	$t0,$t0,5
		lb	$a0,2($sp)
		add	$t0,$t0,$a0
		sll	$t0,$t0,16
		lw	$a0,4($sp)
		andi 	$a0,$a0,0xffff			# deixar numeros negativos em 16 bits
		add	$t0,$t0,$a0
		add 	$sp,$sp,8
		move	$v0,$t0
		jr 	$ra	


assemblerJ:	# desempilho a pilha  - addr:4-7($sp) opcode:0($sp) - e monto o codigo de instrucao tipo I em $v0
		lb	$a0,0($sp)
		move	$t0,$a0
		sll	$t0,$t0,26
		lw	$a0,4($sp)
		add	$t0,$t0,$a0
		move	$v0,$t0
		jr 	$ra
		
		
storeAllTextLabels:	
		addi	$sp,$sp,-4
		sw	$ra,0($sp)
checkLine:	jal	consumeBlankLines
		jal 	checkIfIsLabel
		beq	$v0,$zero,skipLine
		# ver se a label é repetida antes de armazenar ou invoco erro
		la	$a0,textLabelValues
		la	$a1,textLabelKeys
		move	$a2,$zero			# nao me importo em pegar o endereco
		li	$a3,':'
		jal	getValueAddr
		bne	$v0,$zero,errorSameLabel
		#ver no dataLabel tbm
		la	$a0,dataLabelValues
		la	$a1,dataLabelKeys
		move	$a2,$zero			# nao me importo em pegar o endereco
		li	$a3,':'
		jal	getValueAddr
		bne	$v0,$zero,errorSameLabel
		#
		la	$a0,textLabelKeys
		jal	storeLabel
		la	$t0,textLabelValues
		add	$t0,$t0,$v0
		sw	$s6,($t0)
		jal	consumeBlankLines   	# serve para evitar erro na contagem(pc) de linhas apenas com label
skipLine:	lb	$t0,($s7)
		addi 	$s7,$s7,1
		beq	$t0,0,done		# terminei de armazenar as labels
		bne	$t0,10,skipLine	
		addi	$s6,$s6,4
		j	checkLine
done:		lw	$ra,0($sp)
		addi	$sp,$sp,4
		jr	$ra



storeLabel:	# escreve na memoria uma label separada por virgula
		move	$t0,$a0			# ponteiro para onde escrever as labels
		move	$t1,$zero		# indice de onde estou colocando a label
checkStart:	lb	$t2,($t0)		# checo se uma label ja foi escrita
		beq	$t2,0,storeByte
		addi	$t0,$t0,1
		bne	$t2,',',checkStart
		addi	$t1,$t1,4		# cada virgula lida representa uma label lida
		j	checkStart
storeByte:	lb	$t2,($s7)		# Byte lido do arquivo
		addi 	$s7,$s7,1
		beq	$t2,':',endWord
		sb	$t2,($t0)
		addi 	$t0,$t0,1
		j 	storeByte
endWord:	li	$t2,','			# indicador de fim de key na memoria
		sb	$t2,($t0)	
		move	$v0,$t1
		jr 	$ra
		

checkIfIsLabel:	# ve se uma palavra termina em ': ', retorna em $v0 1 caso Vdd e 0 Falso e retorna em $v1 o ï¿½ltimo byte lido
		move	$v0,$zero 			# assumo que nao termina em ':'
		move 	$t7,$s7
findEnd:	lbu	$t0,($t7)
		addi	$t7,$t7,1
		beq	$t0,0,noColon			# se achei 0, ja li a palavra sem achar ':'
		beq	$t0,10,noColon			# se achei '\n', ja li a palavra sem achar ':'
		beq	$t0,' ',noColon			# se achei ' ', ja li a palavra sem achar ':'
		bne	$t0,':',findEnd			# como ainda nao achei ':' ou ' ', volto a procurar
		li	$v0,1
noColon:	jr	$ra


errorNoSection:
		la	$a0,msgNoSection
		j 	printErrorMsg
				
errorFewParams:
		la	$a0,msgFewParams
		j 	printErrorMsg

errorManyParams:
		la	$a0,msgManyParams
		j 	printErrorMsg

errorWrongParam:
		la	$a0,msgWrongParam
		j 	printErrorMsg

errorNoSuchOperator:
		la	$a0,msgNoOperator
		j 	printErrorMsg

errorNoSuchLabel:
		la	$a0,msgNoLabel
		j 	printErrorMsg
		
errorSameLabel:
		la	$a0,msgSameLabel
		j 	printErrorMsg

errorInvMemory:
		la	$a0,msgInvMemory
		j 	printErrorMsg
		
errorInvSkip:	
		la	$a0,msgInvSkip
		j 	printErrorMsg	

errorWrongBase:	
		la	$a0,msgWrongBase
		j 	printErrorMsg

errorOutOfRange:	
		la	$a0,msgOutOfRange
		j 	printErrorMsg
		
errorInvSymbol:	
		la	$a0,msgInvSymbol
		j 	printErrorMsg
		
errorWStorageType:	
		la	$a0,msgWrongStorageType
		j 	printErrorMsg


printErrorMsg:	
		li	$v0,55
		li	$a1,0
		syscall
		j	end

.data
	fileWords: 		.space  	1024
	dataLabelKeys:		.space		256  # aqui escrevo as labels dos dodos lidas
	dataLabelValues:	.space		128  # pc do inicio da lista de .word
	textLabelKeys:		.space		256  # aqui escrevo as labels do text lidas
	textLabelValues:	.space		128  # pc de cada label
	filePath: 		.asciiz 	"D:/example_saida.asm"
	openTextFile:		.asciiz		"D:/arquivo_text.mif"
	openDataFile:		.asciiz		"D:/arquivo_data.mif"
	header:			.asciiz		"DEPTH = 4096;\nWIDTH = 32;\nADDRESS_RADIX = HEX;\nDATA_RADIX = HEX;\nCONTENT\nBEGIN\n\n"  # cabeçalho do arquivo .MIF
	separador: 		.asciiz 	" : "
	fimLinha:		.asciiz		";\n"
	rodape:			.asciiz 	";\nEND;\n"
	buffer:			.space		9
	hexaSymbols:		.asciiz		"0123456789abcdef"
	decSymbols:		.asciiz		"0123456789"
	regKeysNum:		.asciiz		"0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,"
	regKeysNaN:		.asciiz		"zero,at,v0,v1,a0,a1,a2,a3,t0,t1,t2,t3,t4,t5,t6,t7,s0,s1,s2,s3,s4,s5,s6,s7,t8,t9,k0,k1,gp,sp,fp,ra,"
	numValues:		.byte		0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
	keysRA:			.asciiz		"add,addu,and,movn,nor,or,slt,sltu,sub,subu,xor,"
	valuesRA:		.byte		0x20,0x21,0x24,0xb,0x27,0x25,0x2a,0x2b,0x22,0x23,0x26	# funct
	keysRB:			.asciiz		"div,mult,"
	valuesRB:		.byte		0x1a,0x18   	# funct
	keysRC:			.asciiz		"jr,"
	valuesRC:		.byte		0x8
	keysRD:			.asciiz		"mul,"
	valuesRD:		.byte		0x1c,0x2 	# (opcode,funct)
	keysRE:			.asciiz		"clo,"
	valuesRE:		.byte		0x1c,0x21	# (opcode,funct)
	keysRF:			.asciiz		"sll,sra,srl,"
	valuesRF:		.byte		0x0,0x3,0x2	# funct
	keysRG:			.asciiz		"srav,"
	valuesRG:		.byte		0x7		# funct
	keysRH:			.asciiz		"mfhi,mflo,"
	valuesRH:		.byte		0x1a,0x18	# funct
	keysIA:			.asciiz		"addi,addiu,andi,ori,slti,xori,"
	valuesIA:		.byte		0x8,0x9,0xc,0xd,0xa,0xe		# opcode
	keysIB:			.asciiz		"beq,bne,"
	valuesIB:		.byte		0x4,0x5		# opcode
	keysIC:			.asciiz		"lw,sw,"
	valuesIC:		.byte		0x23,0x2b	# opcode
	keysID:			.asciiz		"lb,sb,"
	valuesID:		.byte		0x20,0x28	# opcode
	keysIE:			.asciiz		"lui,"
	valuesIE:		.byte		0xf		# opcode
	keysIF:			.asciiz		"bgez,bgezal,"
	valuesIF:		.byte		0x1,0x1,0x1,0x11	# (opcode,rt)
	keysJA:			.asciiz		"j,jal,"
	valuesJA:		.byte		0x2,0x3		# opcode
	
	msgNoSection:		.asciiz 	"Unknown section."
	msgFewParams:		.asciiz 	"Too few or incorrectly formatted operands."
	msgManyParams:		.asciiz 	"Too many operands."
	msgWrongParam:	 	.asciiz		"Operand is of incorrect type."
	msgNoOperator:		.asciiz		"Not a recognized operator."
	msgNoLabel:		.asciiz		"Label not found in file."
	msgSameLabel:		.asciiz		"Label already defined in file."
	msgInvMemory:		.asciiz		"Cannot load or write directly to text segment."
	msgInvSkip:		.asciiz		"Cannot skip to data segment."
	msgWrongBase:		.asciiz		"Not a valid base."
	msgOutOfRange:		.asciiz		"Operand is out of range."
	msgInvSymbol:		.asciiz		"Not a valid symbol for known bases (hexa or decimal)."
	msgWrongStorageType:	.asciiz		"Not a valid storage format. Use .word"
