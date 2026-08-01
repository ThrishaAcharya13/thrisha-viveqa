`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.07.2026 14:44:56
// Design Name: 
// Module Name: uart_rx_tb
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

module uart_rx_tb();
reg clk, rst;
reg tx_start;
reg [7:0] tx_data;

wire tx, tx_busy, tx_done;
wire [7:0] rx_data;
wire rx_done, rx_err;

// Connect the transmitter serial output (tx) to the receiver serial input (rx)
wire rx = tx;

// Instantiate Transmitter
uart dut_tx(
    .clk(clk),
    .rst(rst),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx(tx),
    .tx_busy(tx_busy),
    .tx_done(tx_done)
);

// Instantiate Receiver
uart_rx dut_rx(
    .clk(clk),
    .rst(rst),
    .rx(rx),
    .rx_data(rx_data),
    .rx_done(rx_done),
    .rx_err(rx_err)
);

always #20.8 clk = ~clk;

initial begin
clk = 1'b0;
rst = 1'b0;
tx_start = 1'b0;
tx_data = 8'b0;
#40 rst = 1'b1;
#40 rst = 1'b0;
#40 tx_start = 1'b1; tx_data = 8'hAB;
#40 tx_start = 1'b0; // Deassert tx_start so it only transmits once

#2000000; // Run long enough (2 ms) for the loopback to complete
$stop;
end

endmodule
