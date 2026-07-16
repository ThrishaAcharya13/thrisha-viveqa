`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.06.2026 17:05:56
// Design Name: 
// Module Name: d_ff_tb
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



module universal_ff_tb;

    // Inputs
    reg clk;
    reg rst;
    reg A;
    reg B;
    reg [1:0] mode;

    // Outputs
    wire Q;
    wire Qbar;

    // Instantiate the DUT
    universal_ff uut (
        .clk(clk),
        .rst(rst),
        .A(A),
        .B(B),
        .mode(mode),
        .Q(Q),
        .Qbar(Qbar)
    );

    // Clock Generation (10 ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test Stimulus
    initial begin

        // Initialize
        rst  = 1;
        A    = 0;
        B    = 0;
        mode = 2'b00;

        #12;
        rst = 0;

        //=========================
        // D Flip-Flop (mode = 00)
        //=========================
        $display("\n---- D Flip-Flop ----");

        mode = 2'b00;

        A = 0; #10;
        A = 1; #10;
        A = 0; #10;
        A = 1; #10;

        //=========================
        // T Flip-Flop (mode = 01)
        //=========================
        $display("\n---- T Flip-Flop ----");

        mode = 2'b01;

        A = 0; #10;   // Hold
        A = 1; #10;   // Toggle
        A = 1; #10;   // Toggle
        A = 0; #10;   // Hold

        //=========================
        // SR Flip-Flop (mode = 10)
        //=========================
        $display("\n---- SR Flip-Flop ----");

        mode = 2'b10;

        A=1; B=0; #10;    // Set
        A=0; B=0; #10;    // Hold
        A=0; B=1; #10;    // Reset
        A=0; B=0; #10;    // Hold
        A=1; B=1; #10;    // Invalid/Hold

        //=========================
        // JK Flip-Flop (mode = 11)
        //=========================
        $display("\n---- JK Flip-Flop ----");

        mode = 2'b11;

        A=1; B=0; #10;    // Set
        A=0; B=0; #10;    // Hold
        A=0; B=1; #10;    // Reset
        A=1; B=1; #10;    // Toggle
        A=1; B=1; #10;    // Toggle
        A=0; B=0; #10;    // Hold

        $finish;

    end

    // Monitor Outputs
    initial begin
        $monitor("Time=%0t | Mode=%b | A=%b B=%b | Q=%b Qbar=%b",
                 $time, mode, A, B, Q, Qbar);
    end

endmodule
