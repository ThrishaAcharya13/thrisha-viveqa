`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.07.2026 23:09:57
// Design Name: 
// Module Name: mod_add
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


module mod_add #(
    parameter WIDTH = 5,
    parameter Q = 17
)(
    input  [WIDTH-1:0] a,
    input  [WIDTH-1:0] b,
    output [WIDTH-1:0] sum
);

wire [WIDTH:0] temp_sum;

assign temp_sum = a + b;

assign sum = (temp_sum >= Q) ? (temp_sum - Q) : temp_sum;

endmodule