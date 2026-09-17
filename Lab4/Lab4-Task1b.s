.text
main:
# addi x10,x0,4  #x10=n
# addi x11,x0,1  #x11=acc=1
# loop:
# ble x10,x0,exit
# mul x6,x11,x10
# addi x11,x6,0
# addi x10,x10,-1
# j loop

# exit:
# end:
# j end 
################the above code is without stack###########################
    addi x10,x0,2  #x10=n
    addi x11,x0,1  #x11=acc=1
    addi x2,x0,0x100

    addi x2,x2,-8   #stack ponter
    sw x10,0(x2)    #saving memory to hold values in the stack
    sw x11,4(x2)

    jal x1,func
    lw x11,4(x2)
    addi x2,x2,8
    j exit
func:
    lw x18,0(x2)    
    lw x19,4(x2)
    mul x5,x19,x18  #acc=acc*n
    sw x5,4(x2)
    addi x18,x18,-1 #n=n-1
    sw x18,0(x2)
    jalr x0,0(x1)
exit:
end:
    j end

#####################this code is using stack##############################