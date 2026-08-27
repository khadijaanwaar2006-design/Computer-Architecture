Main:
    li x2,0x100
    li x3,0x200
    li x4,0x300

    lb x5,0(x2)
    lh x6,0(x3)
    add x7,x5,x6
    sw x7,0(x4)

    lb x5,1(x2)
    lh x6,2(x3)
    add x7,x5,x6
    sw x7,4(x4)

    lb x5,2(x2)
    lh x6,4(x3)
    add x7,x5,x6
    sw x7,8(x4)

    lb x5,3(x2)
    lh x6,6(x3)
    add x7,x5,x6
    sw x7,12(x4)

end:
    j end