.text
main:
    li x7,0 #i 
    li x5,2 #a
    li x6,2 #b
    li x10,0x200 #D's address 
    loop1:
        bge x7,x5,loop1end
        li x29,0 #j
       
    loop2:
        bge x29,x6,loop2end
        slli x8,x29,4
        add x8,x10,x8
        add x11,x7,x29
        sw x11,0(x8)
        addi x29,x29,1
        j loop2
    loop2end:
        addi x7,x7,1
        j loop1
    loop1end:
    
    
    end:
    j end
