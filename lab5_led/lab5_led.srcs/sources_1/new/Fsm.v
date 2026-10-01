`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/20/2026 08:04:49 PM
// Design Name: 
// Module Name: Fsm
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


module Fsm(
    input wire clk,
    input wire rst,
    input wire [15:0] insw,
    output reg [15:0] leds
    );
    //declaring parameters for when machin is idle and when its counting
    localparam IDLE = 1'b0;
    localparam COUNT = 1'b1;
    
    //initializing registers for the next sttae nd counter 
    reg state, nxtstate;
    reg [15:0]countr, nxtcount;
    
    always @(posedge clk or posedge rst) begin
    //if input is reset (reset state) implimentation
        if (rst) begin
            state   <= IDLE;
            countr <= 16'd0;
    //button no longer pressed        
        end else begin
            state <= nxtstate;
            countr <= nxtcount;
        end
    end
    
    always @(*) begin
    //if 
        nxtstate = state;
        nxtcount = countr;
        leds = 16'd0;
        
        case(state)
            IDLE: begin
                leds = 16'd0;
                
                if (insw != 16'd0) begin
                    nxtcount = insw;
                    nxtstate = COUNT;
                    leds = insw;
                end   
            end      
            COUNT: begin
                leds = countr;
                
                if (countr == 16'd0) begin
                    nxtstate = IDLE;
                end                
                else begin
                    nxtcount = countr - 16'd1;
                end                  
            end                           
            default: 
                nxtstate = IDLE;
            endcase
        end                
endmodule
