`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2026 08:42:18 AM
// Design Name: 
// Module Name: tb_task1
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

module tb_task1;

    reg         clk;
    reg         reset;
    reg         PCSrc;
    reg  [31:0] instr;

    wire [31:0] pc, pc_plus4, branch_target, pc_next, imm;

    ProgramCounter pc_reg (.clk(clk), .reset(reset), .pc_next(pc_next), .pc(pc));
    pcAdder        pc_add (.pc(pc), .pc_plus4(pc_plus4));
    immGen         ig     (.instr(instr), .imm(imm));
    branchAdder    br_add (.pc(pc), .imm(imm), .branch_target(branch_target));
    mux2           pc_mux (.in0(pc_plus4), .in1(branch_target), .sel(PCSrc), .out(pc_next));

    // 10 ns clock
    initial clk = 0;
    always #5 clk = ~clk;

    integer errors = 0;

    task check(input [31:0] actual, input [31:0] expected, input [255:0] name);
        begin
            if (actual !== expected) begin
                $display("FAIL %0s: got %h (%0d), expected %h (%0d)", name, actual, $signed(actual), expected, $signed(expected));
                errors = errors + 1;
            end else
                $display("PASS %0s: %h (%0d)", name, actual, $signed(actual));
        end
    endtask

    initial begin
        $dumpfile("tb_task1.vcd");
        $dumpvars(0, tb_task1);

        reset = 1; PCSrc = 0; instr = 32'h00000013; // nop (addi x0,x0,0)
        @(posedge clk); #1;
        reset = 0;
        check(pc, 32'd0, "PC after reset");

        // --- PC + 4 when PCSrc = 0 ---
        @(posedge clk); #1; check(pc, 32'd4,  "PC+4 (1)");
        @(posedge clk); #1; check(pc, 32'd8,  "PC+4 (2)");
        @(posedge clk); #1; check(pc, 32'd12, "PC+4 (3)");

        // --- Branch taken: beq x1,x2,+8  (pc = 12 -> 20) ---
        instr = 32'h00208463; PCSrc = 1;
        #1; check(imm, 32'd4, "B imm raw (+8>>1)");
        @(posedge clk); #1; check(pc, 32'd20, "Branch +8");

        // --- Branch taken: beq x1,x2,-8  (pc = 20 -> 12) ---
        instr = 32'hFE208CE3; PCSrc = 1;
        #1; check(imm, 32'hFFFFFFFC, "B imm raw (-8>>1)");
        @(posedge clk); #1; check(pc, 32'd12, "Branch -8");

        // --- Back to sequential ---
        PCSrc = 0;
        @(posedge clk); #1; check(pc, 32'd16, "PC+4 after branch");

        // --- Immediate generator: I, S ---
        instr = 32'hFFF10093; #1; check(imm, 32'hFFFFFFFF, "I-type addi -1");
        instr = 32'h00812283; #1; check(imm, 32'd8,        "I-type lw 8");
        instr = 32'hFE512E23; #1; check(imm, 32'hFFFFFFFC, "S-type sw -4");

        if (errors == 0) $display("ALL TESTS PASSED");
        else             $display("%0d TEST(S) FAILED", errors);
        $finish;
    end

endmodule

