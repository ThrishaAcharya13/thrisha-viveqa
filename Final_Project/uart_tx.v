`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module : uart_tx
//
// UART Transmitter (8-N-1: 8 data bits, no parity, 1 stop bit).
// Mirrors uart_rx.v's parameters so the two share the same CLK_FREQ/BAUD_RATE.
//
// Usage: pulse tx_start for exactly 1 clock while tx_busy is low, with
// tx_data held valid on that same cycle. tx_busy goes high immediately and
// stays high until the stop bit has been shifted out.
//
// CLK_FREQ  : board clock frequency in Hz (e.g. 24_000_000)
// BAUD_RATE : serial baud rate (must match the PC GUI, e.g. 9600)
//////////////////////////////////////////////////////////////////////////////////

module uart_tx #(
    parameter CLK_FREQ  = 24_000_000,
    parameter BAUD_RATE = 9600
)(
    input  wire       clk,
    input  wire       rst,

    input  wire        tx_start,   // 1-clk pulse: begin sending tx_data
    input  wire [7:0]  tx_data,

    output reg         tx,         // serial output, idles high
    output reg         tx_busy     // high while a byte is in flight
);

localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

localparam IDLE  = 2'd0;
localparam START = 2'd1;
localparam DATA  = 2'd2;
localparam STOP  = 2'd3;

reg [1:0]  state;
reg [15:0] clk_count;
reg [2:0]  bit_index;
reg [7:0]  tx_shift;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state     <= IDLE;
        clk_count <= 16'd0;
        bit_index <= 3'd0;
        tx        <= 1'b1;   // line idles high
        tx_busy   <= 1'b0;
    end else begin
        case (state)

            IDLE: begin
                tx      <= 1'b1;
                tx_busy <= 1'b0;
                clk_count <= 16'd0;
                bit_index <= 3'd0;
                if (tx_start) begin
                    tx_shift <= tx_data;
                    tx_busy  <= 1'b1;
                    tx       <= 1'b0;      // start bit
                    state    <= START;
                end
            end

            START: begin
                if (clk_count < CLKS_PER_BIT-1) begin
                    clk_count <= clk_count + 1'b1;
                end else begin
                    clk_count <= 16'd0;
                    tx        <= tx_shift[0];
                    state     <= DATA;
                end
            end

            DATA: begin
                if (clk_count < CLKS_PER_BIT-1) begin
                    clk_count <= clk_count + 1'b1;
                end else begin
                    clk_count <= 16'd0;
                    if (bit_index < 3'd7) begin
                        bit_index <= bit_index + 1'b1;
                        tx        <= tx_shift[bit_index + 1'b1];
                    end else begin
                        bit_index <= 3'd0;
                        tx        <= 1'b1;   // stop bit
                        state     <= STOP;
                    end
                end
            end

            STOP: begin
                if (clk_count < CLKS_PER_BIT-1) begin
                    clk_count <= clk_count + 1'b1;
                end else begin
                    clk_count <= 16'd0;
                    tx_busy   <= 1'b0;
                    state     <= IDLE;
                end
            end

            default: state <= IDLE;

        endcase
    end
end

endmodule
