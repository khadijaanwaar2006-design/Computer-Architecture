`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2026 10:30:12 AM
// Design Name: 
// Module Name: instructionMemory
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module instructionMemory #(
    parameter OPERAND_LENGTH = 31
)(
    input [OPERAND_LENGTH:0] instAddress,
    output reg [31:0] instruction
);

    reg [7:0] memory [0:255];
    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 4) begin
            memory[i] = 8'h13;
            memory[i+1] = 8'h00;
            memory[i+2] = 8'h00;
            memory[i+3] = 8'h00;
        end

        //FSM program
        memory[0] = 8'h37; memory[1] = 8'h11; memory[2] = 8'h00; memory[3] = 8'h00;  // 0x000: 00001137  lui   sp,0x1
        memory[4] = 8'h37; memory[5] = 8'h24; memory[6] = 8'h00; memory[7] = 8'h00;  // 0x004: 00002437  lui   s0,0x2
        memory[8] = 8'h13; memory[9] = 8'h04; memory[10] = 8'h84; memory[11] = 8'h00;  // 0x008: 00840413  addi  s0, s0,0x8
        memory[12] = 8'hb7; memory[13] = 8'h24; memory[14] = 8'h00; memory[15] = 8'h00;  // 0x00c: 000024b7  lui   s1, 0x2
        memory[16] = 8'h93; memory[17] = 8'h84; memory[18] = 8'h44; memory[19] = 8'h00;  // 0x010: 00448493  addi  s1, s1, 0x4
        memory[20] = 8'h93; memory[21] = 8'h02; memory[22] = 8'h30; memory[23] = 8'h00;  // 0x014: 00300293  addi  t0, x0, 3
        memory[24] = 8'h23; memory[25] = 8'h20; memory[26] = 8'h54; memory[27] = 8'h00;  // 0x018: 00542023  sw    t0, 0(s0)
        memory[28] = 8'h23; memory[29] = 8'ha0; memory[30] = 8'h04; memory[31] = 8'h00;  // 0x01c: 0004a023  sw    x0, 0(s1)
        memory[32] = 8'h83; memory[33] = 8'h22; memory[34] = 8'h04; memory[35] = 8'h00;  // 0x020: 00042283  lw    t0, 0(s0)
        memory[36] = 8'he3; memory[37] = 8'h8c; memory[38] = 8'h02; memory[39] = 8'hfe;  // 0x024: fe028ce3  beq   t0, x0, S_WAIT
        memory[40] = 8'h13; memory[41] = 8'h85; memory[42] = 8'h02; memory[43] = 8'h00;  // 0x028: 00028513  addi  a0, t0, 0
        memory[44] = 8'hef; memory[45] = 8'h00; memory[46] = 8'h80; memory[47] = 8'h00;  // 0x02c: 008000ef  jal   ra, COUNTDOWN
        memory[48] = 8'h6f; memory[49] = 8'hf0; memory[50] = 8'hdf; memory[51] = 8'hfe;  // 0x030: fedff06f  jal   x0, S_WAIT
        memory[52] = 8'h13; memory[53] = 8'h01; memory[54] = 8'h01; memory[55] = 8'hff;  // 0x034: ff010113  addi  sp, sp, -16
        memory[56] = 8'h23; memory[57] = 8'h26; memory[58] = 8'h11; memory[59] = 8'h00;  // 0x038: 00112623  sw    ra, 12(sp)
        memory[60] = 8'h23; memory[61] = 8'h24; memory[62] = 8'h81; memory[63] = 8'h00;  // 0x03c: 00812423  sw    s0, 8(sp)
        memory[64] = 8'h23; memory[65] = 8'h20; memory[66] = 8'h31; memory[67] = 8'h01;  // 0x040: 01312023  sw    s3, 0(sp)
        memory[68] = 8'h37; memory[69] = 8'h24; memory[70] = 8'h00; memory[71] = 8'h00;  // 0x044: 00002437  lui   s0, 0x2
        memory[72] = 8'h13; memory[73] = 8'h04; memory[74] = 8'h44; memory[75] = 8'h00;  // 0x048: 00440413  addi  s0, s0, 0x4
        memory[76] = 8'h93; memory[77] = 8'h09; memory[78] = 8'h05; memory[79] = 8'h00;  // 0x04c: 00050993  addi  s3, a0, 0
        memory[80] = 8'h23; memory[81] = 8'h20; memory[82] = 8'h34; memory[83] = 8'h01;  // 0x050: 01342023  sw    s3, 0(s0)
        memory[84] = 8'h63; memory[85] = 8'h8c; memory[86] = 8'h09; memory[87] = 8'h00;  // 0x054: 00098c63  beq   s3, x0, CD_DONE
        memory[88] = 8'hef; memory[89] = 8'h00; memory[90] = 8'h40; memory[91] = 8'h03;  // 0x058: 034000ef  jal   ra, DELAY
        memory[92] = 8'h63; memory[93] = 8'h1c; memory[94] = 8'h05; memory[95] = 8'h00;  // 0x05c: 00051c63  bne   a0, x0, CD_RESET
        memory[96] = 8'h93; memory[97] = 8'h89; memory[98] = 8'hf9; memory[99] = 8'hff;  // 0x060: fff98993  addi  s3, s3, -1
        memory[100] = 8'h23; memory[101] = 8'h20; memory[102] = 8'h34; memory[103] = 8'h01;  // 0x064: 01342023  sw    s3, 0(s0)
        memory[104] = 8'h6f; memory[105] = 8'hf0; memory[106] = 8'hdf; memory[107] = 8'hfe;  // 0x068: fedff06f  jal   x0, S_COUNT
        memory[108] = 8'h13; memory[109] = 8'h05; memory[110] = 8'h00; memory[111] = 8'h00;  // 0x06c: 00000513  addi  a0, x0, 0
        memory[112] = 8'h6f; memory[113] = 8'h00; memory[114] = 8'h80; memory[115] = 8'h00;  // 0x070: 0080006f  jal   x0, CD_EXIT
        memory[116] = 8'h13; memory[117] = 8'h05; memory[118] = 8'h10; memory[119] = 8'h00;  // 0x074: 00100513  addi  a0, x0, 1
        memory[120] = 8'h83; memory[121] = 8'h29; memory[122] = 8'h01; memory[123] = 8'h00;  // 0x078: 00012983  lw    s3, 0(sp)
        memory[124] = 8'h03; memory[125] = 8'h24; memory[126] = 8'h81; memory[127] = 8'h00;  // 0x07c: 00812403  lw    s0, 8(sp)
        memory[128] = 8'h83; memory[129] = 8'h20; memory[130] = 8'hc1; memory[131] = 8'h00;  // 0x080: 00c12083  lw    ra, 12(sp)
        memory[132] = 8'h13; memory[133] = 8'h01; memory[134] = 8'h01; memory[135] = 8'h01;  // 0x084: 01010113  addi  sp, sp, 16
        memory[136] = 8'h67; memory[137] = 8'h80; memory[138] = 8'h00; memory[139] = 8'h00;  // 0x088: 00008067  jalr  x0, 0(ra)
        memory[140] = 8'h93; memory[141] = 8'h02; memory[142] = 8'h30; memory[143] = 8'h00;  // 0x08c: 00300293  addi t0,x0,3
        memory[144] = 8'hb7; memory[145] = 8'h23; memory[146] = 8'h00; memory[147] = 8'h00;  // 0x090: 000023b7  lui   t2, 0x2
        memory[148] = 8'h93; memory[149] = 8'h83; memory[150] = 8'hc3; memory[151] = 8'h00;  // 0x094: 00c38393  addi  t2, t2, 0xC
        memory[152] = 8'h03; memory[153] = 8'ha3; memory[154] = 8'h03; memory[155] = 8'h00;  // 0x098: 0003a303  lw    t1, 0(t2)
        memory[156] = 8'h63; memory[157] = 8'h1a; memory[158] = 8'h03; memory[159] = 8'h00;  // 0x09c: 00031a63  bne   t1, x0, DL_RESET
        memory[160] = 8'h93; memory[161] = 8'h82; memory[162] = 8'hf2; memory[163] = 8'hff;  // 0x0a0: fff28293  addi  t0, t0, -1
        memory[164] = 8'he3; memory[165] = 8'h9a; memory[166] = 8'h02; memory[167] = 8'hfe;  // 0x0a4: fe029ae3  bne   t0, x0, DL_LOOP
        memory[168] = 8'h13; memory[169] = 8'h05; memory[170] = 8'h00; memory[171] = 8'h00;  // 0x0a8: 00000513  addi  a0, x0, 0
        memory[172] = 8'h67; memory[173] = 8'h80; memory[174] = 8'h00; memory[175] = 8'h00;  // 0x0ac: 00008067  jalr  x0, 0(ra)
        memory[176] = 8'h13; memory[177] = 8'h05; memory[178] = 8'h10; memory[179] = 8'h00;  // 0x0b0: 00100513  addi  a0, x0, 1
        memory[180] = 8'h67; memory[181] = 8'h80; memory[182] = 8'h00; memory[183] = 8'h00;  // 0x0b4: 00008067  jalr  x0, 0(ra)
    end

    // Combinational read: 4 consecutive bytes, little-endian, word-aligned by the PC
    always @(*) begin
        instruction = {memory[{instAddress[7:2], 2'b11}],
                       memory[{instAddress[7:2], 2'b10}],
                       memory[{instAddress[7:2], 2'b01}],
                       memory[{instAddress[7:2], 2'b00}]};
    end

endmodule