`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.07.2026 12:24:25
// Design Name: 
// Module Name: fifo
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

module fifo(clk,rst,wr_en,rd_en,write_data,read_data);//full,empty);
input clk,rst;
input wr_en,rd_en;
input [7:0]write_data;
output reg[7:0]read_data;
//output full,empty;

wire full,empty;

reg [7:0]mem[0:15];
reg [4:0]wr_ptr,rd_ptr;


 wire pos_det_wr_en;
 wire pos_det_rd_en;
 reg wr_en_d;
 reg rd_en_d;

assign empty= wr_ptr==rd_ptr;
assign full= (wr_ptr[4]!=rd_ptr[4]) && (wr_ptr[3:0]==rd_ptr[3:0]);

assign pos_det_wr_en= ~wr_en_d & wr_en; 
assign pos_det_rd_en= ~rd_en_d & rd_en;


ila_0 ila (
	.clk(clk), // input wire clk


	.probe0(full), // input wire [0:0]  probe0  
	.probe1(empty) // input wire [0:0]  probe1
);

 //posedge detector
 always@(posedge clk)begin
 if(rst)wr_en_d <=1'b0;
 else wr_en_d <=wr_en;
 end
 
  always@(posedge clk)begin
  if(rst)rd_en_d <=1'b0;
  else rd_en_d <=rd_en;
 end

//Write Logic
always@(posedge clk)begin
 if(rst)begin
   wr_ptr <=5'b0;
 end else if(pos_det_wr_en && !full)begin
   mem[wr_ptr[3:0]] <= write_data;
   wr_ptr <=wr_ptr+1;
 end
end

//Read Logic
always@(posedge clk)begin
 if(rst)begin
   rd_ptr <=5'b0;
   read_data <=8'b0;
 end else if (pos_det_rd_en && !empty)begin
   read_data <= mem[rd_ptr[3:0]];
   rd_ptr <= rd_ptr+1;
 end
 end
endmodule

