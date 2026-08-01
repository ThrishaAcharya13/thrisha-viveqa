`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module : bank_mem
//
// Holds every polynomial the engine touches, as 18 banks of 8 coefficients
// (5 bits each), addressed as {bank_id[4:0], coeff[2:0]}. Using one flat
// memory instead of a separate poly_memory per polynomial means "moving
// data from bank X to bank Y" is just an address computation -- no
// crossbar/mux network is needed between operations.
//
// Bank map (see crypto_engine.v):
//   0  A        (public parameter, constant)
//   1  S        (secret key -- resampled fresh via LFSR by S_KG_S_GEN at
//                the start of every keygen/reset; the reset value here is
//                just a placeholder, overwritten before first use)
//   2  R        (ephemeral randomness -- resampled fresh via LFSR at the
//                start of every encryption; the reset value here is just
//                a placeholder, overwritten before first use)
//   3  WORK     (scratch bank used in-place by every NTT/INTT butterfly pass)
//   4  A_FREQ   5  S_FREQ   6  B_FREQ    (B_FREQ persists after keygen and
//                                          already includes noise term E)
//   7  R_FREQ   8  U_FREQ   9  U_TIME   10  V_FREQ  11  V_TIME
//  12  U_FREQ2 13  US_FREQ 14  US_TIME  15  M_RECOVERED
//  16  E        (keygen noise polynomial, time domain, LFSR-sampled)
//  17  E_FREQ   (NTT(E), added into B_FREQ once during keygen)
//
// Two independent read/write ports (A/B), exactly like the original
// poly_memory, which is what lets a single butterfly operate on two
// coefficients in one cycle.
//////////////////////////////////////////////////////////////////////////////////

module bank_mem #(
    parameter WIDTH = 5,
    parameter N     = 256   // 32 possible banks (18 used) * 8 coefficients
)(
    input clk,

    input                  weA,
    input      [7:0]       write_addrA,
    input      [WIDTH-1:0] write_dataA,

    input                  weB,
    input      [7:0]       write_addrB,
    input      [WIDTH-1:0] write_dataB,

    input      [7:0]       read_addrA,
    output     [WIDTH-1:0] read_dataA,

    input      [7:0]       read_addrB,
    output     [WIDTH-1:0] read_dataB
);

reg [WIDTH-1:0] mem [0:N-1];

integer i;

initial begin
    for (i = 0; i < N; i = i + 1)
        mem[i] = {WIDTH{1'b0}};

    // Bank 0 : A  (public parameter polynomial)
    mem[0]=5'd5;  mem[1]=5'd11; mem[2]=5'd11; mem[3]=5'd2;
    mem[4]=5'd14; mem[5]=5'd16; mem[6]=5'd3;  mem[7]=5'd5;

    // Bank 1 : S  (placeholder only -- overwritten by S_KG_S_GEN before
    // first use, see crypto_engine.v. Kept as small values purely so
    // waveform dumps look sane if anything ever peeks at bank 1 before
    // the first reset finishes.)
    mem[8]=5'd2;  mem[9]=5'd1;  mem[10]=5'd1; mem[11]=5'd1;
    mem[12]=5'd2; mem[13]=5'd0; mem[14]=5'd1; mem[15]=5'd0;

    // Bank 2 : R  (placeholder only -- overwritten by S_R_GEN before
    // first use, see crypto_engine.v)
    mem[16]=5'd1; mem[17]=5'd2; mem[18]=5'd2; mem[19]=5'd2;
    mem[20]=5'd2; mem[21]=5'd1; mem[22]=5'd2; mem[23]=5'd0;
end

always @(posedge clk)
begin
    if (weA)
        mem[write_addrA] <= write_dataA;

    if (weB)
        mem[write_addrB] <= write_dataB;
end

assign read_dataA = mem[read_addrA];
assign read_dataB = mem[read_addrB];

endmodule
