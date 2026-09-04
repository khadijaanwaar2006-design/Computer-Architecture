.text
main:
    addi x24,x0,0x200
    addi x21,x0,10
    addi x22,x0,0

    loop1:
        bge x22,x21,loop1end
        slli x7,x22,2
        add x7,x24,x7
        sw x22,0(x7)
        addi x22,x22,1
        j loop1
    loop1end:
        addi x22,x0,0
        addi x23,x0,0
        addi x24,x0,0x200
    
    loop2:
        bge x22,x21,loop2end
        slli x7,x22,2
        add x7,x24,x7
        lw x8,0(x7)
        add x23,x23,x8
        addi x22,x22,1
        j loop2
    loop2end:
end:
    j end