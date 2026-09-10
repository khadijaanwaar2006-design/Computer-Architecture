.text

main:
    addi x10,x0,10 #g
    addi x11,x0,11  #h
    addi x12,x0,5   #i
    addi x13,x0,2   #j
    addi x20, x0,0  #f
    
    addi x7,x0,0x100 #initializing stack
   
    add x2, x0,x10 #storing g
    sw x2,-4(x7)

    add x2, x0,x11  #storing h
    sw x2,-8(x7)

    add x2, x0,x12  #storing i
    sw x2,-12(x7)

    add x2, x0,x13  #storing j
    sw x2,-16(x7)

    addi x7,x7,-16
    jal x1,func
    addi x7,x7,16
    j exit

    func:
        lw x18,0(x7)
        lw x19,4(x7)
        add x5,x18,x19 #x5=g+h

        lw x18,8(x7)
        lw x19,12(x7)
        add x6,x18,x19  #x6=i+j

        sub x20,x6,x5   #f=x5-x6
        jalr x0,0(x1)   #back to main
            

    exit:
end:
    j end 