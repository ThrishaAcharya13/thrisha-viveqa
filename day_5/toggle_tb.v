`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.06.2026 16:24:22
// Design Name: 
// Module Name: toggle_tb
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

module toggle_tb(
    input  clk,
    input  pulse,
    output reg q
);

wire q_bar;
wire d;

assign q_bar = ~q;

// MUX instance
mux2to1 M1 (
    .i0(q),      // hold state
    .i1(q_bar),  // toggle state
    .sel(pulse),
    .y(d)
);

// D Flip-Flop
always @(posedge clk)
begin
    q <= d;
end

endmodule
