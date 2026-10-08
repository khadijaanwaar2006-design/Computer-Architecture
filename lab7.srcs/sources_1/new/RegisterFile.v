`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/08/2026 09:08:53 AM
// Design Name: 
// Module Name: RegisterFile
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


module RegisterFile(
    
    input wire  clk,
    input wire  rst,
    input wire  WriteEnable,    //signal(1/0)
    input wire [4:0]rs1,    //5 bit source reg(1)
    input wire [4:0]rs2,     //5 bit source reg(2)
    input wire [4:0]rd,      //5 bit destination reg
    input wire [31:0]WriteData,     //32 bit written back into the file register
    output wire [31:0]ReadData1,    //output 1 (for rs1)
    output wire [31:0]ReadData2     //output 2 (for rs2)
);

    reg[31:0] regs[31:0];    //this makes 32 registers which are 32 bit wide

    integer i; //variable assigned to iterate over the 32 bits
    always @(posedge clk) begin
        if (rst) begin  //the if conditon checks if the reset was active(1)
            for (i = 0; i < 32; i = i + 1) begin    //loop iterates over each 32 bit reister and assigns there value to 0
                regs[i] <= 32'h00000000;
            end
        end else if (WriteEnable && (rd != 5'b00000)) begin //if writeenale is (1) and rd !=0 assigns value of destination reg to writedata 
            regs[rd] <= WriteData;  //assigns value stored in write data into destination register
        end
    end
    assign ReadData1 = (rs1 == 5'b00000) ? 32'h00000000 : regs[rs1]; //if rs1=0 it forces readdata to be equal to 0 and for any other address outputs the val stored at rs1
    assign ReadData2 = (rs2 == 5'b00000) ? 32'h00000000 : regs[rs2];

endmodule

