`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.07.2026 10:22:44
// Design Name: 
// Module Name: sevensegment_tb
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

module sevensegment_tb();

reg b3, b2, b1, b0;
wire a, b, c, d, e, f, g, h;

// Instantiate the DUT
sevensegment dut(
    .b3(b3),
    .b2(b2),
    .b1(b1),
    .b0(b0),
    .a(a),
    .b(b),
    .c(c),
    .d(d),
    .e(e),
    .f(f),
    .g(g),
    .h(h)
);

initial begin
    $display("Time\tInput\t\tOutput(a b c d e f g h)");
    $monitor("%0t\t%b%b%b%b\t\t%b %b %b %b %b %b %b %b",
             $time, b3, b2, b1, b0,
             a, b, c, d, e, f, g, h);

    // Apply all possible inputs
    {b3,b2,b1,b0} = 4'b0000; #10;
    {b3,b2,b1,b0} = 4'b0001; #10;
    {b3,b2,b1,b0} = 4'b0010; #10;
    {b3,b2,b1,b0} = 4'b0011; #10;
    {b3,b2,b1,b0} = 4'b0100; #10;
    {b3,b2,b1,b0} = 4'b0101; #10;
    {b3,b2,b1,b0} = 4'b0110; #10;
    {b3,b2,b1,b0} = 4'b0111; #10;
    {b3,b2,b1,b0} = 4'b1000; #10;
    {b3,b2,b1,b0} = 4'b1001; #10;
    {b3,b2,b1,b0} = 4'b1010; #10;
    {b3,b2,b1,b0} = 4'b1011; #10;
    {b3,b2,b1,b0} = 4'b1100; #10;
    {b3,b2,b1,b0} = 4'b1101; #10;
    {b3,b2,b1,b0} = 4'b1110; #10;
    {b3,b2,b1,b0} = 4'b1111; #10;

    $finish;
end

endmodule
