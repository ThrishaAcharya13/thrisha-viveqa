`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.07.2026 23:14:54
// Design Name: 
// Module Name: mod_mul
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


module mod_mul #(
    parameter WIDTH = 5,
    parameter Q = 17
)(
    input  [WIDTH-1:0] a,
    input  [WIDTH-1:0] b,
    output [WIDTH-1:0] product
);

wire [2*WIDTH-1:0] mult;

assign mult = a * b;
assign product = mult % Q;

endmodule
