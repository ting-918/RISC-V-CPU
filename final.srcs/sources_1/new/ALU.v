`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/14 15:07:15
// Design Name: 
// Module Name: ALU
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

module ALU (
    input[31:0] a,
    input[31:0] b,
    input[3:0] op,
    output reg[31:0] f,
    output reg c
);
    //ALU運算類型直接按{dis,func[2:0]}來進行編碼(CU就可以不用額外判斷func值來給定aluOP值)
    always @(*)
        case(op)
            4'b0000:f=a+b;                                  //add,addi
            4'b1000:begin                                   //sub
                        f=a-b;
                        c=~(|f);
                    end
            4'b0001:f=a<<b[4:0];                            //sll,slli 
            4'b0101:f=a>>b[4:0];                            //srl,srli 
            4'b1101:f=$signed(a)>>>b[4:0];                  //sra,srai 
            4'b0110:f=a|b;                                  //or,ori
            4'b0111:f=a&b;                                  //and,andi
            4'b0100:begin                                   //xor,xori
                        f=a^b;                               
                        c=(f==0)?1'b0:1'b1;
                    end
            4'b0010:begin                                   //slt,slti
                        f=($signed(a)<$signed(b))?32'b1:32'b0;  
                        c=($signed(a)<$signed(b))?1'b1:1'b0;
                    end
            4'b0011:begin                                   //sltu,sltiu
                        f=(a<b)?32'b1:32'b0;                    
                        c=(a<b)?1'b1:1'b0;
                    end
            4'b1010:c=($signed(a)<$signed(b))?1'b0:1'b1;    //bge
            4'b1011:c=(a<b)?1'b0:1'b1;                      //bgeu
            4'b1110:f=b<<12;                                //lui
            4'b1111:f=(b<<12)+a;                            //auipc
            default:f=32'b0;
        endcase
endmodule