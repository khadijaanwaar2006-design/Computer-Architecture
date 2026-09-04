.text
main:
    addi x20,x0,1
    addi x22,x0,2
    addi x23,x0,3

    li x1,1
    beq x20,x1,case1

    li x2,2
    beq x20,x2,case2

    li x3,3
    beq x20,x3,case3

    li x4,4
    beq x20,x4,case4

    beq x0,x0,default

    case1:
        add x21,x22,x23
        beq x0,x0,exit

    case2:
        sub x21,x22,x23
        beq x0,x0,exit

    case3:
        slli x21,x22,1
        beq x0,x0,exit
    case4:
        srai x21,x22,1
        beq x0,x0,exit
    default:
        li x21,0
    exit:

end:
    j end