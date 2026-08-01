`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.07.2026 12:16:09
// Design Name: 
// Module Name: asyn_4bit_up_pos_tb
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


module asyn_4bit_up_pos_tb();
reg clk,rst;
wire [3:0]count;

async_4bit_up_pos dut(clk,rst,count);

always #5 clk=~clk;

initial begin
clk=1'b0;
rst=1'b0;
#12 rst=1'b1;
#12 rst=1'b0;

#500 $finish;  //one clk is 10, so around 50 clocks are visible, around 3 times count
end

endmodule
