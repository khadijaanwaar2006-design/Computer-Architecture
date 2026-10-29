main:
        lui   sp,0x1                #sp = 0x1000, where the stack starts
        lui   s0,0x2                #s0 = 0x2000 , (first half of the switch address)
        addi  s0, s0,0x8           #the switch address
        lui   s1, 0x2               #s1 = 0x2000, for the LEDS
        addi  s1, s1, 0x4           #LED Address

        addi  t0, x0, 3             # fake switch value = 3
        sw    t0, 0(s0)             # store it at the "switch" address
S_WAIT:
        sw    x0, 0(s1)             #writes 0 to led address so all leds are initially switched off
        lw    t0, 0(s0)            #reads switches into t0 (t0=sw_in , upper part of switch address)
        beq   t0, x0, S_WAIT        #if sw_in=0 jump to s_wait and loop
        addi  a0, t0, 0             #if sw_in!=0 copy into a0 
        jal   ra, COUNTDOWN         #
        jal   x0, S_WAIT            

COUNTDOWN:
        addi  sp, sp, -16      #moves stack pointer 16 ytes down to make room      
        sw    ra, 12(sp)           #saves return addressa because calling Delay overwrites ra
        sw    s0, 8(sp)             #s0 will be reused for the led adress, so it must be saved 
        sw    s3, 0(sp)             #saved func needs to be reused as the counter

        lui   s0, 0x2
        addi  s0, s0, 0x4           #LED address (this is where s0 is reused again)
        addi  s3, a0, 0             
        sw    s3, 0(s0)             #shows starting count on LEDS

S_COUNT:
        beq   s3, x0, CD_DONE       #i count=0, countdown finished, go to CD_DONE
        jal   ra, DELAY             
        bne   a0, x0, CD_RESET      #if a0!=0 reset was pressed 
        addi  s3, s3, -1            
        sw    s3, 0(s0)            #shows new count of leds 
        jal   x0, S_COUNT           #back to top and repeat

CD_DONE:
        addi  a0, x0, 0             #sets return val to 0, countdown is finished 
        jal   x0, CD_EXIT
CD_RESET:
        addi  a0, x0, 1             #return val=0, reset has stopped countdown
CD_EXIT:
        lw    s3, 0(sp)             #all next lws are restoring values 
        lw    s0, 8(sp)
        lw    ra, 12(sp)
        addi  sp, sp, 16            #restoring stack pointer, moving it back up
        jalr  x0, 0(ra)             

DELAY:
        # lui   t0, 0x262             
        # addi  t0, t0, 0x5A0        #t0= 0x262 + 0x5A0 , creates the loop count(1sec at 10MHz)
        addi t0,x0,3
        lui   t2, 0x2
        addi  t2, t2, 0xC           #t2=0x2+0xC,the reset btn address 

DL_LOOP:
       lw    t1, 0(t2)            #reads reset btn into t1
        bne   t1, x0, DL_RESET      
        addi  t0, t0, -1            #subs 1 from loop counter
        bne   t0, x0, DL_LOOP
        addi  a0, x0, 0             #loop finised, no reset, return 0
        jalr  x0, 0(ra)

DL_RESET:
        addi  a0, x0, 1         #reset happended, return 1
        jalr  x0, 0(ra)         #back to coundown