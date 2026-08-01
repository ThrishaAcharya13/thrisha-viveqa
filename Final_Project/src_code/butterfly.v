`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.07.2026 23:18:01
// Design Name: 
// Module Name: butterfly
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


module butterfly #(
    parameter WIDTH = 5,
    parameter Q = 17
)(
    input  [WIDTH-1:0] A,
    input  [WIDTH-1:0] B,
    input  [WIDTH-1:0] W,

    output [WIDTH-1:0] A_out,
    output [WIDTH-1:0] B_out
);

wire [WIDTH-1:0] t;

// t = B × W mod Q
mod_mul #(WIDTH, Q) MUL (
    .a(B),
    .b(W),
    .product(t)
);

// A_out = A + t mod Q
mod_add #(WIDTH, Q) ADD (
    .a(A),
    .b(t),
    .sum(A_out)
);

// B_out = A - t mod Q
mod_sub #(WIDTH, Q) SUB (
    .a(A),
    .b(t),
    .diff(B_out)
);

endmodule