######## Test 3 ########
# Instructions : addi, sll, sllv, srl, srlv, sra, srav

main:
addi $s1, $0, 1		#result = 1
addi $s2, $0, 0x8000	#result = 0x00008000
addi $s3, $0, 5		#result = 5
addi $s4, $0, 0xffff	#result = 0x0000ffff
sll  $s5, $s1, 3		#result = 0x00000008
sllv $s6, $s1, $s3		#result = 0x00000020
srl  $s7, $s2, 3		#result = 0x10000000
srlv $t8, $s2, $s3		#result = ?
sra  $t9, $s4, 2		#result = 0x000000ff
srav $t0,$s4, $s3		#result = 0x00000000



