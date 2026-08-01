`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// tb_keygen_check.v
//
// Quick self-checking testbench for the LFSR-driven keygen change.
// Run this (Icarus: `iverilog -o sim tb_keygen_check.v crypto_engine.v
// bank_mem.v butterfly.v inverse_butterfly.v address_generator.v
// twiddle_index.v twiddle_rom.v inverse_twiddle_rom.v mod_add.v mod_sub.v
// mod_mul.v lfsr.v && vvp sim`) before trusting this change on real
// hardware.
//
// What it checks:
//   1. keygen_done pulses after each reset (keygen FSM still completes).
//   2. u_full/v_full (and therefore the public key -> ciphertext) differ
//      between two separate reset/keygen cycles for the SAME message --
//      proof that S is no longer a fixed constant.
//   3. Encrypting a byte then immediately decrypting it (within the same
//      keygen, same as top.v's normal flow) still recovers the original
//      byte correctly, i.e. this change didn't break correctness.
//////////////////////////////////////////////////////////////////////////////////

module tb_keygen_check;

reg clk = 0;
reg rst = 1;
reg start = 0;
reg [7:0] message_in = 8'b10110010; // arbitrary test byte

wire done, keygen_done;
wire [4:0] cipherU, cipherV;
wire [7:0] recovered_message;
wire [39:0] u_full, v_full;

crypto_engine DUT (
    .clk(clk), .rst(rst), .start(start), .message_in(message_in),
    .done(done), .keygen_done(keygen_done),
    .cipherU(cipherU), .cipherV(cipherV),
    .recovered_message(recovered_message),
    .u_full(u_full), .v_full(v_full)
);

always #5 clk = ~clk; // 100 MHz sim clock

reg [39:0] u_run1, v_run1;
reg [7:0]  recovered_run1;

task do_reset_and_keygen;
    begin
        rst = 1;
        repeat (4) @(posedge clk);
        rst = 0;
        wait (keygen_done == 1'b1);
        @(posedge clk);
    end
endtask

task do_encrypt_decrypt;
    begin
        start = 1;
        @(posedge clk);
        wait (done == 1'b1);
        @(posedge clk);
        start = 0;
        wait (done == 1'b0);
    end
endtask

initial begin
    $display("=== Run 1: reset, keygen, encrypt+decrypt message 8'b10110010 ===");
    do_reset_and_keygen;
    do_encrypt_decrypt;

    u_run1 = u_full;
    v_run1 = v_full;
    recovered_run1 = recovered_message;

    $display("Run1: u_full=%h v_full=%h recovered=%b (expected %b)",
              u_run1, v_run1, recovered_run1, message_in);

    if (recovered_run1 !== message_in)
        $display("FAIL: run1 did not decrypt correctly (noise pushed a bit past the rounding boundary -- rerun, or check DELTA/Q margins if this repeats)");
    else
        $display("PASS: run1 decrypted correctly");

    $display("=== Run 2: reset again (fresh S expected), same message ===");
    do_reset_and_keygen;
    do_encrypt_decrypt;

    $display("Run2: u_full=%h v_full=%h recovered=%b (expected %b)",
              u_full, v_full, recovered_message, message_in);

    if (recovered_message !== message_in)
        $display("FAIL: run2 did not decrypt correctly");
    else
        $display("PASS: run2 decrypted correctly");

    if ((u_full !== u_run1) || (v_full !== v_run1))
        $display("PASS: ciphertext differs across reset/keygen cycles -> S is being regenerated, not fixed");
    else
        $display("FAIL: ciphertext IDENTICAL across two separate keygens -> S_KG_S_GEN is not actually changing S (check the FSM wiring)");

    $finish;
end

endmodule
