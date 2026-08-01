`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.07.2026 11:29:05
// Design Name: 
// Module Name: dff_glitch_tb
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


module dff_glitch_tb();
reg clk,rst;
reg D;
wire Q,Qb;

dff_glitch dut(clk,rst,D,Q,Qb);

always #5 clk=~clk;

initial begin
clk=1'b0;
rst=1'b0;
D=1'b0;
#12 rst=1'b1;
#12 rst=1'b0;
#12 D=1'b1;
#12 D=1'b0;
#12 D=1'b1;
#50 D=1'b0;
#10 $finish;
end
endmodule

