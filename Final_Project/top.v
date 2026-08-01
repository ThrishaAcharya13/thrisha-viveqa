`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// FPGA Implementation of a Simplified Lattice-Based Post-Quantum Cryptographic
// Encryption/Decryption Engine with NTT Accelerator
//
// UART input version: a PC GUI sends one byte -> uart_rx decodes it -> the
// full byte becomes the message (one bit per ciphertext coefficient) -> a
// start pulse is generated automatically and held until crypto_engine
// reports done.
//
// UPDATED: encryption/decryption now genuinely go through the NTT
// accelerator (NTT -> pointwise multiply -> INTT), via crypto_engine.v,
// instead of the placeholder scalar multiply the earlier version used.
// See crypto_engine.v for the full explanation and bank map.
//////////////////////////////////////////////////////////////////////////////////

module top(

    input clk,
    input key0_n,    // keypad key '0' (A13), active-low, used as RESET
    input key1_n,    // keypad key '1' (F5),  active-low, used as MODE
    input rx,        // serial input pin, routed via PMOD to an external USB-serial adapter

    output tx,       // serial output pin -> external USB-serial adapter's RX line

    output reg [7:0] led,

    output lcd_rs,
    output lcd_rw,
    output lcd_e,
    output [7:0] lcd_d

);

// Board's keypad keys are active-low (10K pull-up, press pulls to GND).
// Invert here so the rest of this module can keep using active-high
// rst/mode, unchanged from before.
wire rst  = ~key0_n;
wire mode = ~key1_n;

//--------------------------------------------------
// UART Receiver
//--------------------------------------------------

wire [7:0] uart_data;
wire       rx_done;

uart_rx #(
    .CLK_FREQ  (24_000_000),    // AT-STLN-ARTIX7-001 on-board oscillator is 24 MHz
    .BAUD_RATE (9600)           // must match the PC GUI's baud rate
) UART_RX (
    .clk      (clk),
    .rst      (rst),
    .rx       (rx),
    .data_out (uart_data),
    .rx_done  (rx_done)
);

//--------------------------------------------------
// Latch the received byte as the message. Every bit is now used --
// bit i is encrypted into ciphertext coefficient i (see crypto_engine.v's
// full-byte encoding note), matching real Kyber's per-coefficient bit
// encoding, generalized to this engine's whole message at once.
//--------------------------------------------------

reg [7:0] message_reg;

always @(posedge clk or posedge rst) begin
    if (rst)
        message_reg <= 8'd0;
    else if (rx_done)
        message_reg <= uart_data;
end

//--------------------------------------------------
// Auto-generate 'start' the same way a held-then-released button would:
// go high when a new byte lands, drop low once the engine reports done.
//--------------------------------------------------

reg start_reg;

always @(posedge clk or posedge rst) begin
    if (rst)
        start_reg <= 1'b0;
    else if (rx_done)
        start_reg <= 1'b1;
    else if (done)
        start_reg <= 1'b0;
end

wire start = start_reg;

//--------------------------------------------------
// Crypto Engine (NTT-accelerated encrypt + decrypt)
//--------------------------------------------------

wire done;
wire keygen_done;

wire [4:0] cipherU;
wire [4:0] cipherV;
wire [7:0] recovered_message;

crypto_engine ENGINE (

    .clk(clk),
    .rst(rst),
    .start(start),
    .message_in(message_reg),

    .done(done),
    .keygen_done(keygen_done),

    .cipherU(cipherU),
    .cipherV(cipherV),
    .recovered_message(recovered_message),

    .u_full(u_full),
    .v_full(v_full)

);

//--------------------------------------------------
// 16x2 LCD (live text readout, always redrawing)
//--------------------------------------------------

lcd_display LCD (
    .clk(clk),
    .rst(rst),

    .message_in(message_reg),
    .cipherU(cipherU),
    .cipherV(cipherV),
    .recovered(recovered_message),
    .keygen_done(keygen_done),
    .done(done),

    .lcd_rs(lcd_rs),
    .lcd_rw(lcd_rw),
    .lcd_e(lcd_e),
    .lcd_data(lcd_d)
);

//--------------------------------------------------
// UART TX: dump all 8 coefficients of U_TIME and V_TIME, plus the
// recovered message, to the PC after every completed run.
//
// Frame format sent to the PC, once per completed message:
//   0xFF                       -- sync byte (data bytes are always 0-16,
//                                  so 0xFF can never be mistaken for one)
//   u[0], u[1], ..., u[7]      -- 8 bytes, zero-extended from 5 bits
//   v[0], v[1], ..., v[7]      -- 8 bytes, zero-extended from 5 bits
//   recovered_message          -- 1 byte, the decoded plaintext byte (bit i
//                                  decoded from ciphertext coefficient i --
//                                  see crypto_engine.v's encoding note)
// 18 bytes total per frame.
//
// u_full/v_full come straight from crypto_engine's shadow registers
// (captured at write time -- see crypto_engine.v), so there's no extra
// bank_mem read port or address sweep involved here at all.
//--------------------------------------------------

wire [39:0] u_full;
wire [39:0] v_full;
wire        tx_busy;

reg  done_d;
always @(posedge clk or posedge rst) begin
    if (rst) done_d <= 1'b0;
    else     done_d <= done;
end
wire done_rise = done && !done_d;   // one-cycle pulse when a run finishes

localparam RO_IDLE = 2'd0, RO_PRE = 2'd1, RO_PRE_WAIT = 2'd2, RO_SEND = 2'd3;

reg [1:0] ro_state;
reg [4:0] ro_idx;         // 0..16 : which of the 17 bytes (u+v+out) we're on
reg [7:0] tx_data_r;
reg       tx_start_r;

// Byte currently selected by ro_idx: u[0..7], then v[0..7], then OUT.
wire [7:0] cur_byte_val =
    (ro_idx < 5'd8)  ? {3'b000, u_full[ro_idx*5 +: 5]}          :
    (ro_idx < 5'd16) ? {3'b000, v_full[(ro_idx - 5'd8)*5 +: 5]} :
                       recovered_message;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        ro_state   <= RO_IDLE;
        ro_idx     <= 5'd0;
        tx_start_r <= 1'b0;
    end else begin
        tx_start_r <= 1'b0;   // default: only pulses in RO_PRE/RO_SEND below

        case (ro_state)

            RO_IDLE: begin
                if (done_rise) begin
                    ro_idx   <= 5'd0;
                    ro_state <= RO_PRE;
                end
            end

            RO_PRE: begin
                if (!tx_busy) begin
                    tx_data_r  <= 8'hFF;      // sync byte
                    tx_start_r <= 1'b1;
                    ro_state   <= RO_PRE_WAIT;
                end
            end

            RO_PRE_WAIT: begin
                if (tx_busy)
                    ro_state <= RO_SEND;
            end

            RO_SEND: begin
                if (!tx_busy) begin
                    tx_data_r  <= cur_byte_val;
                    tx_start_r <= 1'b1;
                    if (ro_idx == 5'd16)
                        ro_state <= RO_IDLE;
                    else begin
                        ro_idx   <= ro_idx + 1'b1;
                        ro_state <= RO_PRE_WAIT;   // reuse: just waits for tx_busy then loops back here
                    end
                end
            end

            default: ro_state <= RO_IDLE;

        endcase
    end
end

uart_tx #(
    .CLK_FREQ  (24_000_000),
    .BAUD_RATE (9600)
) UART_TX (
    .clk      (clk),
    .rst      (rst),
    .tx_start (tx_start_r),
    .tx_data  (tx_data_r),
    .tx       (tx),
    .tx_busy  (tx_busy)
);

//--------------------------------------------------
// MODE Button (edge detect)
//--------------------------------------------------

reg [1:0] display_mode;
reg mode_d;

always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        mode_d <= 1'b0;
        display_mode <= 2'd0;
    end
    else
    begin
        mode_d <= mode;

        if(mode && !mode_d)
            display_mode <= display_mode + 1'b1;
    end
end

//--------------------------------------------------
// LED Display Modes
//--------------------------------------------------

always @(*)
begin

    case(display_mode)

        // Mode 0 : Cipher U (coefficient 0 of the u polynomial)
        2'd0:
            led = {3'b000, cipherU};

        // Mode 1 : Cipher V (coefficient 0 of the v polynomial)
        2'd1:
            led = {3'b000, cipherV};

        // Mode 2 : Recovered Message (full decoded byte)
        2'd2:
            led = recovered_message;

        // Mode 3 : Status
        2'd3:
            led = {6'b000000, keygen_done, done};

        default:
            led = 8'b00000000;

    endcase

end

endmodule
