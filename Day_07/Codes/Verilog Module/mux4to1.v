`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.06.2026 12:35:49
// Design Name: 
// Module Name: mux4to1
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


module mux4to1(
input wire [3:0]d,
input wire [1:0]sel,
output reg y
 );
 
 always@(*)
 begin
 case(sel)
 2'b00:y=d[0];
 2'b01:y=d[1];
 2'b10:y=d[2];
 2'b11:y=d[3];
 endcase
 end
 

endmodule
