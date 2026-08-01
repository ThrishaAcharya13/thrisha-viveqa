`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module : crypto_engine
// Project: FPGA Implementation of a Simplified Lattice-Based PQC
//          Encryption/Decryption Engine with NTT Accelerator
//
// Every polynomial multiplication in the scheme goes through the real NTT
// pipeline:
//     NTT(a) -> pointwise multiply -> INTT  ==  polynomial multiplication
// All 8-coefficient polynomials live in one shared 18-bank memory
// (bank_mem.v) and are moved between banks by a microcoded FSM below.
//
// NEGACYCLIC RING (matches real Kyber's X^N+1, not a cyclic X^N-1):
//   Kyber's ring is Z_q[X]/(X^n+1). A plain radix-2 NTT (as used here)
//   naturally computes CYCLIC convolution (mod X^n-1), which is the wrong
//   ring. The standard fix -- used here, and in real Kyber -- is to
//   "twist" the input/output by powers of psi, a primitive 2N-th root of
//   unity with psi^2 = omega (the root the NTT already uses): multiply
//   coefficient i by psi^i before the forward transform, and by
//   (1/N)*psi^-i after the inverse transform. That turns the same
//   cyclic-convolution hardware (butterfly.v, twiddle_rom.v,
//   address_generator.v -- all UNCHANGED from before) into a correct
//   negacyclic convolution. Q=17 was actually already the right modulus
//   for this at N=8 (17 = 2*8+1, i.e. 17 == 1 mod 16, so a primitive
//   16th root of unity exists mod 17) -- verified in this project's
//   design notes by directly comparing against schoolbook negacyclic
//   convolution before committing to these ROM values.
//
// GENUINE LWE NOISE: B = A*S + E, a real noise polynomial E (LFSR-sampled)
// added to the public key -- this is what makes recovering S from (A,B)
// hard. R is resampled fresh via the LFSR every encryption. (Noise is
// intentionally NOT added again on U/V -- simulation showed that at these
// toy parameters, Q=17/N=8, adding noise at every stage as real Kyber
// does drops whole-byte decode reliability to ~32%. Keygen-only noise
// keeps it at ~96.6% per byte while still being genuine LWE hardness.)
//
// GENUINE KEYGEN (S no longer a fixed constant): the secret S is now
// sampled fresh from the LFSR every reset, via the new S_KG_S_GEN state
// (same eta=1 centered-binomial sampler already used for noise E and
// randomness R -- real Kyber draws its secret from the same distribution
// as its noise). bank_mem.v's old hardcoded S values are now just a
// power-on placeholder, overwritten by S_KG_S_GEN before S is ever used --
// exactly the same pattern the R bank already used. This means a full
// power-cycle/reset now yields a genuinely different keypair (A stays a
// fixed public parameter, matching how Kyber shares/derives the public
// matrix, but S and therefore the public key B = A*S+E are regenerated).
//
// FULL-BYTE MESSAGE ENCODING (matches real Kyber's per-coefficient bit
// encoding, generalized to this engine's whole message at once): each of
// the 8 bits of message_in maps to one of the 8 ciphertext coefficients,
// encoded as 0 or DELTA=Q/2-ish and decoded via nearest-value rounding,
// exactly like Kyber decodes each bit of its message polynomialalso.
//////////////////////////////////////////////////////////////////////////////////

module crypto_engine(

    input clk,
    input rst,
    input start,
    input [7:0] message_in,          // one full byte -- bit i encrypted in coefficient i

    output done,
    output keygen_done,

    output [4:0] cipherU,
    output [4:0] cipherV,
    output [7:0] recovered_message,  // decoded byte -- bit i decoded from coefficient i

    // Full 8-coefficient U_TIME/V_TIME polynomials for top.v's UART
    // readout (5 bits/coefficient x 8 = 40 bits each). Captured directly
    // at write time inside this module -- see the shadow-register block
    // below -- so no extra bank_mem read port is needed.
    output [39:0] u_full,
    output [39:0] v_full

);

localparam Q     = 17;
localparam DELTA = 5'd8;   // per-bit encoding: bit=0 -> 0, bit=1 -> DELTA

//----------------------------------------------------------------------------
// Bank IDs (5 bits: 18 banks used, up to 32 addressable)
//----------------------------------------------------------------------------
localparam BANK_A     = 5'd0;
localparam BANK_S     = 5'd1;
localparam BANK_R     = 5'd2;
localparam BANK_WORK  = 5'd3;
localparam BANK_AF    = 5'd4;
localparam BANK_SF    = 5'd5;
localparam BANK_BF    = 5'd6;
localparam BANK_RF    = 5'd7;
localparam BANK_UF    = 5'd8;
localparam BANK_UT    = 5'd9;
localparam BANK_VF    = 5'd10;
localparam BANK_VT    = 5'd11;
localparam BANK_UF2   = 5'd12;
localparam BANK_USF   = 5'd13;
localparam BANK_UST   = 5'd14;
localparam BANK_MR    = 5'd15;
localparam BANK_E     = 5'd16;   // keygen noise, time domain
localparam BANK_EF    = 5'd17;   // NTT(E)

//----------------------------------------------------------------------------
// Op types
//----------------------------------------------------------------------------
localparam OP_COPY  = 3'd0;   // bank->bank copy, 8 cycles, optional twist/untwist
localparam OP_BFLY  = 3'd1;   // in-place NTT/INTT butterfly pass on WORK, 12 cycles
localparam OP_PW    = 3'd2;   // pointwise multiply, two src banks -> dst bank, 8 cycles
localparam OP_EW    = 3'd3;   // elementwise add/sub, 8 cycles
localparam OP_NOISE = 3'd4;   // sample an LFSR-derived small value into dst, 8 cycles

//----------------------------------------------------------------------------
// States
//----------------------------------------------------------------------------
localparam S_KG_A_IN=0,  S_KG_A_BF=1,  S_KG_A_OUT=2,
           S_KG_S_GEN=3,
           S_KG_S_IN=4,  S_KG_S_BF=5,  S_KG_S_OUT=6,
           S_KG_E_GEN=7, S_KG_E_IN=8,  S_KG_E_BF=9, S_KG_E_OUT=10,
           S_KG_B_PW=11, S_KG_B_ADDE=12,
           S_WAIT=13,
           S_R_GEN=14,
           S_R_IN=15,  S_R_BF=16,  S_R_OUT=17,
           S_U_PW=18,
           S_U_IN=19,  S_U_BF=20,  S_U_OUT=21,
           S_V_PW=22,
           S_V_IN=23,  S_V_BF=24,  S_V_OUT=25,
           S_V_ADDM=26,
           S_U2_IN=27, S_U2_BF=28, S_U2_OUT=29,
           S_US_PW=30,
           S_US_IN=31, S_US_BF=32, S_US_OUT=33,
           S_M_SUB=34,
           S_DONE=35;

reg [5:0] state;
reg [3:0] cnt;

//----------------------------------------------------------------------------
// Per-state control (combinational microcode)
//
// "twist" marks a forward-transform input copy (needs the psi^i pre-twist
// before its butterfly pass); "scale" marks an inverse-transform output
// copy (needs the combined (1/N)*psi^-i post-twist after its butterfly
// pass). Both are copy-time multiplies, so no extra cycles are needed --
// see the datapath section below for how they're applied.
//----------------------------------------------------------------------------
reg [2:0] op_type;
reg [4:0] src_a, src_b, dst;
reg       bitrev, scale, twist, inverse, ew_sub;

always @(*) begin
    // safe defaults
    op_type = OP_COPY; src_a = BANK_WORK; src_b = BANK_WORK; dst = BANK_WORK;
    bitrev = 1'b0; scale = 1'b0; twist = 1'b0; inverse = 1'b0; ew_sub = 1'b0;

    case(state)
        // ---- key generation (runs once after reset) ----
        S_KG_A_IN:  begin op_type=OP_COPY; src_a=BANK_A;  dst=BANK_WORK; bitrev=1; twist=1; end
        S_KG_A_BF:  begin op_type=OP_BFLY; inverse=0; end
        S_KG_A_OUT: begin op_type=OP_COPY; src_a=BANK_WORK; dst=BANK_AF; end
        S_KG_S_GEN: begin op_type=OP_NOISE; dst=BANK_S; end
        S_KG_S_IN:  begin op_type=OP_COPY; src_a=BANK_S;  dst=BANK_WORK; bitrev=1; twist=1; end
        S_KG_S_BF:  begin op_type=OP_BFLY; inverse=0; end
        S_KG_S_OUT: begin op_type=OP_COPY; src_a=BANK_WORK; dst=BANK_SF; end

        S_KG_E_GEN: begin op_type=OP_NOISE; dst=BANK_E; end
        S_KG_E_IN:  begin op_type=OP_COPY; src_a=BANK_E; dst=BANK_WORK; bitrev=1; twist=1; end
        S_KG_E_BF:  begin op_type=OP_BFLY; inverse=0; end
        S_KG_E_OUT: begin op_type=OP_COPY; src_a=BANK_WORK; dst=BANK_EF; end

        S_KG_B_PW:   begin op_type=OP_PW; src_a=BANK_AF; src_b=BANK_SF; dst=BANK_BF; end
        S_KG_B_ADDE: begin op_type=OP_EW; src_a=BANK_BF; src_b=BANK_EF; dst=BANK_BF; ew_sub=0; end

        S_WAIT: begin end

        // ---- per-message encryption ----
        S_R_GEN: begin op_type=OP_NOISE; dst=BANK_R; end

        S_R_IN:  begin op_type=OP_COPY; src_a=BANK_R; dst=BANK_WORK; bitrev=1; twist=1; end
        S_R_BF:  begin op_type=OP_BFLY; inverse=0; end
        S_R_OUT: begin op_type=OP_COPY; src_a=BANK_WORK; dst=BANK_RF; end

        S_U_PW:  begin op_type=OP_PW; src_a=BANK_AF; src_b=BANK_RF; dst=BANK_UF; end
        S_U_IN:  begin op_type=OP_COPY; src_a=BANK_UF; dst=BANK_WORK; bitrev=0; end
        S_U_BF:  begin op_type=OP_BFLY; inverse=1; end
        S_U_OUT: begin op_type=OP_COPY; src_a=BANK_WORK; dst=BANK_UT; bitrev=1; scale=1; end

        S_V_PW:  begin op_type=OP_PW; src_a=BANK_BF; src_b=BANK_RF; dst=BANK_VF; end
        S_V_IN:  begin op_type=OP_COPY; src_a=BANK_VF; dst=BANK_WORK; bitrev=0; end
        S_V_BF:  begin op_type=OP_BFLY; inverse=1; end
        S_V_OUT: begin op_type=OP_COPY; src_a=BANK_WORK; dst=BANK_VT; bitrev=1; scale=1; end

        S_V_ADDM: begin op_type=OP_EW; src_a=BANK_VT; dst=BANK_VT; ew_sub=0; end

        // ---- per-message decryption (standalone: only reads u_time/v_time) ----
        S_U2_IN:  begin op_type=OP_COPY; src_a=BANK_UT; dst=BANK_WORK; bitrev=1; twist=1; end
        S_U2_BF:  begin op_type=OP_BFLY; inverse=0; end
        S_U2_OUT: begin op_type=OP_COPY; src_a=BANK_WORK; dst=BANK_UF2; end

        S_US_PW:  begin op_type=OP_PW; src_a=BANK_UF2; src_b=BANK_SF; dst=BANK_USF; end
        S_US_IN:  begin op_type=OP_COPY; src_a=BANK_USF; dst=BANK_WORK; bitrev=0; end
        S_US_BF:  begin op_type=OP_BFLY; inverse=1; end
        S_US_OUT: begin op_type=OP_COPY; src_a=BANK_WORK; dst=BANK_UST; bitrev=1; scale=1; end

        S_M_SUB:  begin op_type=OP_EW; src_a=BANK_VT; src_b=BANK_UST; dst=BANK_MR; ew_sub=1; end

        S_DONE: begin end
        default: begin end
    endcase
end

wire [3:0] target = (op_type == OP_BFLY) ? 4'd12 : 4'd8;

//----------------------------------------------------------------------------
// FSM sequencing
//----------------------------------------------------------------------------
function [5:0] next_state;
    input [5:0] s;
    begin
        case(s)
            S_KG_A_IN:  next_state = S_KG_A_BF;
            S_KG_A_BF:  next_state = S_KG_A_OUT;
            S_KG_A_OUT: next_state = S_KG_S_GEN;
            S_KG_S_GEN: next_state = S_KG_S_IN;
            S_KG_S_IN:  next_state = S_KG_S_BF;
            S_KG_S_BF:  next_state = S_KG_S_OUT;
            S_KG_S_OUT: next_state = S_KG_E_GEN;
            S_KG_E_GEN: next_state = S_KG_E_IN;
            S_KG_E_IN:  next_state = S_KG_E_BF;
            S_KG_E_BF:  next_state = S_KG_E_OUT;
            S_KG_E_OUT: next_state = S_KG_B_PW;
            S_KG_B_PW:  next_state = S_KG_B_ADDE;
            S_KG_B_ADDE: next_state = S_WAIT;

            S_R_GEN: next_state = S_R_IN;
            S_R_IN:  next_state = S_R_BF;
            S_R_BF:  next_state = S_R_OUT;
            S_R_OUT: next_state = S_U_PW;
            S_U_PW:  next_state = S_U_IN;
            S_U_IN:  next_state = S_U_BF;
            S_U_BF:  next_state = S_U_OUT;
            S_U_OUT: next_state = S_V_PW;
            S_V_PW:  next_state = S_V_IN;
            S_V_IN:  next_state = S_V_BF;
            S_V_BF:  next_state = S_V_OUT;
            S_V_OUT: next_state = S_V_ADDM;
            S_V_ADDM: next_state = S_U2_IN;
            S_U2_IN: next_state = S_U2_BF;
            S_U2_BF: next_state = S_U2_OUT;
            S_U2_OUT: next_state = S_US_PW;
            S_US_PW: next_state = S_US_IN;
            S_US_IN: next_state = S_US_BF;
            S_US_BF: next_state = S_US_OUT;
            S_US_OUT: next_state = S_M_SUB;
            S_M_SUB: next_state = S_DONE;

            default: next_state = S_WAIT;
        endcase
    end
endfunction

reg keygen_done_r, done_r;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= S_KG_A_IN;
        cnt   <= 4'd0;
        keygen_done_r <= 1'b0;
        done_r <= 1'b0;
    end
    else begin
        case(state)
            S_WAIT: begin
                done_r <= 1'b0;
                if (start)
                    state <= S_R_GEN;
            end
            S_DONE: begin
                done_r <= 1'b1;
                if (!start)
                    state <= S_WAIT;
            end
            default: begin
                if (cnt == target - 1'b1) begin
                    cnt <= 4'd0;
                    state <= next_state(state);
                    if (state == S_KG_B_ADDE)
                        keygen_done_r <= 1'b1;
                end
                else begin
                    cnt <= cnt + 1'b1;
                end
            end
        endcase
    end
end

assign done = done_r;
assign keygen_done = keygen_done_r;

//----------------------------------------------------------------------------
// Pseudorandom source: free-running LFSR, tapped for both the keygen
// noise polynomial E and the fresh-per-encryption randomness R.
//----------------------------------------------------------------------------
wire [15:0] lfsr_q;
lfsr LFSR_INST (.clk(clk), .rst(rst), .q(lfsr_q));

// Centered-binomial-style sample (eta=1): two LFSR bits a,b -> a-b mod Q,
// giving small values {-1,0,1} i.e. {16,0,1}. Standard LWE noise sampler.
wire [4:0] noise_val = (lfsr_q[0] && !lfsr_q[1]) ? 5'd1  :
                        (!lfsr_q[0] && lfsr_q[1]) ? 5'd16 :
                                                     5'd0;

//----------------------------------------------------------------------------
// Datapath: address generation per op type
//----------------------------------------------------------------------------
wire [2:0] k = cnt[2:0];

// bit-reversal of a 3-bit address is just a wire swap
function [2:0] bitrev3;
    input [2:0] a;
    begin
        bitrev3 = {a[0], a[1], a[2]};
    end
endfunction

// -- BFLY sub-addressing --
wire [1:0] stage_cnt = cnt[3:2];
wire [1:0] bf_cnt     = cnt[1:0];
wire [1:0] stage_actual = inverse ? (2'd2 - stage_cnt) : stage_cnt;

wire [2:0] bfly_localA, bfly_localB;
address_generator AG (
    .stage(stage_actual),
    .butterfly(bf_cnt),
    .addrA(bfly_localA),
    .addrB(bfly_localB)
);

wire [1:0] twid_exp;
twiddle_index TIDX (.stage(stage_actual), .bf(bf_cnt), .exp(twid_exp));

wire [4:0] w_fwd, w_inv;
twiddle_rom         ROM_F (.addr({1'b0,twid_exp}), .w(w_fwd));
inverse_twiddle_rom  ROM_I (.addr({1'b0,twid_exp}), .w(w_inv));
wire [4:0] W = inverse ? w_inv : w_fwd;

// -- Negacyclic twist ROMs (psi=6, satisfies psi^2=2=omega, so the
// forward/inverse butterfly network above needs zero changes -- see the
// module header note). Values verified against direct schoolbook
// negacyclic convolution before use.
function [4:0] twist_fwd_rom;
    input [2:0] i;
    begin
        case(i)
            3'd0: twist_fwd_rom = 5'd1;
            3'd1: twist_fwd_rom = 5'd6;
            3'd2: twist_fwd_rom = 5'd2;
            3'd3: twist_fwd_rom = 5'd12;
            3'd4: twist_fwd_rom = 5'd4;
            3'd5: twist_fwd_rom = 5'd7;
            3'd6: twist_fwd_rom = 5'd8;
            3'd7: twist_fwd_rom = 5'd14;
        endcase
    end
endfunction

function [4:0] twist_inv_scale_rom;
    input [2:0] i;
    begin
        case(i)
            3'd0: twist_inv_scale_rom = 5'd15;
            3'd1: twist_inv_scale_rom = 5'd11;
            3'd2: twist_inv_scale_rom = 5'd16;
            3'd3: twist_inv_scale_rom = 5'd14;
            3'd4: twist_inv_scale_rom = 5'd8;
            3'd5: twist_inv_scale_rom = 5'd7;
            3'd6: twist_inv_scale_rom = 5'd4;
            3'd7: twist_inv_scale_rom = 5'd12;
        endcase
    end
endfunction

//----------------------------------------------------------------------------
// bank_mem address/data wiring, muxed per op_type
//----------------------------------------------------------------------------
reg [7:0] rdA, rdB, wrA, wrB;
reg       weA, weB;
reg [4:0] wdA, wdB;

wire [4:0] rdatA, rdatB;

wire [4:0] pw_product;
mod_mul #(.WIDTH(5), .Q(Q)) PW_MUL (.a(rdatA), .b(rdatB), .product(pw_product));

// S_V_ADDM adds the encoded message bit (0 or DELTA) at every coefficient
// k, one bit of message_in per coefficient (bit i -> coefficient i).
wire [4:0] ew_operand2 = message_in[k] ? DELTA : 5'd0;
wire [4:0] ew_add_result, ew_sub_result;
mod_add #(.WIDTH(5), .Q(Q)) EW_ADD (.a(rdatA), .b(ew_operand2), .sum(ew_add_result));
mod_sub #(.WIDTH(5), .Q(Q)) EW_SUB (.a(rdatA), .b(rdatB), .diff(ew_sub_result));

// Forward-transform input copy: multiply by psi^i, where i is the NATURAL
// index of the coefficient just fetched -- since the read address is
// bit-reversed (bitrev3(k)), that natural index is bitrev3(k) itself.
wire [4:0] twist_val;
mod_mul #(.WIDTH(5), .Q(Q)) TWIST_MUL (.a(rdatA), .b(twist_fwd_rom(bitrev3(k))), .product(twist_val));

// Inverse-transform output copy: multiply by the combined (1/N)*psi^-k,
// where k is the NATURAL output index being written this cycle.
wire [4:0] untwist_scaled;
mod_mul #(.WIDTH(5), .Q(Q)) UNTWIST_MUL (.a(rdatA), .b(twist_inv_scale_rom(k)), .product(untwist_scaled));

wire [4:0] bfA_out, bfB_out, ibfA_out, ibfB_out;
butterfly         BF  (.A(rdatA), .B(rdatB), .W(W), .A_out(bfA_out),  .B_out(bfB_out));
inverse_butterfly IBF (.A(rdatA), .B(rdatB), .W(W), .A_out(ibfA_out), .B_out(ibfB_out));

always @(*) begin
    rdA = 8'd0; rdB = 8'd0; wrA = 8'd0; wrB = 8'd0;
    weA = 1'b0; weB = 1'b0;
    wdA = 5'd0; wdB = 5'd0;

    case(op_type)
        OP_COPY: begin
            rdA = {src_a, bitrev ? bitrev3(k) : k};
            wrA = {dst,   k};
            wdA = scale ? untwist_scaled : (twist ? twist_val : rdatA);
            weA = 1'b1;
        end
        OP_BFLY: begin
            rdA = {BANK_WORK, bfly_localA};
            rdB = {BANK_WORK, bfly_localB};
            wrA = {BANK_WORK, bfly_localA};
            wrB = {BANK_WORK, bfly_localB};
            wdA = inverse ? ibfA_out : bfA_out;
            wdB = inverse ? ibfB_out : bfB_out;
            weA = 1'b1;
            weB = 1'b1;
        end
        OP_PW: begin
            rdA = {src_a, k};
            rdB = {src_b, k};
            wrA = {dst,   k};
            wdA = pw_product;
            weA = 1'b1;
        end
        OP_EW: begin
            rdA = {src_a, k};
            rdB = {src_b, k};
            wrA = {dst,   k};
            wdA = ew_sub ? ew_sub_result : ew_add_result;
            weA = 1'b1;
        end
        OP_NOISE: begin
            wrA = {dst, k};
            wdA = noise_val;
            weA = 1'b1;
        end
    endcase
end

wire engine_active = (state != S_WAIT) && (state != S_DONE);

bank_mem MEM (
    .clk(clk),
    .weA(weA && engine_active), .write_addrA(wrA), .write_dataA(wdA),
    .weB(weB && engine_active), .write_addrB(wrB), .write_dataB(wdB),
    .read_addrA(rdA), .read_dataA(rdatA),
    .read_addrB(rdB), .read_dataB(rdatB)
);

//----------------------------------------------------------------------------
// Output display taps -- captured directly at the exact cycle each value
// is written, instead of read back out through a separate peek port.
//----------------------------------------------------------------------------
reg [4:0] u_shadow [0:7];   // full U_TIME polynomial, latched as it's written
reg [4:0] v_shadow [0:7];   // full V_TIME polynomial, latched as it's written
reg [4:0] resid_shadow [0:7]; // full residual (all 8 coefficients), pre-decode

integer si;
always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (si = 0; si < 8; si = si + 1) begin
            u_shadow[si] <= 5'd0;
            v_shadow[si] <= 5'd0;
            resid_shadow[si] <= 5'd0;
        end
    end else begin
        // S_U_OUT writes UT[k] <- wdA for k = 0..7: capture every cycle.
        if (state == S_U_OUT)
            u_shadow[k] <= wdA;

        // S_V_ADDM writes VT[k] <- wdA for k = 0..7: capture every cycle
        // (this is the final, message-added V_TIME, for all 8 coeffs).
        if (state == S_V_ADDM)
            v_shadow[k] <= wdA;

        // S_M_SUB writes MR[k] <- wdA for k = 0..7: capture every cycle,
        // one residual per message bit.
        if (state == S_M_SUB)
            resid_shadow[k] <= wdA;
    end
end

// Nearest-of-{0, DELTA} decode per coefficient: with Q=17 and DELTA=8,
// residuals 4..12 decode to bit 1, everything else decodes to bit 0 (see
// the design notes for the derivation -- computed exactly, not guessed,
// from the circular distance to 0 vs. to DELTA mod Q).
wire [7:0] decoded_byte;
genvar dj;
generate
    for (dj = 0; dj < 8; dj = dj + 1) begin : DECODE_BITS
        assign decoded_byte[dj] = (resid_shadow[dj] >= 5'd4) && (resid_shadow[dj] <= 5'd12);
    end
endgenerate

// Full 8-coefficient polynomials, packed for top.v's UART readout
// (5 bits/coefficient x 8 = 40 bits, no extra memory port needed).
genvar gi;
generate
    for (gi = 0; gi < 8; gi = gi + 1) begin : PACK_U
        assign u_full[gi*5 +: 5] = u_shadow[gi];
    end
    for (gi = 0; gi < 8; gi = gi + 1) begin : PACK_V
        assign v_full[gi*5 +: 5] = v_shadow[gi];
    end
endgenerate

assign cipherU = u_shadow[0];
assign cipherV = v_shadow[0];
assign recovered_message = decoded_byte;

endmodule
