`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.07.2026 23:16:31
// Design Name: 
// Module Name: twiddle_rom
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


module twiddle_rom(
    input  [2:0] addr,
    output reg [4:0] w
);

always @(*) begin
    case(addr)
        3'd0: w = 5'd1;
        3'd1: w = 5'd2;
        3'd2: w = 5'd4;
        3'd3: w = 5'd8;
        3'd4: w = 5'd16;
        3'd5: w = 5'd15;
        3'd6: w = 5'd13;
        3'd7: w = 5'd9;
        default: w = 5'd0;
    endcase
end

endmodule