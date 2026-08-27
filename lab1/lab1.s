
main:
    li x2, 5
    
    

    addi x3, x0, 0
    addi x2, x3, 32
    add x4, x2, x3
    addi x6, x4, -5
    sub x5, x2, x6
    sub x7 , x3, x2
    add x8, x5, x7
    add x9, x8, x6
    add x9, x2, x3
    add x9, x6, x9
end:
    j end