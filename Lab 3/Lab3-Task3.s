.text

main:
    addi x7,x0,0x100 #initializing stack 

    addi x2,x0,2
    sw x2,-4(x7)    #Placing values in these stack addresses 

    addi x2,x0,3
    sw x2,-8(x7)

    addi x7,x7,-8

    addi x10,x7,0   #v[]
    addi x11,x0,0   #k
    jal x1, func
    
    addi x1,x1,8
    j exit

    func:
        slli x14,x11,2  #v[k]
        add x14,x10,x14 #x14=v[k]
        lw x15,0(x14)   #stores v[k] in x15
        lw x16,4(x14)   #stores v[k+1] in x16
        sw x16,0(x14)   #swapping of v[k] and v[k+1]
        sw x15,4(x14)   #swapping of v[k] and v[k+1]
        jalr x0,0(x1)   #returns to main 

    exit:
    

end:
    j end 

   