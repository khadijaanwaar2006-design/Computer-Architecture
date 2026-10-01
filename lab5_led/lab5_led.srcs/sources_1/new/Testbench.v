`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/20/2026 08:24:59 PM
// Design Name: 
// Module Name: Testbench
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


`timescale 1ns / 1ps

module tb_fsm;

    reg clk;
    reg rst;
    reg [15:0] sw_in;
    wire [15:0] leds;

    // initiating design 
    fsm_countdown dut (
        .clk(clk),
        .rst(rst),
        .sw_in(sw_in),
        .leds(leds)
    );

    // Clock generation (10ns period)
    always #5 clk = ~clk;

    initial begin
        // Initialize inputs
        clk = 0;
        rst = 1;
        sw_in = 16'd0;

        // 1. Release reset and check IDLE state
        #20;
        rst = 0;
        #20;

        // 2. Apply non-zero switch input (e.g., 5)
        sw_in = 16'd5;
        #10;
        
        // 3. Change switch input immediately (FSM should ignore this during count)
        sw_in = 16'd12;
        
        // Wait for counter to reach 0 and return to IDLE (needs >5 clock cycles)
        #80; 
        
        // Return switches to 0 to stay in IDLE
        sw_in = 16'd0;
        #30;

        // 4. Test Asynchronous Reset mid-count
        sw_in = 16'd10; // Start new count from 10
        #10;
        sw_in = 16'd0;  // Reset switches
        #30;            // Let it count down to 7
        
        rst = 1;        // Press reset button
        #10;
        rst = 0;        // Release reset button
        
        // Wait and observe that it remains in IDLE
        #40;

        $display("Simulation complete. Check waveforms for verification.");
        $finish;
    end
endmodule


