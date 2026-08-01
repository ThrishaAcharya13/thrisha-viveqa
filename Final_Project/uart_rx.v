`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.07.2026 18:10:25
// Design Name: 
// Module Name: uart_rx
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

//////////////////////////////////////////////////////////////////////////////////
// UART Receiver (8-N-1: 8 data bits, no parity, 1 stop bit)
//
// CLK_FREQ  : board clock frequency in Hz (e.g. 100_000_000 for a 100 MHz clock)
// BAUD_RATE : serial baud rate (must match the PC GUI, e.g. 9600)
//////////////////////////////////////////////////////////////////////////////////

module uart_rx #(
    parameter CLK_FREQ  = 100_000_000,
    parameter BAUD_RATE = 9600
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       rx,          // serial line in, from PC's TX pin

    output reg  [7:0] data_out,    // last received byte
    output reg        rx_done      // 1 clk-cycle pulse when a new byte lands
);

localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

localparam IDLE     = 3'd0;
localparam START    = 3'd1;
localparam DATA     = 3'd2;
localparam STOP     = 3'd3;
localparam CLEANUP  = 3'd4;

reg [2:0]  state     = IDLE;
reg [15:0] clk_count  = 0;
reg [2:0]  bit_index  = 0;
reg [7:0]  rx_shift   = 0;

//--------------------------------------------------
// Double-flop synchronizer (rx is an async external pin)
//--------------------------------------------------
reg rx_ff1, rx_ff2;
always @(posedge clk) begin
    rx_ff1 <= rx;
    rx_ff2 <= rx_ff1;
end
wire rx_sync = rx_ff2;

//--------------------------------------------------
// Receive FSM
//--------------------------------------------------
always @(posedge clk or posedge rst) begin
    if (rst) begin
        state     <= IDLE;
        clk_count <= 0;
        bit_index <= 0;
        rx_done   <= 1'b0;
        data_out  <= 8'd0;
    end else begin

        rx_done <= 1'b0; // default; only pulses in CLEANUP

        case (state)

            IDLE: begin
                clk_count <= 0;
                bit_index <= 0;
                if (rx_sync == 1'b0)          // line dropped low -> possible start bit
                    state <= START;
            end

            START: begin
                // sample mid-bit to confirm it's a real start bit, not noise
                if (clk_count == (CLKS_PER_BIT-1)/2) begin
                    if (rx_sync == 1'b0) begin
                        clk_count <= 0;
                        state     <= DATA;
                    end else begin
                        state <= IDLE;         // was a glitch
                    end
                end else begin
                    clk_count <= clk_count + 1'b1;
                end
            end

            DATA: begin
                if (clk_count < CLKS_PER_BIT-1) begin
                    clk_count <= clk_count + 1'b1;
                end else begin
                    clk_count <= 0;
                    rx_shift[bit_index] <= rx_sync;
                    if (bit_index < 7) begin
                        bit_index <= bit_index + 1'b1;
                    end else begin
                        bit_index <= 0;
                        state     <= STOP;
                    end
                end
            end

            STOP: begin
                if (clk_count < CLKS_PER_BIT-1) begin
                    clk_count <= clk_count + 1'b1;
                end else begin
                    data_out  <= rx_shift;
                    rx_done   <= 1'b1;         // byte is ready this cycle
                    clk_count <= 0;
                    state     <= CLEANUP;
                end
            end

            CLEANUP: begin
                state <= IDLE;
            end

            default: state <= IDLE;

        endcase
    end
end

endmodule

