`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.06.2026 16:51:20
// Design Name: 
// Module Name: full_adder
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


module full_adder(a,b,cin,sum,cout);
input a,b,cin;
output sum,cout;
wire s1,c1,c2;
half_adder HA1(.a(a),.b(b),.sum(sum),.carry(c1));
half_adder HA2(.a(s1),.b(cin),.sum(sum),.carry(c2));
assign cout=c1|c2;
endmodule
