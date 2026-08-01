`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/30/2026 05:03:06 PM
// Design Name: 
// Module Name: password
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


module password(pass,conf,buzz,led);
input [7:0]pass;
input conf;
output reg buzz;
output reg [7:0]led;

always @(posedge conf) begin
case(pass)
8'b10101010, 8'b11000011, 8'b11110000: begin
                led  <= 8'b1111_1111; // All 8 LEDs glow if correct
                buzz <= 1'b0;          // Buzzer stays off
            end
default: begin
                led  <= 8'b0000_0000; // LEDs stay off if incorrect
                buzz <= 1'b1;          // Sound the buzzer
            end
        endcase
    end

endmodule
