`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.07.2026 10:32:51
// Design Name: 
// Module Name: inverse_butterfly
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

//////////////////////////////////////////////////////////////////////////////////
// Module: inverse_butterfly
// Simplified Inverse NTT Butterfly
//////////////////////////////////////////////////////////////////////////////////

module inverse_butterfly(

    input  [4:0] A,
    input  [4:0] B,
    input  [4:0] W,

    output [4:0] A_out,
    output [4:0] B_out

);

wire [4:0] sum;
wire [4:0] diff;
wire [4:0] mult;

//----------------------------------
// sum = A + B
//----------------------------------

mod_add ADD(

    .a(A),
    .b(B),
    .sum(sum)

);

//----------------------------------
// diff = A - B
//----------------------------------

mod_sub SUB(

    .a(A),
    .b(B),
    .diff(diff)

);

//----------------------------------
// mult = diff × W
//----------------------------------

mod_mul MUL(

    .a(diff),
    .b(W),
    .product(mult)

);

//----------------------------------
// Outputs
//----------------------------------

assign A_out = sum;
assign B_out = mult;

endmodule
