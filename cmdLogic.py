# esse sao os cmds para compilar:
opcodes = ["add","addi","addiu","addu","and","andi","beq","bgez","bgezal","bne","clo","div","j","jal","jr","lb","lui","lw","mfhi","mflo","movn","mul","mult","nor","or","ori","sb","sll","slt","slti","sltu","sra","srav","srl","sub","subu","sw","xor","xori"]
# tendo eles, separo em casos comuns para padronizar e otimizar o codigo


# 6 particoes:
       # com ate 3 registradores
              #          6bits    5bits  5bits  5bits  5bits   6bits
opcodesR = [
    
       {"typeRA": [#registradores:  rd,rs,rt
       # cmds com:                                            funct
              "add",   # 000000    rs     rt     rd    00000   0x20
              "addu",  # 000000    rs     rt     rd    00000   0x21
              "and",   # 000000    rs     rt     rd    00000   0x24
              "movn",  # 000000    rs     rt     rd    00000   0xb
              "nor",   # 000000    rs     rt     rd    00000   0x27
              "or",    # 000000    rs     rt     rd    00000   0x25
              "slt",   # 000000    rs     rt     rd    00000   0x2a
              "sltu",  # 000000    rs     rt     rd    00000   0x2b
              "sub",   # 000000    rs     rt     rd    00000   0x22
              "subu",  # 000000    rs     rt     rd    00000   0x23
              "xor",   # 000000    rs     rt     rd    00000   0x26
       ]},

       {"typeRB": [#registradores: rs,rt
       # cmds com:                                            funct
              "div",   # 000000    rs     rt    00000  00000   0x1a          
              "mult",  # 000000    rs     rt    00000  00000   0x18
       ]},

       {"typeRC": [#registradores: rs
       # cmds com:                                            funct
              "jr",    # 000000    rs    00000  00000  00000   0x8
       ]},

       {"typeRD": [#registradores:  rd,rs,rt
       # cmds com:       opcode                               funct
              "mul",   # 0x1c      rs     rt     rd    00000   0x2
       ]},

       {"typeRE": [#registradores: rd,rs
       # cmds com:      opcode                                funct
              "clo",   # 0x1c      rs    00000   rd    00000   0x21
       ]},

       {"typeRF": [#registradores: rd,rt,sa
       # cmds com:                                            funct
              "sll",   # 000000   00000   rt     rd     sa      0
              "sra",   # 000000   00000   rt     rd     sa     0x3
              "srl",   # 000000   00000   rt     rd     sa     0x2
       ]},

       {"typeRG": [#registradores: rd,rt,rs
       # cmds com:                                            funct
              "srav",  # 000000    rs     rt     rd    00000   0x7
       ]},

       {"typeRH": [#registradores: rd
       # cmds com:                                            funct
              "mfhi",  # 000000   00000  00000   rd    00000   0x10
              "mflo",  # 000000   00000  00000   rd    00000   0x12
       ]},
]



# 4 particoes:
       # com 2 registradores
              #           6bits      5bits     5bits          16bits
opcodesI = [
    
       {"typeIA": [#parametros: rt,rs,imm
              "addi",  #   0x8        rs        rt              imm  
              "addiu", #   0x9        rs        rt              imm   
              "andi",  #   0xc        rs        rt              imm   
              "ori",   #   0xd        rs        rt              imm   
              "slti",  #   0xa        rs        rt              imm   
              "xori"   #   0xe        rs        rt              imm   
       ]},

       {"typeIB": [#parametros: rs,rt,offset 
              "beq",   #   0x4        rs        rt             offset   
              "bne",   #   0x5        rs        rt             offset   
       ]},

       {"typeIC": [#parametros: rt, offset(rs)
              "lw",    #  0x23        rs        rt             offset   
              "sw",    #  0x2b        rs        rt             offset   
       ]},

       {"typeID": [#parametros: rt, imm(rs)
              "lb",    #  0x20        rs        rt              imm   
              "sb",    #  0x28        rs        rt              imm
       ]},

       {"typeIE": [#parametros: rt, imm
              "lui",   #   0xf       00000      rt              imm   
       ]},

       {"typeIF": [#parametros: rs, offset
              "bgez",  #   0x1        rs        0x1             offset   
              "bgezal",#   0x1        rs       0x21             offset       
       ]},

]

# 2 particoes:
       # com 1 target
              #          6bits             26bits
opcodeJ = [
    
       {"typeJA": [#parametros: target
              "j",     #  0x2              target       
              "jal"    #  0x3              target  
       ]},

]