`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module : twiddle_index
//
// For an 8-point radix-2 NTT with the address_generator's pair layout,
// the twiddle exponent used by a given (stage, butterfly) is:
//
//     exponent = butterfly_index_within_group * (N / group_size)
//
// which works out, for this specific address layout, to:
//
//     stage 0 : 0, 0, 0, 0
//     stage 1 : 0, 2, 0, 2
//     stage 2 : 0, 1, 2, 3
//
// This is the same table for both the forward and inverse transform;
// only the stage traversal ORDER and the ROM (twiddle_rom vs
// inverse_twiddle_rom) differ between forward/inverse.
//
// The previous design fed the raw memory address (addrB) straight into
// the twiddle ROM. That is only coincidentally correct for a couple of
// entries and wrong in general -- it is the root cause of the transform
// not being invertible.
//////////////////////////////////////////////////////////////////////////////////

module twiddle_index(

    input  [1:0] stage,
    input  [1:0] bf,

    output reg [1:0] exp

);

always @(*)
begin
    case(stage)
        2'd0: exp = 2'd0;
        2'd1: exp = bf[0] ? 2'd2 : 2'd0;
        2'd2: exp = bf;
        default: exp = 2'd0;
    endcase
end

endmodule
