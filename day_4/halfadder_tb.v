`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.06.2026 13:39:26
// Design Name: 
// Module Name: halfadder_tb
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


module halfadder_tb();
reg a,b;
wire sum,carry;
halfadder dut(.a(a),.b(b),.sum(sum),.carry(carry)); //half_adder dut(a,b,sum,carry)
initial begin
a=1'b0;b=1'b0;
#10;
a=1'b0;b=1'b1;
#10;
a=1'b1;b=1'b0;
#10;
a=1'b1;b=1'b1;
#10 $finish;
end
endmodule
