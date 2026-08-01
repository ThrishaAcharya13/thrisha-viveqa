`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.06.2026 12:49:20
// Design Name: 
// Module Name: mux4to1_tb
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


module mux4to1_tb();
wire [3:0]d;
wire [1:0]sel;
reg y;
mux4to1 dut (
.d(d),
.sel(sel),
.y(y));

initial begin
integer i;
for(i=0;i<=64;i=i+1) begin
{d,sel,y}=i;
#5;
end
#5; $finish;
end


endmodule
