######## Test 1 ########
# Instructions : addi, addiu, add, addu, sub, subu

addiu $1, $0, 10	#result 10
addiu $2, $0, 20	#result 20
addu  $3, $1, $2	#result 10 + 20 = 30
subu  $4, $2, $1	#result 20 - 10 = 10
addi  $5, $0, -40	#result -40
add   $6, $2, $5	#result 20 - 40 = -20
sub   $7, $2, $5	#result 20 -(-40) = 60  
