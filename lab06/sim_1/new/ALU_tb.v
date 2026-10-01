`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/01/2026 09:03:51 AM
// Design Name: 
// Module Name: ALU_tb
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

module ALU_tb;
    reg  [31:0] A, B;
    reg  [3:0]  ALUControl;
    wire [31:0] ALUResult;
    wire Zero;

    ALU uut (.A(A), .B(B), .ALUControl(ALUControl), .ALUResult(ALUResult), .Zero(Zero));

    initial begin
        A = 32'h10101010;
        B = 32'h01010101;

        ALUControl = 4'b0010; #10; // ADD        (wait 10ns between each)
        ALUControl = 4'b0110; #10; // SUB
        ALUControl = 4'b0000; #10; // AND
        ALUControl = 4'b0001; #10; // OR
        ALUControl = 4'b0100; #10; // XOR
        ALUControl = 4'b0011; #10; // SLL
        ALUControl = 4'b0101; #10; // SRL

        A = 32'h10101010; B = 32'h10101010;   //testing for beq
        ALUControl = 4'b0110; #10; //in case of beq SUB Zero should equal 1

        $finish;
    end
endmodule
