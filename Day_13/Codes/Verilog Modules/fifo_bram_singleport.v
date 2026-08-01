`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.07.2026 10:49:30
// Design Name: 
// Module Name: fifo_bram_singleport
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

//this is single port block ram, not fifo, mistake in the file name, just singleport bram
module fifo_bram_singleport(clk,addr,wr_en,write_data,read_data);
input clk;
input [31:0]addr;
input wr_en;
input [31:0]write_data;
output reg [31:0]read_data;

reg [31:0]mem[0:63]; //creating a memory that has 64 locations, and 32 bits,

always@(posedge clk)
if(wr_en) mem[addr]<=write_data;
else
read_data<=mem[addr];


endmodule
