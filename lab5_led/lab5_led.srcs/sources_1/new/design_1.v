`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/17/2026 10:49:42 AM
// Design Name: 
// Module Name: design_1
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
module top_count(
    input wire clk,
    input wire resetbtn,
    input wire [15:0] sw,
    output wire [15:0] led  
);

wire clean_rst;
    debouncer all(
        .clk(clk),
        .pbin(resetbtn),
        .pbout(clean_rst)
);

countdown_fsm myfsm(
    .clk(clk),
    .rst_clean(clean_rst),
    .sw(sw),
    .ledo(led)
);    
endmodule    


