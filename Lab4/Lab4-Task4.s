.text

main:
addi x10,x0,0x100   # a[]

addi x5,x0,3
sw x5,0(x10)   # a[3]

addi x5,x0,5    # a[5]
sw x5,4(x10)

addi x5,x0,8    # a[8]
sw x5,8(x10)

addi x5,x0,13   # a[13]
sw x5,12(x10)

addi x11,x0,8   # x11 is target=8
addi x12,x0,0   # x11=low=0
addi x13,x0,4
addi x13,x13,-1 # x13=high=3

jal x1, binarysearch
exit:
j exit

binarysearch:
addi x2,x2,-16  #stack 
sw x1,12(x2)
sw x8,8(x2) #x8=low index
sw x9,4(x2) #x9=high index

add x8,x12,x0   #putting low=0 (low=val)
add x9,x13,x0   #putting high=0 (high=val)

loop:
blt x8,x9,notfound
sub x5,x9,x8    #mid=high-low
srai x5,x5,1    #mid=high-low/2
add x5,x8,x5    # mid=low+(high-low/2)

slli x6,x5,2    #offset (4)
add x6,x10,x6   #array=B.A*4
lw x6,0(x6)     #x6=array[mid]
beq x6,x11,found
blt x6,x11,right

left:
addi x9,x5,-1   #high=mid-1
j loop
right:
addi x8,x5,1    #low=mid+1
j loop
found:
add x10,x5,x0   #x10=mid
j again
notfound:
addi x10,x0,-1  #next address

again:
lw x9,4(x2) #storing x9
lw x8,8(x2) #storing x8
lw x1,12(x2)
addi x2,x2,16   #reset stack 
jalr x0,0(x1)

end:
    j end