`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/01/2026 09:27:50 AM
// Design Name: 
// Module Name: ALU_Top
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

module ALU_Top (
    input  wire clk,         
    input  wire rst,         // reset
    input  wire btn_next,    // Pushbutton to toggle result view (Low/High 16 bits)
    input  wire [3:0] sw_control,  // Board switches [3:0] mapped to ALUControl[3:0]
    output reg [14:0] leds,        // 16 board LEDs for 16-bit result 
    output wire led_zero     // LED for Zero flag
);

    wire [31:0] A = 32'h10101010;    //from lab manual
    wire [31:0] B = 32'h01010101;
    
    wire [31:0] alu_result;
    wire btn_clean;
    reg display_sel; // 0 = Lower 16 bits, 1 = Upper 16 bits

    debouncer deb_inst (   //instantiating deboumcer module
        .clk(clk),
        .pbin(btn_next),
        .pbout(btn_clean)
    );


    ALU alu_inst (         //instantiating ALU module
        .A(A),
        .B(B),
        .ALUControl(sw_control),
        .ALUResult(alu_result),
        .Zero(led_zero)
    );

    // Display FSM Logic 
    always @(posedge clk or posedge rst) begin
        if (rst)
            display_sel <= 1'b0;
        else if (btn_clean)
            display_sel <= ~display_sel; 
    end

    // LED MUX (Drive 16 physical LEDs with lower or upper result half)
    always @(*) begin
        if (display_sel)
            leds = alu_result[30:16]; // Upper 15 bits
        else
            leds = alu_result[14:0];  // Lower 15 bits
    end

endmodule

module debouncer(
    input clk,
    input pbin,
    output pbout
    );
  
    assign pbout = pbin;
endmodule

module switches(
    input clk,
    input rst,
    input [31:0] writeData,
    input writeEnable,
    input readEnable,
    input [29:0] memAddress,
    output reg [31:0] readData = 0,
    output reg [15:0] leds
);

    // Emergency LED writing logic
    always @(posedge clk) begin
        if (rst) 
            leds <= 16'd0;
        else if (writeEnable) 
            leds <= writeData[15:0];
    end
endmodule

module leds(
    input clk,
    input rst,
    input [15:0] btns,
    input [31:0] writeData,
    input writeEnable,
    input readEnable,
    input [29:0] memAddress,
    input [15:0] switches,
    output [31:0] readData
    );
  
    assign readData = {16'd0, switches};
endmodule