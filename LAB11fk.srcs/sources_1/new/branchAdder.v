`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2026 08:35:46 AM
// Design Name: 
// Module Name: ProgramCounter
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

// Branch Adder: computes the branch target, PC + (sign-extended imm << 1).
// immGen outputs the B-type immediate WITHOUT the implicit trailing 0 bit,
// so the left shift by 1 here restores the correct byte offset.
module branchAdder (
    input  wire [31:0] pc,
    input  wire [31:0] imm,
    output wire [31:0] branch_target
);

    assign branch_target = pc + (imm << 1);

endmodule