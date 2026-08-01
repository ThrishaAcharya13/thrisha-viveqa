`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module : lfsr
//
// 16-bit maximal-length Galois LFSR (polynomial x^16+x^15+x^13+x^4+1), used
// as crypto_engine's pseudorandom source for:
//   - the noise polynomial E added to the public key (B = A*S + E)
//   - the ephemeral randomness polynomial R, resampled fresh each encryption
//     (previously a fixed constant in bank_mem.v -- see crypto_engine.v's
//     SIMPLIFICATION NOTE this replaces)
//
// Free-running: advances every clock cycle regardless of what state
// crypto_engine's FSM is in, so by the time any noise-sampling state reads
// it, the low bits have already mixed many times over. This is a
// pseudorandom generator, not a true entropy source -- exactly like the
// original design's fixed constants, it is a simplification appropriate for
// an FPGA teaching project, not a production TRNG.
//////////////////////////////////////////////////////////////////////////////////

module lfsr(
    input  wire        clk,
    input  wire        rst,
    output wire [15:0] q
);

reg [15:0] state;

wire feedback = state[15] ^ state[14] ^ state[12] ^ state[3];

always @(posedge clk or posedge rst) begin
    if (rst)
        state <= 16'hACE1;   // fixed nonzero seed (all-zero state would lock up)
    else
        state <= {state[14:0], feedback};
end

assign q = state;

endmodule
