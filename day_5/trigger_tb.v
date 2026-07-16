`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.06.2026 16:51:30
// Design Name: 
// Module Name: trigger_tb
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


module trigger_tb;

reg clk;
reg d;
reg [1:0] sel;
wire q;

trigger uut(
    .clk(clk),
    .d(d),
    .sel(sel),
    .q(q)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    d = 0;
    sel = 2'b00;      // Positive edge
    #12 d = 1;
    #20 d = 0;

    sel = 2'b01;      // Negative edge
    #20 d = 1;
    #20 d = 0;

    sel = 2'b10;      // Both edge
    #20 d = 1;
    #20 d = 0;

    #20 $finish;
end

initial begin
    $monitor("Time=%0t clk=%b d=%b sel=%b q=%b",
             $time, clk, d, sel, q);
end

endmodule
