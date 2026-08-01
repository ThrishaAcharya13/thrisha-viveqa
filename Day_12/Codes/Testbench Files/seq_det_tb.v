`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.07.2026 11:27:09
// Design Name: 
// Module Name: seq_det_tb
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

module seq_det_tb();
reg clk,rst;
reg ip;
wire op;

sequence_detector dut(clk,rst,ip,op);

always #5 clk=~clk;

initial begin
clk=1'b0;
rst=1'b0;
ip=1'b0;
#12 rst=1'b1;
#12 rst=1'b0;

#12 ip=1'b1;
#12 ip=1'b0;
#12 ip=1'b1;
#12 ip=1'b0;
#12 ip=1'b1;
#12 ip=1'b1;
#12 ip=1'b1;
#12 ip=1'b0;
#12 ip=1'b1;
#12 ip=1'b0;
#12 ip=1'b1;
#12 ip=1'b1;
#12 ip=1'b1;
#12 ip=1'b0;
#12 ip=1'b1;
#12 ip=1'b1;
#12 ip=1'b1;
#12 ip=1'b0;
#12 ip=1'b1;
#12 ip=1'b1;
#12 ip=1'b1;
#12 ip=1'b0;
#12 ip=1'b1;
#12 ip=1'b0;
#12 ip=1'b1;
#12 ip=1'b0;
#12 ip=1'b1;
#12 ip=1'b1;
#12 $finish;
end

endmodule

