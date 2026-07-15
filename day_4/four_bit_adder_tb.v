`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.06.2026 13:59:56
// Design Name: 
// Module Name: four_bit_adder_tb
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


module four_bit_adder_tb();
reg [3:0]a,b;
wire [3:0]sum;
wire carry;

four_bit_adder dut(a,b,sum,carry);
initial begin
a=4'd1;b=4'd2; #10;
a=4'd5;b=4'd5; #10;
a=4'd10;b=4'd2; #10;
a=4'd5;b=4'd9; #10;
a=4'd15;b=4'd15; #10;
$finish;
end
initial begin
$monitor("Sum of a=%d and b=%d is %d and carry is %b",a,b,sum,carry);
end
endmodule