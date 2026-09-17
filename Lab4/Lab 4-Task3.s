.text
main:
    addi x10,x0,0x100   # x10=Base address of a
    addi x11,x0,4       # x11=len

    addi x5,x0,10       # a[0]=10
    sw x5,0(x10)

    addi x5,x0,4        # a[1]=4
    sw x5,4(x10)

    addi x5,x0,3        #a[2]=3
    sw x5,8(x10)

    addi x5,x0,6        #a[3]=6
    sw x5,12(x10)

    beq x10,x0,exit
    beq x11,x0,exit
    addi x12,x0,0      # x12=i

outerloop:
    bge x12,x11,exit    
    add x13,x12,x0

innerloop:
    bge x13,x11,iter
    slli x5,x12,2
    add x5,x10,x5   # x5= Address of a[i]
    lw x6, 0(x5)    # x6=a[i]
    slli x7,x13,2
    add x7,x10,x7   # x7= Address of a[j]
    lw x8, 0(x7)    # x8=a[j]

    bge x6,x8,skip
    sw x8, 0(x5)    # a[i]=a[j]
    sw x6, 0(x7)    # a[j]= a[i]

skip:
    addi x13,x13,1  # j+=1
    j innerloop
iter:
    addi x12,x12,1  # i+=1
    j outerloop
exit:
    j exit