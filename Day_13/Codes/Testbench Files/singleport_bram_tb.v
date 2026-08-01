`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.07.2026 11:05:43
// Design Name: 
// Module Name: singleport_bram_tb
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

module singleport_bram_tb();
reg clk;
reg [31:0]addr;
reg wr_en;
reg [31:0]write_data;
wire [31:0]read_data;

fifo_bram_singleport dut (clk,addr,wr_en,write_data,read_data);

always #5 clk=~clk;

initial begin
clk=1'b0;
wr_en=1'b0;
addr=32'd0;
write_data=32'd0;
#12 wr_en=1'b1;
#12;
addr=32'd1;
write_data=32'd1;
#12;
addr=32'd2;
write_data=32'd2;
#12;
addr=32'd3;
write_data=32'd3;
#12;
addr=32'd4;
write_data=32'd4;
#12;
addr=32'd5;
write_data=32'd5;
#12;
addr=32'd6;
write_data=32'd6;
#12;
addr=32'd7;
write_data=32'd7;
#12;
addr=32'd7;
write_data=32'd7;
#12;
addr=32'd8;
write_data=32'd8;
#12;
addr=32'd9;
write_data=32'd9;
#12;
addr=32'd10;
write_data=32'd10;
#12;
addr=32'd11;
write_data=32'd11;
#12;
addr=32'd12;
write_data=32'd12;
#12 wr_en=1'b0;
addr=32'd0;
#12 addr=32'd1;
#12 addr=32'd2;
#12 addr=32'd3;
#12 addr=32'd4;
#12 addr=32'd5;
#12 addr=32'd6;
#12 addr=32'd7;
#12 addr=32'd8;
#12 addr=32'd9;
#12 addr=32'd10;
#12 addr=32'd11;
#12 addr=32'd12;
#12 $finish;
end
endmodule

