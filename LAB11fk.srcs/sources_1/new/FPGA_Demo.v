`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2026 11:24:58 AM
// Design Name: 
// Module Name: FPGA_Demo
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



// =====================================================================
// FPGA_Demo.v : Basys 3 board demo for the single-cycle RISC-V processor
//
// Uses the existing modules from your project: ProgramCounter, pcAdder,
// branchAdder, mux2, immGen, ControlUnit, ALUControl, ALU, DataMemory.
// New modules in THIS file: DemoInstrMem (4 selectable test programs),
// RegFileDbg (register file with reset + a debug read port),
// Debouncer, SevenSeg and FPGA_Top.
//
// Set FPGA_Top as the design top ONLY for the board build.
// Use TopLevelProcessor as the top for the schematic / utilization / timing reports.
//
// SWITCHES                              BUTTONS
//   sw[4:0]   register to inspect (x0-x31, binary)   btnC = step one instruction
//   sw[7:5]   what the LEDs/display show             btnU = reset (hold ~1 s)
//   sw[13:12] test program 0-3
//   sw[14]    auto speed: 0 = ~1.5 Hz, 1 = ~12 Hz
//   sw[15]    0 = manual step (btnC), 1 = auto run
//
// VIEW (sw[7:5])  LEDs + 4-digit display show:
//   000 ALU result    001 PC    010 instruction [15:0]   011 instruction [31:16]
//   100 register x(sw[4:0])     101 control signals      110 write-back data
//   111 immediate (immGen output)
// Control-signal view (101): LD0 RegWrite, LD1 ALUSrc, LD2 MemWrite, LD3 MemRead,
//   LD4 MemtoReg, LD5 Branch, LD6 zero, LD7 PCSrc, LD9:8 ALUOp
// =====================================================================


// ---------------------------------------------------------------------
// Instruction memory with 4 test programs (16 words each).
// prog_sel picks the program, the PC picks the instruction inside it.
// ---------------------------------------------------------------------
module DemoInstrMem (
    input  wire [31:0] addr,
    input  wire [1:0]  prog_sel,
    output wire [31:0] instr
);
    reg [31:0] mem [0:63];
    integer i;

    initial begin
        for (i = 0; i < 64; i = i + 1)
            mem[i] = 32'h00000013;           // NOP (addi x0,x0,0)

        // ---- Program 0: sum 1..5 loop + sw/lw (words 0..15) ----
        mem[ 0] = 32'h00000093;   // 0x00: addi x1,x0,0
        mem[ 1] = 32'h00500113;   // 0x04: addi x2,x0,5
        mem[ 2] = 32'h00010863;   // 0x08: beq x2,x0,+16
        mem[ 3] = 32'h002080B3;   // 0x0C: add x1,x1,x2
        mem[ 4] = 32'hFFF10113;   // 0x10: addi x2,x2,-1
        mem[ 5] = 32'hFE000AE3;   // 0x14: beq x0,x0,-12
        mem[ 6] = 32'h00102023;   // 0x18: sw x1,0(x0)
        mem[ 7] = 32'h00002203;   // 0x1C: lw x4,0(x0)
        mem[ 8] = 32'h00000063;   // 0x20: beq x0,x0,+0
        // ---- Program 1: R-type ALU operations (words 16..31) ----
        mem[16] = 32'h00C00093;   // 0x00: addi x1,x0,12
        mem[17] = 32'h00A00113;   // 0x04: addi x2,x0,10
        mem[18] = 32'h002081B3;   // 0x08: add x3,x1,x2
        mem[19] = 32'h40208233;   // 0x0C: sub x4,x1,x2
        mem[20] = 32'h0020F2B3;   // 0x10: and x5,x1,x2
        mem[21] = 32'h0020E333;   // 0x14: or x6,x1,x2
        mem[22] = 32'h0020C3B3;   // 0x18: xor x7,x1,x2
        mem[23] = 32'h00112433;   // 0x1C: slt x8,x2,x1
        mem[24] = 32'h0020A4B3;   // 0x20: slt x9,x1,x2
        mem[25] = 32'h00000063;   // 0x24: beq x0,x0,+0
        // ---- Program 2: I-type ALU ops and negative numbers (words 32..47) ----
        mem[32] = 32'hFFB00093;   // 0x00: addi x1,x0,-5
        mem[33] = 32'h01408113;   // 0x04: addi x2,x1,20
        mem[34] = 32'h00617193;   // 0x08: andi x3,x2,6
        mem[35] = 32'h03016213;   // 0x0C: ori x4,x2,48
        mem[36] = 32'h0FF14293;   // 0x10: xori x5,x2,255
        mem[37] = 32'h0000A313;   // 0x14: slti x6,x1,0
        mem[38] = 32'h00A12393;   // 0x18: slti x7,x2,10
        mem[39] = 32'h00000063;   // 0x1C: beq x0,x0,+0
        // ---- Program 3: memory and branches (words 48..63) ----
        mem[48] = 32'h01900093;   // 0x00: addi x1,x0,25
        mem[49] = 32'h00700113;   // 0x04: addi x2,x0,7
        mem[50] = 32'h00102023;   // 0x08: sw x1,0(x0)
        mem[51] = 32'h00202223;   // 0x0C: sw x2,4(x0)
        mem[52] = 32'h00002183;   // 0x10: lw x3,0(x0)
        mem[53] = 32'h00402203;   // 0x14: lw x4,4(x0)
        mem[54] = 32'h004182B3;   // 0x18: add x5,x3,x4
        mem[55] = 32'h00418463;   // 0x1C: beq x3,x4,+8
        mem[56] = 32'h00100313;   // 0x20: addi x6,x0,1
        mem[57] = 32'h00528463;   // 0x24: beq x5,x5,+8
        mem[58] = 32'h06300393;   // 0x28: addi x7,x0,99
        mem[59] = 32'h00200413;   // 0x2C: addi x8,x0,2
        mem[60] = 32'h00000063;   // 0x30: beq x0,x0,+0
    end

    assign instr = mem[{prog_sel, addr[5:2]}];
endmodule


// ---------------------------------------------------------------------
// Register file with synchronous reset (clears x1-x31) and a third,
// debug read port so a switch can choose which register to display.
// ---------------------------------------------------------------------
module RegFileDbg (
    input  wire        clk,
    input  wire        reset,
    input  wire        RegWrite,
    input  wire [4:0]  read_reg1,
    input  wire [4:0]  read_reg2,
    input  wire [4:0]  write_reg,
    input  wire [4:0]  dbg_reg,
    input  wire [31:0] write_data,
    output wire [31:0] read_data1,
    output wire [31:0] read_data2,
    output wire [31:0] dbg_data
);
    reg [31:0] regs [0:31];
    integer i, j;

    initial begin
        for (i = 0; i < 32; i = i + 1)
            regs[i] = 32'b0;
    end

    always @(posedge clk) begin
        if (reset) begin
            for (j = 0; j < 32; j = j + 1)
                regs[j] <= 32'b0;
        end else if (RegWrite && (write_reg != 5'b0))
            regs[write_reg] <= write_data;
    end

    assign read_data1 = (read_reg1 == 5'b0) ? 32'b0 : regs[read_reg1];
    assign read_data2 = (read_reg2 == 5'b0) ? 32'b0 : regs[read_reg2];
    assign dbg_data   = (dbg_reg   == 5'b0) ? 32'b0 : regs[dbg_reg];
endmodule


// ---------------------------------------------------------------------
// Button debouncer: output follows the input only after it has been
// stable for about 10 ms (2^20 cycles of the 100 MHz clock).
// ---------------------------------------------------------------------
module Debouncer (
    input  wire clk,
    input  wire noisy,
    output reg  clean
);
    reg        s0 = 1'b0, s1 = 1'b0;
    reg [19:0] cnt = 20'b0;

    initial clean = 1'b0;

    always @(posedge clk) begin
        s0 <= noisy;
        s1 <= s0;
        if (s1 == clean)
            cnt <= 20'b0;
        else begin
            cnt <= cnt + 1'b1;
            if (cnt == 20'hFFFFF)
                clean <= s1;
        end
    end
endmodule


// ---------------------------------------------------------------------
// 4-digit seven-segment driver (Basys 3: segments and digits active-low)
// ---------------------------------------------------------------------
module SevenSeg (
    input  wire        clk,
    input  wire [15:0] value,
    output reg  [6:0]  seg,     // {g,f,e,d,c,b,a}
    output reg  [3:0]  an
);
    reg [16:0] refresh = 17'b0;
    always @(posedge clk) refresh <= refresh + 1'b1;

    reg [3:0] nib;
    always @(*) begin
        case (refresh[16:15])
            2'd0:    begin an = 4'b1110; nib = value[3:0];   end
            2'd1:    begin an = 4'b1101; nib = value[7:4];   end
            2'd2:    begin an = 4'b1011; nib = value[11:8];  end
            default: begin an = 4'b0111; nib = value[15:12]; end
        endcase
        case (nib)
            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            4'hA: seg = 7'b0001000;
            4'hB: seg = 7'b0000011;
            4'hC: seg = 7'b1000110;
            4'hD: seg = 7'b0100001;
            4'hE: seg = 7'b0000110;
            default: seg = 7'b0001110;
        endcase
    end
endmodule


// ---------------------------------------------------------------------
// Board top level
// ---------------------------------------------------------------------
module FPGA_Top (
    input  wire        clk,        // 100 MHz board clock
    input  wire        btnC,       // single step
    input  wire        btnU,       // reset
    input  wire [15:0] sw,
    output wire [15:0] led,
    output wire [6:0]  seg,
    output wire        dp,
    output wire [3:0]  an
);
    // ---------------- buttons ----------------
    wire step_btn, rst_btn;
    Debouncer db_step (.clk(clk), .noisy(btnC), .clean(step_btn));
    Debouncer db_rst  (.clk(clk), .noisy(btnU), .clean(rst_btn));

    // ---------------- clock for the processor ----------------
    reg [26:0] div = 27'b0;
    always @(posedge clk) div <= div + 1'b1;

    // keep reset asserted ~1.3 ms after the button is released
    reg [16:0] rst_ext = 17'b0;
    always @(posedge clk) begin
        if (rst_btn)              rst_ext <= 17'h1FFFF;
        else if (rst_ext != 17'b0) rst_ext <= rst_ext - 1'b1;
    end
    wire rst_cpu = rst_btn | (rst_ext != 17'b0);

    // cpu_clk: fast clock while resetting, auto clock, or the step button
    reg cpu_clk = 1'b0;
    always @(posedge clk) begin
        if (rst_btn)      cpu_clk <= div[16];                       // ~760 Hz so reset takes effect
        else if (sw[15])  cpu_clk <= sw[14] ? div[22] : div[25];    // ~12 Hz or ~1.5 Hz
        else              cpu_clk <= step_btn;                      // manual: one press = one clock
    end

    // ---------------- processor datapath ----------------
    wire [31:0] pc, pc_next, pc_plus4, branch_target, instr, imm;
    wire [31:0] rd1, rd2, alu_b, alu_result, mem_rd, wb_data, dbg_data;
    wire        Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, zero, PCSrc;
    wire [1:0]  ALUOp;
    wire [3:0]  alu_ctrl;

    assign PCSrc = Branch & zero;

    ProgramCounter pc_reg (.clk(cpu_clk), .reset(rst_cpu), .pc_next(pc_next), .pc(pc));
    pcAdder        pc_add (.pc(pc), .pc_plus4(pc_plus4));
    branchAdder    br_add (.pc(pc), .imm(imm), .branch_target(branch_target));
    mux2           pc_mux (.in0(pc_plus4), .in1(branch_target), .sel(PCSrc), .out(pc_next));

    DemoInstrMem   imem   (.addr(pc), .prog_sel(sw[13:12]), .instr(instr));

    ControlUnit ctrl (
        .opcode(instr[6:0]),
        .Branch(Branch), .MemRead(MemRead), .MemtoReg(MemtoReg),
        .ALUOp(ALUOp), .MemWrite(MemWrite), .ALUSrc(ALUSrc), .RegWrite(RegWrite)
    );
    ALUControl alu_ctrl_unit (
        .ALUOp(ALUOp), .funct3(instr[14:12]), .funct7_5(instr[30]), .alu_ctrl(alu_ctrl)
    );

    RegFileDbg rf (
        .clk(cpu_clk), .reset(rst_cpu), .RegWrite(RegWrite),
        .read_reg1(instr[19:15]), .read_reg2(instr[24:20]),
        .write_reg(instr[11:7]), .dbg_reg(sw[4:0]), .write_data(wb_data),
        .read_data1(rd1), .read_data2(rd2), .dbg_data(dbg_data)
    );
    immGen ig (.instr(instr), .imm(imm));

    mux2 alusrc_mux (.in0(rd2), .in1(imm), .sel(ALUSrc), .out(alu_b));
    ALU  alu (.a(rd1), .b(alu_b), .alu_ctrl(alu_ctrl), .result(alu_result), .zero(zero));

    DataMemory dmem (
        .clk(cpu_clk), .MemRead(MemRead), .MemWrite(MemWrite),
        .address(alu_result), .write_data(rd2), .read_data(mem_rd)
    );
    mux2 memtoreg_mux (.in0(alu_result), .in1(mem_rd), .sel(MemtoReg), .out(wb_data));

    // ---------------- what to show ----------------
    reg [15:0] shown;
    always @(*) begin
        case (sw[7:5])
            3'd0:    shown = alu_result[15:0];
            3'd1:    shown = pc[15:0];
            3'd2:    shown = instr[15:0];
            3'd3:    shown = instr[31:16];
            3'd4:    shown = dbg_data[15:0];
            3'd5:    shown = {6'b0, ALUOp, PCSrc, zero, Branch, MemtoReg, MemRead, MemWrite, ALUSrc, RegWrite};
            3'd6:    shown = wb_data[15:0];
            default: shown = imm[15:0];
        endcase
    end

    assign led = shown;
    assign dp  = 1'b1;                      // decimal point off
    SevenSeg disp (.clk(clk), .value(shown), .seg(seg), .an(an));
endmodule
