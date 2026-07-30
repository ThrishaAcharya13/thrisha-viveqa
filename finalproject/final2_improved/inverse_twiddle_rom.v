`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.07.2026 10:31:46
// Design Name: 
// Module Name: inverse_twiddle_rom
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




module inverse_twiddle_rom(

    input [2:0] addr,
    output reg [4:0] w

);

// Inverse twiddle factors = (g^-1)^i mod 17, where g = 2 is the
// primitive 8th root of unity used by twiddle_rom.v (g^-1 = 9 mod 17).
// Only indices 0-3 are ever used (see twiddle_index.v), the rest are
// kept populated for safety.
// FIX: the previous version had indices 1 and 2 swapped
// (13 and 9 reversed), which silently produced an incorrect inverse
// transform. Correct sequence: 9^0=1, 9^1=9, 9^2=13, 9^3=15, 9^4=1 ...

always @(*)
begin

    case(addr)

        3'd0: w = 5'd1;
        3'd1: w = 5'd9;
        3'd2: w = 5'd13;
        3'd3: w = 5'd15;
        3'd4: w = 5'd1;
        3'd5: w = 5'd9;
        3'd6: w = 5'd13;
        3'd7: w = 5'd15;

        default: w = 5'd1;

    endcase

end

endmodule
