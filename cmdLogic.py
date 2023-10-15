# esse sao os cmds para compilar:
opcodes = ["add","addi","addiu","addu","and","andi","beq","bgez","bgezal","bne","clo","div","j","jal","jr","lb","lui","lw","mfhi","mflo","movn","mul","mult","nor","or","ori","sb","sll","slt","slti","sltu","sra","srav","srl","sub","subu","sw","xor","xori"]
# tendo eles, separo em casos comuns para padronizar e otimizar o codigo


# 6 particoes:
       # com 3 registradores (ordem: rd,rs,st)
              #          6bits    5bits  5bits  5bits  5bits   6bits
opcodesR = [
# params ordem:     rd,rs,rt
# cmds com:                                                   funct
              "add",   # 000000    rs     rt     rd    00000   0x20
              "addu",  # 000000    rs     rt     rd    00000   0x21
              "and",   # 000000    rs     rt     rd    00000   0x24
              "mfhi",  # 000000   00000  00000   rd    00000   0x10
              "mflo",  # 000000   00000  00000   rd    00000   0x12
              "movn",  # 000000    rs     rt     rd    00000   0xb
              "nor",   # 000000    rs     rt     rd    00000   0x27
              "or",    # 000000    rs     rt     rd    00000   0x25
              "slt",   # 000000    rs     rt     rd    00000   0x2a
              "sltu",  # 000000    rs     rt     rd    00000   0x2b
              "sub",   # 000000    rs     rt     rd    00000   0x22
              "subu",  # 000000    rs     rt     rd    00000   0x23
              "xor",   # 000000    rs     rt     rd    00000   0x26

# params ordem:     rd,rs,rt
# cmds com:            opcode                                 funct
              "clo",   # 0x1c      rs    00000   rd    00000   0x21
              "mul",   # 0x1c      rs     rt     rd    00000   0x2

# params ordem:     rs,rt
# parametros nao comecam com rd:                              funct
              "div",   # 000000    rs     rt    00000  00000   0x1a          
              "jr",    # 000000    rs    00000  00000  00000   0x8
              "mult",  # 000000    rs     rt    00000  00000   0x18

# params ordem:     rd,rt,rs/sa ??????????????????
# cmds com:                                            shamt  fucnt
              "sll",   # 000000    rs     rt     rd     sa      0
              "sra",   # 000000   00000   rt     rd     sa     0x3
              "srav",  # 000000    rs     rt     rd    00000   0x7
              "srl",   # 000000    rs     rt     rd     sa     0x2
]

# 4 particoes:
       # com 2 registradores
              #          6bits    5bits  5bits             16bits
opcodesI = [
              "addi",  #   
              "addiu", # 
              "andi",  # 
              "beq",   # 
              "bgez",  # 
              "bgezal",# 
              "bne",   # 
              "lb",    # 
              "lui",   # 
              "lw",    # 
              "ori",   # 
              "sb",    # 
              "slti",  # 
              "sw",    # 
              "xori"   # 
]

# 2 particoes:
       # com 1 target
              #          6bits             26bits
opcodeJ = [
              "j",     #  0x2              target
              "jal"    #  0x3              target  
]
'''
		addi	$s7,$s7,-1			#
		jal 	readNotNullByte			# releio o ultimo byte lido, que pode ser ' ' ou ',' ou '\n'
		addi	$s7,$s7,1			# retorno o ponteiro pro valor atual
		beq	$v1,10,noReg			# se era '\n' nao ha mais registrador e ja pulamos a linha
		jal 	readNotNullByte
       '''