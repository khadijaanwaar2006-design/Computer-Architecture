.text
main:
li x5,0
addi x10,x0,0x100 #x
addi x11,x0,0x200 #y

addi x12,x0,72 #H for test
sb x12,0(x11)
addi x12,x0,69 #E for test
sb x12,1(x11)
addi x12,x0,76 #L for test
sb x12,2(x11)
addi x12,x0,76 #L for test
sb x12,3(x11)
addi x12,x0,79 #o for test
sb x12,4(x11)
addi x12,x0,0x00 #NuLL for test
sb x12,5(x11)

jal x1,strcpy
addi x17,x0,10
ecall

strcpy:
addi sp,sp,-4
sw x19,0(sp)
addi x19,x0,0 #i=0



while:
add x5,x11,x19
lbu x6,0(x5) #x6=y[i]
add x7,x10,x19 #x[i]=y[i]
sb x6,0(x7)
beq x6,x0,exit
addi x19,x19,1
jal x0,while

exit:
lw x19,0(sp)
addi sp,sp,4
jalr x0,0(x1)

end:
j end
