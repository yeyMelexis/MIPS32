######## Test 6 ########
# Instructions : addi, jr, nop, add, nor, j, xor

main:
addiu $1, $0, 70
addiu $2, $0, 100
sw    $1, 4($0)
sw    $2, 20($0)
lw    $3, 4($0)
lw    $4, 20($0)

