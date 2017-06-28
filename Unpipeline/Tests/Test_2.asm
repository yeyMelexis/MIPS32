######## Test 2 ########
# Instructions : addi, addiu, add, addu, sub, subu

addi $s1, $0, 65535	#result 0x0000ffff
addi $s2, $0, 65280	#result 0x0000ff00
and  $s3, $s1, $s2		#result 0x0000ff00
or   $s4, $s1, $s2		#result 0x0000ffff
nor  $s5, $s1, $s2		#result 0xffff0000
xor  $s6, $s1, $s2		#result 0x000000ff
lui  $s7, 0x8765		#result 0x87650000
ori  $s7, $s7, 0x4321	#result 0x87654321
xori $t8, $s6, 0xf000	#result 0x0000f0ff
andi $t9, $s1, 0x0ff0	#result 0x00000ff0
