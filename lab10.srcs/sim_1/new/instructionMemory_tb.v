`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2026 10:37:44 AM
// Design Name: 
// Module Name: instructionMemory_tb
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

module instructionMemory_tb;
    reg  [31:0] pc;
    wire [31:0] instruction;

    instructionMemory #(.OPERAND_LENGTH(31)) uut (.instAddress(pc), .instruction(instruction));

    integer k;
    initial begin
        for (k = 0; k < 46; k = k + 1) begin
            pc = k * 4;
            #10;
            $display("PC=0x%03h  instruction=0x%08h", pc, instruction);
        end
        // past the program: NOP padding
        pc = 180; #10;
        $display("PC=0x%03h  instruction=0x%08h (expected NOP 00000013)", pc, instruction);
        $finish;
    end
endmodule