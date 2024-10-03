`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/14 15:11:20
// Design Name: 
// Module Name: PC
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
module PC (
    input rst,
    input clk,
    input[31:0] next,       //下條指令的地址
    output reg[31:0] addr   //當前指令的地址
);
    always @(posedge clk)
        if(rst)
            addr<=32'h0;
        else
            addr<=next;
endmodule