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
//////////////////////////////////////////////////////////////////////////////////1ps
//////////////////////////////////////////////////////////////////////////////////1ps
// Immediate Generator: supports I, S and B type immediates (RV32I).
//
// Note on B-type: the 12 immediate bits imm[12|11|10:5|4:1] are placed in
// imm[11:0] and sign-extended. The "<< 1" is done in branchAdder, matching
// the datapath diagram (Shift left 1 before the branch adder).
module immGen (
    input  wire [31:0] instr,
    output reg  [31:0] imm
);

    wire [6:0] opcode = instr[6:0];

    always @(*) begin
        case (opcode)
            // I-type: OP-IMM, LOAD, JALR
            7'b0010011,
            7'b0000011,
            7'b1100111:
                imm = {{20{instr[31]}}, instr[31:20]};

            // S-type: STORE
            7'b0100011:
                imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};

            // B-type: BRANCH
            7'b1100011:
                imm = {{20{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8]};

            default:
                imm = 32'b0;
        endcase
    end

endmodule
