`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.07.2026 10:51:42
// Design Name: 
// Module Name: tff
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


module tff(clk,rst,t,q,qb);
input clk,rst;
input t;
output reg q;
output qb;
always@(posedge clk) begin //if t is 0, it is hold state, output doesnt depend on q. if t is 1, op will toggle
if(rst) q<=1'b0;
else if(t) q<=~q;   //if t=1;
else q<=q;
end
assign qb=~q;

endmodule
