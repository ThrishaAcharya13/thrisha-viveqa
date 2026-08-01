`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.07.2026 11:05:28
// Design Name: 
// Module Name: dff_glitch
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

module dff_glitch(clk,rst,D,Q,Qb);
input clk,rst;
input D;
output reg Q;
output Qb;


always @(posedge clk)begin
  if(rst)begin
   Q<=1'b0;
   
   //Qb<=~Q; this is for the wrong
  end else begin
   Q <=D;
  
   //Qb <=~Q; this is for the wrong
  end
end
assign Qb=~Q;
endmodule
