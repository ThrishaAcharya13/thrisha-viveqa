`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.06.2026 17:01:25
// Design Name: 
// Module Name: universal_ff
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

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.06.2026 16:51:14
// Design Name: 
// Module Name: d_ff
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


module universal_ff(
    input clk,
    input rst,
    input A,
    input B,
    input [1:0]mode,
    output reg Q,
    output Qbar
);

reg D;

always @(posedge clk) begin
    if (rst)
        Q <= 1'b0;
    else
        Q <= D;
end

assign Qbar = ~Q;

always @(*) begin
    case(mode)

        // 00 : D Flip-Flop
        2'b00:
            D = A;

        // 01 : T Flip-Flop
        2'b01:
            D = A ? ~Q : Q;

        // 10 : SR Flip-Flop
        2'b10:
            case({A,B})
                2'b00: D = Q;      // Hold
                2'b01: D = 1'b0;   // Reset
                2'b10: D = 1'b1;   // Set
                2'b11: D = Q;      // Invalid (Hold)
            endcase

        // 11 : JK Flip-Flop
        2'b11:
            case({A,B})
                2'b00: D = Q;      // Hold
                2'b01: D = 1'b0;   // Reset
                2'b10: D = 1'b1;   // Set
                2'b11: D = ~Q;     // Toggle
            endcase

    endcase
end

endmodule
