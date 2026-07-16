`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.06.2026 16:48:41
// Design Name: 
// Module Name: trigger
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


module trigger(
    input clk,
    input d,
    input [1:0] sel,      // 00=posedge, 01=negedge, 10=both-edge
    output reg q
);

reg q_pos, q_neg, q_both;

// Positive-edge triggered
always @(posedge clk)
begin
    q_pos <= d;
end

// Negative-edge triggered
always @(negedge clk)
begin
    q_neg <= d;
end

// Both-edge triggered (simulation only)
always @(posedge clk or negedge clk)
begin
    q_both <= d;
end

// Select output
always @(*)
begin
    case(sel)
        2'b00: q = q_pos;
        2'b01: q = q_neg;
        2'b10: q = q_both;
        default: q = 1'b0;
    endcase
end

endmodule
