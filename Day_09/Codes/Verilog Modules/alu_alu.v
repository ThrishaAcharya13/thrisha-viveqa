`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.07.2026 10:52:35
// Design Name: 
// Module Name: alu_alu
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
// Create Date: 07/01/2026 10:44:47 AM
// Design Name: 
// Module Name: ALU
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
module alu_alu(
    input  [7:0] sw,
    input  [15:0] btn,
    output reg [7:0] led
);

wire [3:0] A;
wire [3:0] B;

assign A = sw[3:0];
assign B = sw[7:4];

always @(*) begin

    led = 8'b00000000;

    if(btn[0])
        led = A + B;

    else if(btn[1])
        led = A - B;

    else if(btn[2])
        led = A & B;

    else if(btn[3])
        led = A | B;

    else if(btn[4])
        led = A << B;

    else if(btn[5])
        led = A >> B;

    else if(btn[6])
        led = A ^ B;

    else if(btn[7])
        led = ~A;

    else if(btn[8])
        led = A * B;

    else if(btn[9]) begin
        if(B == 0)
            led = 8'hFF;
        else
            led = A / B;
    end

    else if(btn[10])
        led = ~(A & B);

    else if(btn[11])
        led = A << 2;

    else if(btn[12])
        led = A >> 2;

    else if(btn[13])
        led = ~(A | B);

    else if(btn[14])
        led = A + 1;

    else if(btn[15])
        led = B + 1;

end

endmodule