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
//////////////////////////////////////////////////////////////////////////////////`timescale 1ns / 1ps
// 2-to-1 multiplexer (parameterized width, default 32 bits).
// Used for PCSrc, ALUSrc and MemtoReg selection.
module mux2 #(
    parameter WIDTH = 32
)(
    input  wire [WIDTH-1:0] in0,   // selected when sel = 0
    input  wire [WIDTH-1:0] in1,   // selected when sel = 1
    input  wire sel,
    output wire [WIDTH-1:0] out
);

    assign out = sel ? in1 : in0;

endmodule
