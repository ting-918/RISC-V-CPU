`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/16 23:10:39
// Design Name: 
// Module Name: myRegFiles
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

module RegFiles (
    input clk,
    input[4:0] raddr1,
    output[31:0] rdata1,
    input[4:0] raddr2,
    output[31:0] rdata2,
    input[4:0] waddr,
    input we,
    output[31:0] wdata
);
    reg[31:0] regs[1:31];
    assign rdata1=(raddr1==5'b00000)?32'b0:regs[raddr1];
    assign rdata2=(raddr2==5'b00000)?32'b0:regs[raddr2];
    always @(posedge clk)
        if(we)
            if(waddr!=5'b00000)
                regs[waddr]<=wdata;
endmodule

