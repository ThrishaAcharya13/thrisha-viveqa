`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.07.2026 23:28:18
// Design Name: 
// Module Name: address_generator
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

module address_generator(

    input [1:0] stage,
    input [1:0] butterfly,

    output reg [2:0] addrA,
    output reg [2:0] addrB

);

always @(*) begin

case(stage)

2'd0:
begin
    case(butterfly)
        2'd0: begin addrA=0; addrB=1; end
        2'd1: begin addrA=2; addrB=3; end
        2'd2: begin addrA=4; addrB=5; end
        2'd3: begin addrA=6; addrB=7; end
    endcase
end

2'd1:
begin
    case(butterfly)
        2'd0: begin addrA=0; addrB=2; end
        2'd1: begin addrA=1; addrB=3; end
        2'd2: begin addrA=4; addrB=6; end
        2'd3: begin addrA=5; addrB=7; end
    endcase
end

2'd2:
begin
    case(butterfly)
        2'd0: begin addrA=0; addrB=4; end
        2'd1: begin addrA=1; addrB=5; end
        2'd2: begin addrA=2; addrB=6; end
        2'd3: begin addrA=3; addrB=7; end
    endcase
end

default:
begin
    addrA=0;
    addrB=0;
end

endcase

end

endmodule
