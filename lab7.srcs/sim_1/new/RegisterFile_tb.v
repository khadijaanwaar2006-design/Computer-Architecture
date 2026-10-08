`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/08/2026 09:26:29 AM
// Design Name: 
// Module Name: RegisterFile_tb
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


module RegisterFile_tb;

    reg  clk;
    reg  rst;
    reg  WriteEnable;
    reg  [4:0]rs1;
    reg  [4:0]rs2;
    reg  [4:0]rd;
    reg  [31:0]WriteData;

    wire [31:0]ReadData1;
    wire [31:0]ReadData2;

    // Instantiate Unit Under Test
    RegisterFile uut (
        .clk(clk),
        .rst(rst),
        .WriteEnable(WriteEnable),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .WriteData(WriteData),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2)
    );
    // 100 MHz Clock (10ns period) , toggles every 5 ns
    always #5 clk = ~clk;
    initial begin           //initializing values
        clk=0;
        rst=1;
        WriteEnable=0;
        rs1=5'd0;
        rs2=5'd0;
        rd=5'd0;
        WriteData=32'h00000000;

        // Resetting the pulse
        #20;
        rst=0;
        #10;

        // Test 1: Write 0xDEADBEEF to x5 and read back on rs1
        rd=5'd5;
        WriteData =32'hDEADBEEF;
        WriteEnable=1;
        #10;
        
        WriteEnable=0;
        rs1=5'd5;
        #10;

        //Test2: Writing rd=0
        rd=5'd0;
        WriteData=32'hFFFFFFFF;
        WriteEnable=1;
        #10;
        
        WriteEnable=0;
        rs1=5'd0;
        #10;

        //Test3:Reading values (x5 on rs1, x6 on rs2), then confimrms if the values we set are being read by readdat1 and readdata2
        rd =5'd6;       
        WriteData =32'h12345678;
        WriteEnable=1;
        #10;
        
        WriteEnable=0;
        rs1 =5'd5;
        rs2 =5'd6;
        #10;

        //test4: overwriting x5 with 0xCAFEBABE
        rd  = 5'd5;
        WriteData =32'hCAFEBABE;
        WriteEnable=1;
        #10;
        
        WriteEnable=0;
        rs1= 5'd5;
        #10;

        // Test 5: assigns reset=1 and makes sure all the register values are set back to zero
        rst=1;
        #10;
        rst=0;
        rs1=5'd5;
        rs2=5'd6;
        #10;
        $finish;
    end

endmodule
