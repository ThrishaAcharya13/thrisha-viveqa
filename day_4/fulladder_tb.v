`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.06.2026 13:49:17
// Design Name: 
// Module Name: fulladder_tb
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


module fulladder_tb();
reg a,b,cin;
wire sum, carry;

fulladder dut(a,b,cin,sum,carry);
integer i;
initial begin
for(i=0;i<8;i=i+1) begin
{a,b,cin}=i; //integer is 32 bit, reg&wire is 1 bit,time is 32 bit
#5;
end
#5; $finish;
end
endmodule
