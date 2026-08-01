`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.07.2026 12:40:20
// Design Name: 
// Module Name: vending_machine
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

//this is moore based
module vending_machine(clk,rst,coin,d,c );
input clk,rst;
input [1:0]coin;
output reg d,c;
localparam s0=3'b000,s1=3'b001,s2=3'b010,s3=3'b011,s4=3'b100;  //state encoding
//create register to hold current state and next state
reg [2:0]state,next_state;
//current state logic
always@(posedge clk)begin
if(rst)state<=s0;
else
state<=next_state;
end

//combinational next state logic
always@(*)begin
case(state)
s0:begin
d=1'b0;c=1'b0;
if(coin==2'b01)next_state=s1;
else if(coin==2'b10)next_state=s2;
else next_state=s0;
end

s1:begin
d=1'b0;c=1'b0;
if(coin==2'b01)next_state=s2;
else if(coin==2'b10)next_state=s3;
else next_state=s1;
end

s2:begin
d=1'b0;c=1'b0;
if(coin==2'b01)next_state=s3;
else if(coin==2'b10)next_state=s4;
else next_state=s2;
end

s3:begin
d=1'b1;c=1'b0;
next_state=s0;
end

s4:begin
d=1'b1;c=1'b1;
next_state=s0;
end

default:next_state=s0;
endcase
end
endmodule
