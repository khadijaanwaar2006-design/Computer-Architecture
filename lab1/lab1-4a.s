main:
    li x10, 0x78786464
    li x11, 0xA8A81919
    sw x2, 0x100(x0)
    sw x3, 0x1F0(x0)
    lhu x12, 0x100(x0)
    lh x13, 0x1F0(x0)
    lh x14, 0x1F0(x0)




end:
    j end