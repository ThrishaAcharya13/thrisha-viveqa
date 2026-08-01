`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.07.2026 12:05:15
// Design Name: 
// Module Name: async_4bit_up_pos
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


module async_4bit_up_pos(clk,rst,count);
input clk,rst;
output [3:0] count;
wire qb0,qb1,qb2,qb3;


tff t_ff0(clk,rst,1'b1,count[0],qb0);
tff t_ff1(qb0,rst,1'b1,count[1],qb1);
tff t_ff2(qb1,rst,1'b1,count[2],qb2);
tff t_ff3(qb2,rst,1'b1,count[3],qb3);
endmodule
