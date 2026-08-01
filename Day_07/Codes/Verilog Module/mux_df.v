`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.06.2026 12:12:44
// Design Name: 
// Module Name: mux_df
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


module mux_df(a,b,sel,y);
input a,b;
input sel;
output y;

assign y=(sel==1'b1)? b : a; //dataflow

endmodule
