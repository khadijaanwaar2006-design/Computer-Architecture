`timescale 1ns / 1ps
// =====================================================================
// TopLevelProcessor.v
// Single-Cycle RISC-V (RV32I subset) processor with Memory-Mapped I/O.
// =====================================================================

// ---------------------------------------------------------------------
// Instruction Memory: loads external .mem file via MEMFILE parameter
// ---------------------------------------------------------------------
module InstructionMemory #(
    parameter MEMFILE = "instr.mem"
)(
    input  wire [31:0] addr,
    output wire [31:0] instr
);
    reg [31:0] mem [0:255];
    integer i;

    initial begin
        for (i = 0; i < 256; i = i + 1)
            mem[i] = 32'h00000013; // NOP
        $readmemh(MEMFILE, mem);
    end

    assign instr = mem[addr[9:2]];
endmodule


// ---------------------------------------------------------------------
// Main Control Unit: decodes the opcode into datapath control signals.
// ---------------------------------------------------------------------
module ControlUnit (
    input  wire [6:0] opcode,
    output reg        Branch,
    output reg        MemRead,
    output reg        MemtoReg,
    output reg  [1:0] ALUOp,     // 00 = add, 01 = sub (branch), 10 = R-type, 11 = I-type ALU
    output reg        MemWrite,
    output reg        ALUSrc,
    output reg        RegWrite
);

    always @(*) begin
        Branch   = 1'b0;
        MemRead  = 1'b0;
        MemtoReg = 1'b0;
        ALUOp    = 2'b00;
        MemWrite = 1'b0;
        ALUSrc   = 1'b0;
        RegWrite = 1'b0;

        case (opcode)
            7'b0110011: begin // R-type (add, sub, and, or, xor, slt)
                RegWrite = 1'b1;
                ALUOp    = 2'b10;
            end
            7'b0010011: begin // I-type ALU (addi, andi, ori, xori, slti)
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                ALUOp    = 2'b11;
            end
            7'b0000011: begin // lw
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                MemRead  = 1'b1;
                MemtoReg = 1'b1;
                ALUOp    = 2'b00;
            end
            7'b0100011: begin // sw
                ALUSrc   = 1'b1;
                MemWrite = 1'b1;
                ALUOp    = 2'b00;
            end
            7'b1100011: begin // beq
                Branch   = 1'b1;
                ALUOp    = 2'b01;
            end
            default: ;
        endcase
    end

endmodule


// ---------------------------------------------------------------------
// ALU Control: ALUOp + funct3/funct7 -> 4-bit ALU operation code.
//   0000 AND   0001 OR   0010 ADD   0011 XOR   0110 SUB   0111 SLT
// ---------------------------------------------------------------------
module ALUControl (
    input  wire [1:0] ALUOp,
    input  wire [2:0] funct3,
    input  wire       funct7_5,     // instruction bit 30
    output reg  [3:0] alu_ctrl
);

    always @(*) begin
        case (ALUOp)
            2'b00: alu_ctrl = 4'b0010;           // lw / sw  -> ADD
            2'b01: alu_ctrl = 4'b0110;           // beq      -> SUB

            2'b10: begin                         // R-type
                case (funct3)
                    3'b000:  alu_ctrl = funct7_5 ? 4'b0110 : 4'b0010; // sub : add
                    3'b111:  alu_ctrl = 4'b0000;                      // and
                    3'b110:  alu_ctrl = 4'b0001;                      // or
                    3'b100:  alu_ctrl = 4'b0011;                      // xor
                    3'b010:  alu_ctrl = 4'b0111;                      // slt
                    default: alu_ctrl = 4'b0010;
                endcase
            end

            2'b11: begin                         // I-type ALU (funct7 ignored)
                case (funct3)
                    3'b000:  alu_ctrl = 4'b0010;                      // addi
                    3'b111:  alu_ctrl = 4'b0000;                      // andi
                    3'b110:  alu_ctrl = 4'b0001;                      // ori
                    3'b100:  alu_ctrl = 4'b0011;                      // xori
                    3'b010:  alu_ctrl = 4'b0111;                      // slti
                    default: alu_ctrl = 4'b0010;
                endcase
            end

            default: alu_ctrl = 4'b0010;
        endcase
    end

endmodule


// ---------------------------------------------------------------------
// 32-bit ALU with Zero flag.
// ---------------------------------------------------------------------
module ALU (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  alu_ctrl,
    output reg  [31:0] result,
    output wire        zero
);

    always @(*) begin
        case (alu_ctrl)
            4'b0000: result = a & b;                                     // AND
            4'b0001: result = a | b;                                     // OR
            4'b0010: result = a + b;                                     // ADD
            4'b0011: result = a ^ b;                                     // XOR
            4'b0110: result = a - b;                                     // SUB
            4'b0111: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; // SLT
            default: result = 32'b0;
        endcase
    end

    assign zero = (result == 32'b0);

endmodule


// ---------------------------------------------------------------------
// Register File: 32 x 32-bit, 2 async read ports, 1 sync write port.
// x0 is hardwired to zero.
// ---------------------------------------------------------------------
module RegisterFile (
    input  wire        clk,
    input  wire        rst,
    input  wire        RegWrite,
    input  wire [4:0]  read_reg1,
    input  wire [4:0]  read_reg2,
    input  wire [4:0]  write_reg,
    input  wire [31:0] write_data,
    output wire [31:0] read_data1,
    output wire [31:0] read_data2
);

    reg [31:0] regs [0:31];
    integer i;

    initial begin
        for (i = 0; i < 32; i = i + 1)
            regs[i] = 32'b0;
    end

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'b0;
        end else if (RegWrite && (write_reg != 5'b0)) begin
            regs[write_reg] <= write_data;
        end
    end

    assign read_data1 = (read_reg1 == 5'b0) ? 32'b0 : regs[read_reg1];
    assign read_data2 = (read_reg2 == 5'b0) ? 32'b0 : regs[read_reg2];

endmodule


// ---------------------------------------------------------------------
// Data Memory: 128 words (512 bytes), word-aligned.
// ---------------------------------------------------------------------
module DataMemory (
    input  wire        clk,
    input  wire        MemRead,
    input  wire        MemWrite,
    input  wire [31:0] address,
    input  wire [31:0] write_data,
    output wire [31:0] read_data
);

    reg [31:0] mem [0:127];
    integer i;

    initial begin
        for (i = 0; i < 128; i = i + 1)
            mem[i] = 32'b0;
    end

    always @(posedge clk) begin
        if (MemWrite)
            mem[address[8:2]] <= write_data;
    end

    assign read_data = MemRead ? mem[address[8:2]] : 32'b0;

endmodule


// ---------------------------------------------------------------------
// Top Level Processor with Memory-Mapped I/O (LEDs, Switches, Buttons)
// ---------------------------------------------------------------------
module TopLevelProcessor #(
    parameter MEMFILE = "instr.mem"
)(
    input  wire        clk,
    input  wire        rst,
    input  wire [15:0] sw,
    input  wire [15:0] btns,
    output reg  [15:0] led
);

    // Internal signals
    wire [31:0] pc, pc_next, pc_plus4, branch_target;
    wire [31:0] instr, imm;
    wire [31:0] read_data1, read_data2;
    wire [31:0] alu_b, alu_result;
    wire [31:0] mem_read_data, final_read_data, write_back_data;

    wire        Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;
    wire [1:0]  ALUOp;
    wire [3:0]  alu_ctrl;
    wire        zero, PCSrc;

    // ---- Fetch ----
    assign PCSrc = Branch & zero;

    ProgramCounter pc_reg (
        .clk(clk), .reset(rst), .pc_next(pc_next), .pc(pc)
    );

    pcAdder pc_add (
        .pc(pc), .pc_plus4(pc_plus4)
    );

    branchAdder br_add (
        .pc(pc), .imm(imm), .branch_target(branch_target)
    );

    mux2 pc_mux (
        .in0(pc_plus4), .in1(branch_target), .sel(PCSrc), .out(pc_next)
    );

    InstructionMemory #(.MEMFILE(MEMFILE)) imem (
        .addr(pc), .instr(instr)
    );

    // ---- Decode ----
    ControlUnit ctrl (
        .opcode(instr[6:0]),
        .Branch(Branch), .MemRead(MemRead), .MemtoReg(MemtoReg),
        .ALUOp(ALUOp), .MemWrite(MemWrite), .ALUSrc(ALUSrc), .RegWrite(RegWrite)
    );

    ALUControl alu_ctrl_unit (
        .ALUOp(ALUOp), .funct3(instr[14:12]), .funct7_5(instr[30]),
        .alu_ctrl(alu_ctrl)
    );

    RegisterFile rf (
        .clk(clk), .rst(rst), .RegWrite(RegWrite),
        .read_reg1(instr[19:15]), .read_reg2(instr[24:20]),
        .write_reg(instr[11:7]),  .write_data(write_back_data),
        .read_data1(read_data1),  .read_data2(read_data2)
    );

    immGen ig (
        .instr(instr), .imm(imm)
    );

    // ---- Execute ----
    mux2 alusrc_mux (
        .in0(read_data2), .in1(imm), .sel(ALUSrc), .out(alu_b)
    );

    ALU alu (
        .a(read_data1), .b(alu_b), .alu_ctrl(alu_ctrl),
        .result(alu_result), .zero(zero)
    );

    // ---- Memory & MMIO Address Decoder ----
    // Address map:
    //   0   .. 511 : Data Memory
    //   512 .. 767 : LEDs (write)
    //   768        : Switches (read)
    //   772        : Buttons (read)
    wire is_dmem = (alu_result[31:9] == 23'd0);
    wire is_led  = (alu_result >= 32'd512 && alu_result < 32'd768);
    wire is_sw   = (alu_result == 32'd768);
    wire is_btns = (alu_result == 32'd772);

    DataMemory dmem (
        .clk(clk),
        .MemRead(MemRead & is_dmem),
        .MemWrite(MemWrite & is_dmem),
        .address(alu_result),
        .write_data(read_data2),
        .read_data(mem_read_data)
    );

    // LED Output Register
    always @(posedge clk) begin
        if (rst)
            led <= 16'd0;
        else if (MemWrite && is_led)
            led <= read_data2[15:0];
    end

    // Read Data Mux (Data Memory vs. Switches vs. Buttons)
    assign final_read_data = is_sw   ? {16'd0, sw}   :
                             is_btns ? {16'd0, btns} :
                                       mem_read_data;

    // ---- Write-Back ----
    mux2 memtoreg_mux (
        .in0(alu_result), .in1(final_read_data), .sel(MemtoReg), .out(write_back_data)
    );

endmodule