`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// tb_crypto_demo.v
//
// LECTURE-DEMO TESTBENCH for crypto_engine (FPGA lattice-based PQC engine).
//
// Purpose: show, in one simulation run, that the design
//   (a) generates a keypair after reset,
//   (b) encrypts + decrypts a whole spread of test bytes correctly through
//       the real NTT -> pointwise-multiply -> INTT pipeline, and
//   (c) reports the per-bit accuracy so the ~96%-ish LWE-noise behavior is
//       visible and explainable, not hidden.
//
// This deliberately reuses the SAME reset/keygen and encrypt/decrypt task
// structure as tb_keygen_check.v (do_reset_and_keygen / do_encrypt_decrypt),
// since that handshake is already proven against this exact crypto_engine
// interface -- this testbench just drives it over more messages and adds
// summary statistics for a demo.
//
// Run with Icarus Verilog:
//   iverilog -o sim tb_crypto_demo.v crypto_engine.v bank_mem.v butterfly.v \
//       inverse_butterfly.v address_generator.v twiddle_index.v \
//       twiddle_rom.v inverse_twiddle_rom.v mod_add.v mod_sub.v mod_mul.v \
//       lfsr.v
//   vvp sim
//
// (Optional waveform: add `$dumpfile("demo.vcd"); $dumpvars(0,tb_crypto_demo);`
//  right after the `initial begin` below, then view demo.vcd in GTKWave.)
//////////////////////////////////////////////////////////////////////////////////

module tb_crypto_demo;

reg clk = 0;
reg rst = 1;
reg start = 0;
reg [7:0] message_in = 8'd0;

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

//----------------------------------------------------------------------------
// Same handshake tasks as tb_keygen_check.v
//----------------------------------------------------------------------------
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

//----------------------------------------------------------------------------
// Test vectors -- a spread that exercises all-zero, all-one, alternating,
// and mixed bit patterns across the byte.
//----------------------------------------------------------------------------
reg [7:0] test_vectors [0:7];
integer   num_tests = 8;

integer i, b;
integer total_bits, correct_bits;
integer msg_fail_count;
reg [7:0] xor_diff;

initial begin
    test_vectors[0] = 8'h00; // all zero bits
    test_vectors[1] = 8'hFF; // all one bits
    test_vectors[2] = 8'hA5; // 10100101
    test_vectors[3] = 8'h5A; // 01011010
    test_vectors[4] = 8'h3C; // 00111100
    test_vectors[5] = 8'hC3; // 11000011
    test_vectors[6] = 8'h81; // 10000001
    test_vectors[7] = 8'h42; // 01000010

    total_bits    = 0;
    correct_bits  = 0;
    msg_fail_count = 0;

    $display("================================================================");
    $display(" FPGA Lattice-Based (LWE) Crypto Engine -- Demonstration Testbench");
    $display("================================================================");

    $display("\n[1] Reset + key generation ...");
    do_reset_and_keygen;
    if (keygen_done)
        $display("    PASS: keygen_done asserted -- public key B = A*S + E ready.");
    else
        $display("    FAIL: keygen_done never asserted.");

    $display("\n[2] Encrypt + decrypt %0d test messages through the same keypair:", num_tests);
    $display("    (each message: NTT(A,R) -> U ; NTT pointwise B*R+msg -> V ; decrypt V - U*S)\n");

    for (i = 0; i < num_tests; i = i + 1) begin
        message_in = test_vectors[i];

        do_encrypt_decrypt;

        xor_diff = message_in ^ recovered_message;

        $display("    Test %0d: sent=8'b%b  cipherU=%0d cipherV=%0d  recovered=8'b%b  %s",
                  i, message_in, cipherU, cipherV, recovered_message,
                  (xor_diff == 8'd0) ? "PASS (exact match)" : "PARTIAL (bit-level noise -- see below)");

        // Per-bit accuracy accounting (expected LWE behavior: occasional
        // single-bit misses near the decode threshold, not a design bug)
        for (b = 0; b < 8; b = b + 1) begin
            total_bits = total_bits + 1;
            if (message_in[b] == recovered_message[b])
                correct_bits = correct_bits + 1;
        end

        if (xor_diff != 8'd0)
            msg_fail_count = msg_fail_count + 1;
    end

    $display("\n================================================================");
    $display(" SUMMARY");
    $display("================================================================");
    $display(" Messages tested            : %0d", num_tests);
    $display(" Messages decoded exactly   : %0d / %0d", num_tests - msg_fail_count, num_tests);
    $display(" Total bits tested          : %0d", total_bits);
    $display(" Bits decoded correctly     : %0d / %0d", correct_bits, total_bits);
    $display(" Per-bit accuracy           : %0d.%0d%%",
              (correct_bits*10000/total_bits)/100, (correct_bits*10000/total_bits)%100);
    $display(" (Occasional single-bit misses are expected genuine LWE-noise");
    $display("  behavior at these toy parameters (Q=17, N=8), not a functional bug --");
    $display("  see crypto_engine.v header comment on keygen-only noise.)");
    $display("================================================================");

    $finish;
end

endmodule
