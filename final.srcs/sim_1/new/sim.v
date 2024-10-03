`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/14 15:20:31
// Design Name: 
// Module Name: sim
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

module sim();
      reg [3:0] n=4'b1111; 
      wire[31:0] result;
      reg clk = 1'b0;
      reg rst = 1'b1;
      always #5
          clk = ~clk;
      initial
      begin
          #6 rst = 1'b0;
      end
      CPU myCPU(.clk(clk),.rst(rst),.n(n),.result(result));
      
endmodule
