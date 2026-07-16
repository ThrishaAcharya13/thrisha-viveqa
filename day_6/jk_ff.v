`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.06.2026 15:29:42
// Design Name: 
// Module Name: jk_ff
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


module jk_ff(clk,rst,J,K,Q,Qb);
input clk,rst;
input J,K;
output reg Q;
output Qb;
always @(posedge clk)begin
if(rst)
    Q<=1'b0;
else begin
case({J,K})
2'b00:Q<=Q;
2'b01:Q<=1'b0;
2'b10:Q<=1'b1;
2'b11:Q<=~Q;
endcase
end
end
assign Qb=~Q;

endmodule