######## Test 5 ########
# Instructions : addi, jr, nop, add, nor, j, xor

main:
addiu $1, $0, 10
nop		#result = 1		#result = 0x00008000
addiu $3, $0, 24		#result = 5
jr   $3
nop
add  $3, $0, $0
nor  $4, $1, $1
j blink
nop
and  $4, $4, $1
blink:    xor  $4, $4, $1