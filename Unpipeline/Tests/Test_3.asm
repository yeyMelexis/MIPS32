######## Test 3 ########
# Instructions : addi, sltu, slt, beq, bne, xor, nop

main:
addi $1, $0, 50		#result = 50
addi $2, $0, 60		#result = 60
addi $3, $0, -30	#result = -30
sltu $4, $1, $2		#result = 1
addi $5, $0, 1
beq  $5, $4, blink	#result: It will be jump to "blink"
nop
xor  $6, $1, $2		 # It will not perform
blink: 	slt $7, $2, $3	 #result = 0
	bne $7, $0, main # It will not jump to "main"
	nop


