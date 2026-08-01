`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/30/2026 03:52:55 PM
// Design Name: 
// Module Name: display_no
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


module display_no(button,led);
input [15:0]button;
output reg [3:0]led;

always @(*) begin
case(button)
16'd1: led=4'd0;  
16'd2: led=4'd1;
16'd4: led=4'd2;
16'd8: led=4'd3;
16'd16: led=4'd4;
16'd32 : led=4'd5;
16'd64 : led=4'd6;
16'd128: led=4'd7;
16'd256: led=4'd8;
16'd512: led=4'd9;
16'd1204: led=4'd10;
16'd2408: led=4'd11;
16'd4096: led=4'd12;
16'd8192: led=4'd13;
16'd16384: led=4'd14;
16'd32768: led=4'd15;
default: led=4'd0;
endcase
end
endmodule
