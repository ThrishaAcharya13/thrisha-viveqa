`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.06.2026 16:35:02
// Design Name: 
// Module Name: tb_test
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


module tb_test(

    );
    
    reg a_tb,b_tb;
    wire y_tb;
    
    test u0(
    .a(a_tb),
    .b(b_tb),
    .y(y_tb)
    );
    
initial begin

a_tb=0; b_tb=0;
#10;

a_tb=0; b_tb=1;
#10;

a_tb=1; b_tb=0;
#10;

a_tb=1 ; b_tb=1;
#10;
end

endmodule
