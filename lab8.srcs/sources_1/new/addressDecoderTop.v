`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2026 08:48:09 AM
// Design Name: 
// Module Name: addressDecoderTop
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


module addressDecoderTop(
    input clk, rst,
    input [31:0] address,
    input readEnable, writeEnable,
    input [31:0] writeData,
    input [15:0] switches,
    output [31:0] readData,
    output [15:0] leds );
    
    wire [9:0] addr10 = address[9:0]; // Only the 10 LSBs of the address will be used
 
    wire DataMemWrite, DataMemRead, LEDWrite, SwitchReadEnable;
 
    AddressDecoder dec (
        .sel(addr10[9:8]),
        .MemRead(readEnable),
        .MemWrite(writeEnable),
        .DataMemWrite(DataMemWrite),
        .DataMemRead(DataMemRead),
        .LEDWrite(LEDWrite),
        .SwitchReadEnable(SwitchReadEnable)
    );
 
    wire [31:0] mem_rdata, sw_rdata, led_rdata_unused;
 
    DataMemory dmem (
        .clk(clk),
        .MemWrite(DataMemWrite),
        .address(addr10[8:0]),
        .write_data(writeData),
        .read_data(mem_rdata)
    );
 
    // LED output interface 
    switches led_if (
        .clk(clk),
        .rst(rst),
        .writeData(writeData),
        .writeEnable(LEDWrite),
        .readEnable(1'b0),
        .memAddress(address[31:2]),
        .readData(),                     // not to be read
        .leds(leds)
    );
 
    // Switch input interface 
    leds sw_if (
        .clk(clk),
        .rst(rst),
        .btns(16'b0),                    // buttons not used in this lab
        .writeData(32'b0),               // not to be written
        .writeEnable(1'b0),              // not to be used
        .readEnable(SwitchReadEnable),
        .memAddress(address[31:2]),
        .switches(switches),
        .readData(sw_rdata)
    );
 
    assign readData = DataMemRead      ? mem_rdata :
                      SwitchReadEnable ? sw_rdata  :
                      32'b0;
endmodule
 
module AddressDecoder (
    input [1:0] sel,               // address[9:8]
    input MemRead,
    input MemWrite,
    output DataMemWrite,
    output DataMemRead,
    output LEDWrite,
    output SwitchReadEnable
);
    wire DataMemSelect, LEDSelect, SwitchSelect;
 
    assign DataMemSelect = (sel == 2'b00);
    assign LEDSelect = (sel == 2'b01);
    assign SwitchSelect = (sel == 2'b10);
 
    assign DataMemWrite = DataMemSelect & MemWrite;
    assign DataMemRead = DataMemSelect & MemRead;
    assign LEDWrite = LEDSelect & MemWrite;   
    assign SwitchReadEnable = SwitchSelect & MemRead;    
endmodule
 
module DataMemory (
    input clk,
    input MemWrite,
    input [8:0] address,
    input [31:0] write_data,
    output [31:0] read_data
);
    reg[31:0] mem[0:511];
 
    integer i;
    initial begin
        for (i = 0; i < 512; i = i + 1)
            mem[i] = 32'b0;
    end
 
    always @(posedge clk) begin
        if (MemWrite)
            mem[address] <= write_data;
    end
 
    assign read_data = mem[address];
endmodule
 
module switches(
    input clk,
    input rst,
    input [31:0] writeData,
    input writeEnable,
    input readEnable,
    input [29:0] memAddress,
    output reg [31:0] readData = 0,   // not to be read
    output reg [15:0] leds
);
    always @(posedge clk) begin
        if (rst)
            leds <= 16'b0;
        else if (writeEnable)
            leds <= writeData[15:0];
    end
endmodule
 
module leds(
    input clk, rst,
    input [15:0] btns,
    input [31:0] writeData,           // not to be written
    input writeEnable,                // not to be used
    input readEnable,
    input [29:0] memAddress,
    input [15:0] switches,
    output reg [31:0] readData
);
    always @(*) begin
        if (readEnable)
            readData = {16'b0, switches};
        else
            readData = 32'b0;
    end
endmodule
