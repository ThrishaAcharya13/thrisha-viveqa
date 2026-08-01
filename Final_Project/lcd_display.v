`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module : lcd_display
//
// Drives a 16x2 character LCD (HD44780-compatible, e.g. DS1WC1602A) in 8-bit
// mode. After the standard init sequence, continuously redraws two lines:
//
//   Line 1:  IN=xxx OUT=xxx
//   Line 2:  U=xx V=xx K?D?
//
// where IN is the raw message byte received over UART (0-255), OUT is the
// decrypted plaintext BYTE (bit i of OUT decoded from ciphertext
// coefficient i -- see crypto_engine.v's full-byte encoding note), U/V are
// coefficient 0 of the ciphertext's u/v polynomials, K is keygen_done and
// D is done (each shown as '1'/'0').
//
// The whole 2-line redraw is ~68 LCD-command ticks at the ~2.7 ms tick
// period below (~184 ms per full refresh) -- fast enough that a new
// message's result appears effectively instantly to a person watching,
// slow enough to respect HD44780 command timing without a busy-flag read.
//////////////////////////////////////////////////////////////////////////////////

module lcd_display(

    input clk,
    input rst,

    input [7:0] message_in,   // raw byte received over UART (0-255)
    input [4:0] cipherU,
    input [4:0] cipherV,
    input [7:0] recovered,
    input       keygen_done,
    input       done,

    output reg lcd_rs,
    output reg lcd_rw,
    output reg lcd_e,
    output reg [7:0] lcd_data

);

//====================================================
// Clock Divider (24 MHz -> ~366 Hz tick, i.e. ~2.7 ms/tick)
//====================================================

reg [15:0] clk_div;

always @(posedge clk)
begin
    if(rst)
        clk_div <= 0;
    else
        clk_div <= clk_div + 1;
end

wire tick = (clk_div == 16'd0);

//====================================================
// Decimal digit splitting -- IN/OUT are full bytes (0-255, 3 digits);
// U/V stay 0-16 (2 digits, unchanged) since they're still single
// ciphertext coefficients.
//====================================================

function [7:0] hundreds_ascii;
    input [7:0] v;
    begin
        hundreds_ascii = "0" + (v / 100);
    end
endfunction

function [7:0] tens_ascii;
    input [7:0] v;
    begin
        tens_ascii = "0" + ((v / 10) % 10);
    end
endfunction

function [7:0] ones_ascii;
    input [7:0] v;
    begin
        ones_ascii = "0" + (v % 10);
    end
endfunction

//====================================================
// Character lookup: position 0-15 = line 1, 16-31 = line 2
//====================================================

function [7:0] char_at;
    input [4:0] p;
    begin
        case (p)
            5'd0:  char_at = "I";
            5'd1:  char_at = "N";
            5'd2:  char_at = "=";
            5'd3:  char_at = hundreds_ascii(message_in);
            5'd4:  char_at = tens_ascii(message_in);
            5'd5:  char_at = ones_ascii(message_in);
            5'd6:  char_at = " ";
            5'd7:  char_at = "O";
            5'd8:  char_at = "U";
            5'd9:  char_at = "T";
            5'd10: char_at = "=";
            5'd11: char_at = hundreds_ascii(recovered);
            5'd12: char_at = tens_ascii(recovered);
            5'd13: char_at = ones_ascii(recovered);
            5'd14: char_at = " ";
            5'd15: char_at = " ";

            5'd16: char_at = "U";
            5'd17: char_at = "=";
            5'd18: char_at = tens_ascii(cipherU);
            5'd19: char_at = ones_ascii(cipherU);
            5'd20: char_at = " ";
            5'd21: char_at = "V";
            5'd22: char_at = "=";
            5'd23: char_at = tens_ascii(cipherV);
            5'd24: char_at = ones_ascii(cipherV);
            5'd25: char_at = " ";
            5'd26: char_at = "K";
            5'd27: char_at = keygen_done ? "1" : "0";
            5'd28: char_at = "D";
            5'd29: char_at = done ? "1" : "0";
            5'd30: char_at = " ";
            default: char_at = " ";
        endcase
    end
endfunction

//====================================================
// LCD FSM
//====================================================
// items:  0            = set DDRAM addr 0x00 (line 1 start)
//         1..16         = write line-1 chars 0..15
//         17            = set DDRAM addr 0x40 (line 2 start)
//         18..33        = write line-2 chars 0..15
// each item takes 2 ticks: tick0 = assert E with data/RS set, tick1 = deassert E

reg [7:0] state;      // 0-7 : power-up init sequence (unchanged from before)
reg [6:0] cnt2;        // 0-67 : redraw-loop counter (7 bits, up to 127)

wire [5:0] item_idx   = cnt2[6:1];   // 0..33
wire       tick_phase = cnt2[0];      // 0 = E high, 1 = E low

reg        item_rs;
reg [7:0]  item_data;

always @(*)
begin
    if (item_idx == 6'd0) begin
        item_rs   = 1'b0;
        item_data = 8'h80;                 // DDRAM addr 0 (line 1)
    end
    else if (item_idx <= 6'd16) begin
        item_rs   = 1'b1;
        item_data = char_at(item_idx - 6'd1);      // positions 0..15
    end
    else if (item_idx == 6'd17) begin
        item_rs   = 1'b0;
        item_data = 8'hC0;                 // DDRAM addr 0x40 (line 2)
    end
    else begin
        item_rs   = 1'b1;
        item_data = char_at(6'd16 + (item_idx - 6'd18)); // positions 16..31
    end
end

always @(posedge clk)
begin

if(rst)
begin

    state <= 0;
    cnt2  <= 0;

    lcd_rs <= 0;
    lcd_rw <= 0;
    lcd_e  <= 0;
    lcd_data <= 8'h00;

end
else if(tick)
begin

case(state)

0:
begin
    lcd_rs <= 0;
    lcd_rw <= 0;
    lcd_data <= 8'h38;      // 8-bit mode
    lcd_e <= 1;
    state <= 1;
end

1:
begin
    lcd_e <= 0;
    state <= 2;
end

2:
begin
    lcd_data <= 8'h0C;      // Display ON
    lcd_e <= 1;
    state <= 3;
end

3:
begin
    lcd_e <= 0;
    state <= 4;
end

4:
begin
    lcd_data <= 8'h01;      // Clear LCD
    lcd_e <= 1;
    state <= 5;
end

5:
begin
    lcd_e <= 0;
    state <= 6;
end

6:
begin
    lcd_data <= 8'h06;      // Entry mode
    lcd_e <= 1;
    state <= 7;
end

7:
begin
    lcd_e <= 0;
    cnt2  <= 0;
    state <= 8;
end

//----------------------------------------------------
// Continuous redraw loop
//----------------------------------------------------

8:
begin
    lcd_rs   <= item_rs;
    lcd_rw   <= 1'b0;
    lcd_data <= item_data;

    if (!tick_phase) begin
        lcd_e <= 1'b1;
        cnt2  <= cnt2 + 1'b1;
    end
    else begin
        lcd_e <= 1'b0;
        if (item_idx == 6'd33)
            cnt2 <= 7'd0;         // full redraw done, loop back to item 0
        else
            cnt2 <= cnt2 + 1'b1;
    end
end

default:
    state <= 0;

endcase

end

end

endmodule
