`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.06.2026 12:22:07
// Design Name: 
// Module Name: mux_tb
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


module mux_tb();
reg a,b,sel;
wire y;
mux_df dut(
.a(a),
.b(b),
.sel(sel),
.y(y));
integer i;
initial begin
for(i=0;i<=8;i=i+1) begin
{a,b,sel}=i;
#5;
end
#5; $finish;
end
endmodule
