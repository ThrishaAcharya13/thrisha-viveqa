`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.07.2026 12:59:01
// Design Name: 
// Module Name: fifo_tb
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
`timescale 1ns/1ps

module fifo_tb();

reg clk;
reg rst;
reg wr_en;
reg rd_en;
reg [7:0] write_data;

wire [7:0] read_data;
wire full;
wire empty;

// Instantiate FIFO
fifo dut(
    .clk(clk),
    .rst(rst),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .write_data(write_data),
    .read_data(read_data),
    .full(full),
    .empty(empty)
);

// Clock Generation
always #5 clk = ~clk;

initial
begin
    clk = 1'b0;
    rst = 1'b1;
    wr_en = 1'b0;
    rd_en = 1'b0;
    write_data = 8'd0;

    // Reset
    #12 rst = 1'b0;

    // Write Data
    #12 wr_en = 1'b1; write_data = 8'd10;
    #12 wr_en = 1'b0;

    #12 wr_en = 1'b1; write_data = 8'd20;
    #12 wr_en = 1'b0;

    #12 wr_en = 1'b1; write_data = 8'd30;
    #12 wr_en = 1'b0;

    #12 wr_en = 1'b1; write_data = 8'd40;
    #12 wr_en = 1'b0;

    // Read Data
    #12 rd_en = 1'b1;
    #12 rd_en = 1'b0;

    #12 rd_en = 1'b1;
    #12 rd_en = 1'b0;

    #12 rd_en = 1'b1;
    #12 rd_en = 1'b0;

    #12 rd_en = 1'b1;
    #12 rd_en = 1'b0;

    #20 $finish;
end

endmodule