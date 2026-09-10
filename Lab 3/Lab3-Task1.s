.text

main:
    addi x10,x0,12   #a
    addi x11,x0,12      #b
    jal x1,sum
    addi x11,x10,0  #b=a
    li x10,1
    ecall
    j exit
    sum:
        add x10,x11,x10     #a=a+b
        jalr x0,0(x1)   #go back to main
    exit:
end:
    j end


