`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.07.2026 10:58:32
// Design Name: 
// Module Name: sequence_detector
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


module sequence_detector(clk,rst,ip,op);
input clk,ip,rst;
output reg op;
wire d1,q0,qb0,q1,qb1;

//not n1(ipb,ip);

dff d_ff0(clk,rst,~ip,q0,qb0);
assign d1=ip&q0;
dff d_ff1(clk,rst,d1,q1,qb1);

always@(posedge clk)begin
if(rst)op<=1'b0;
else op <=ip&q1;
end
endmodule
