`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/08/2026 10:18:35 AM
// Design Name: 
// Module Name: RF_ALU_FSM_tb
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



module RF_ALU_FSM_tb;
    reg clk;
    reg rst;

    // FSM State Encoding
    localparam STATE_IDLE = 4'd0;
    localparam STATE_WRITE_REGS = 4'd1;
    localparam STATE_ADD  = 4'd2;
    localparam STATE_SUB = 4'd3;
    localparam STATE_AND = 4'd4;
    localparam STATE_OR = 4'd5;
    localparam STATE_XOR  = 4'd6;
    localparam STATE_SLL  = 4'd7;
    localparam STATE_SRL = 4'd8;
    localparam STATE_CHECK_ZERO = 4'd9;
    localparam STATE_READ_AFTER_WRITE = 4'd10;
    localparam STATE_DONE  = 4'd11;

    reg [3:0]current_state, next_state;

    // Register File Signals
    reg rf_we;
    reg [4:0]rf_rs1, rf_rs2, rf_rd;
    reg [31:0]rf_writedata;
    wire [31:0]rf_readdata1, rf_readdata2;

    // alu signals
    reg [3:0]alu_control;
    wire [31:0]alu_result;
    wire alu_zero;

    // Instantiating the register file
    RegisterFile rf_inst (
        .clk(clk),
        .rst(rst),
        .WriteEnable(rf_we),
        .rs1(rf_rs1),
        .rs2(rf_rs2),
        .rd(rf_rd),
        .WriteData(rf_writedata),
        .ReadData1(rf_readdata1),
        .ReadData2(rf_readdata2)
    );

    // Instantiating the ALU
    ALU alu_inst (
        .A(rf_readdata1),
        .B(rf_readdata2),
        .ALUControl(alu_control),
        .ALUResult(alu_result),
        .Zero(alu_zero)
    );

    //100 MHz Clock (10ns period), toggles at every 5ns
    always #5 clk=~clk;

    always @(posedge clk or posedge rst) begin  //updating the state registers
        if (rst)
            current_state <= STATE_IDLE;
        else
            current_state <= next_state;
    end

    always @(*) begin        // State Machine and Signal Generation
        rf_we=1'b0;         //assigning default assignments 
        rf_rs1=5'd0;
        rf_rs2=5'd0;
        rf_rd=5'd0;
        rf_writedata=32'd0;
        alu_control=4'b0000;
        next_state=current_state;

        case (current_state)
            STATE_IDLE: begin
                next_state=STATE_WRITE_REGS;
            end

            // Step1: assigning values to x1 as 0x10101010 and x2 as 0x01010101
            STATE_WRITE_REGS: begin
                rf_we=1'b1;
                rf_rd=5'd1;
                rf_writedata=32'h10101010;
                next_state=STATE_ADD;
            end

            // Step2: Reads x1 and x2, performs ADD using ALU and puts result in x4
            STATE_ADD: begin
                rf_rs1=5'd1;
                rf_rs2=5'd2;
                alu_control=4'b0010; // ADD operation
                rf_we=1'b1;
                rf_rd=5'd4;
                rf_writedata=alu_result;
                next_state=STATE_SUB;
            end

            // Step3: Reads x1 and x2, performs SUB using ALU and puts result in x5
            STATE_SUB: begin
                rf_rs1=5'd1;
                rf_rs2=5'd2;
                alu_control=4'b0110; // SUB operation
                rf_we=1'b1;
                rf_rd=5'd5;
                rf_writedata=alu_result;
                next_state=STATE_AND;
            end

            // Step4: Reads x1 and x2, performs AND using ALU and puts result in x6
            STATE_AND: begin
                rf_rs1=5'd1;
                rf_rs2=5'd2;
                alu_control=4'b0000; // AND operation
                rf_we=1'b1;
                rf_rd=5'd6;
                rf_writedata=alu_result;
                next_state=STATE_OR;
            end

            // Step5: Reads x1 and x2, performs OR using ALU and puts result in x7
            STATE_OR: begin
                rf_rs1=5'd1;
                rf_rs2=5'd2;
                alu_control=4'b0001; // OR operation
                rf_we=1'b1;
                rf_rd=5'd7;
                rf_writedata=alu_result;
                next_state=STATE_XOR;
            end

            // Step6: Reads x1 and x2, performs XOR using ALU and puts result in x8
            STATE_XOR: begin
                rf_rs1=5'd1;
                rf_rs2=5'd2;
                alu_control=4'b0100; // XOR operation
                rf_we=1'b1;
                rf_rd=5'd8;
                rf_writedata=alu_result;
                next_state=STATE_SLL;
            end

            // Step7: Reads x1 and x2, performs SLL using ALU and puts result in x9
            STATE_SLL: begin
                rf_rs1=5'd1;
                rf_rs2=5'd2;
                alu_control=4'b0011; // SLL operation
                rf_we=1'b1;
                rf_rd=5'd9;
                rf_writedata=alu_result;
                next_state=STATE_SRL;
            end

            // Step8: Reads x1 and x2, performs SRL using ALU and puts result in x10
            STATE_SRL: begin
                rf_rs1=5'd1;
                rf_rs2=5'd2;
                alu_control=4'b0101; // SRL operation
                rf_we=1'b1;
                rf_rd=5'd10;
                rf_writedata=alu_result;
                next_state=STATE_CHECK_ZERO;
            end

            // Step9: performs subtraction specifically x1-x1 in ALU, writes Zero flag result to x3
            STATE_CHECK_ZERO: begin
                rf_rs1=5'd1;
                rf_rs2=5'd1;
                alu_control=4'b0110; // SUB operation
                rf_we=1'b1;
                rf_rd=5'd3;
                rf_writedata={31'd0, alu_zero};
                next_state=STATE_READ_AFTER_WRITE;
            end

            // Step10: writes to x11 and immediately reads on rs1 to check timing
            STATE_READ_AFTER_WRITE: begin
                rf_we=1'b1;
                rf_rd=5'd11;
                rf_writedata=32'hA5A5A5A5;
                rf_rs1=5'd11; // reads rs1 to look at x11
                next_state=STATE_DONE;
            end

            STATE_DONE: begin
                next_state=STATE_DONE;
            end

            default: next_state=STATE_IDLE;
        endcase
    end

    initial begin
        clk =0;
        rst =1;
        #20;
        rst =0;
        #250;
        $finish;
    end
endmodule
