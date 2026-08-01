`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.07.2026 12:59:06
// Design Name: 
// Module Name: vending_machine_tb
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


module vending_machine_tb();
reg clk,rst;
reg [1:0]coin;
wire d,c;

vending_machine dut(clk,rst,coin,d,c);

always #5clk=~clk;

initial begin
clk=1'b0;
rst=1'b0;
coin=2'd0;

#12 rst=1'b1;
#12 rst=1'b0;
#12 coin=2'd1;
#12 coin=2'd2;
#12 coin=2'd2;
#12 coin=2'd2;
#12 coin=2'd2;
#12 coin=2'd2;
#12 coin=2'd1;
#12 coin=2'd2;
#12 coin=2'd1;
#12 coin=2'd2;
#12 coin=2'd1;
#12 coin=2'd2;
#12 coin=2'd1;
#12 coin=2'd1;
#12 coin=2'd1;
#12 coin=2'd1;
#12 coin=2'd1;
#12 coin=2'd1;
#12 coin=2'd1;
#12 coin=2'd2;
#12 coin=2'd2;
#12 coin=2'd1;
#12 coin=2'd1;
#12 coin=2'd1;
#12 coin=2'd1;
#12 coin=2'd2;
#12 coin=2'd1;
#12 coin=2'd1;
#12 coin=2'd1;
#12 coin=2'd1;
#12 coin=2'd1;
#12 coin=2'd2;
#12 coin=2'd2;
#12 coin=2'd1;
#12 coin=2'd1;
#12 coin=2'd2;
#12 coin=2'd1;
#12 coin=2'd1;
#12 coin=2'd2;
#12 coin=2'd1;

#12 $finish;
end
endmodule
