`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/14 15:08:55
// Design Name: 
// Module Name: ID
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
module ID (
    input[31:0] ins,             //從ROM取出的RV321指令
    output[4:0] rs1,
    output[4:0] rs2,
    output[4:0] rd,
    output[6:0] opcode,
    output[2:0] func,
    output dis,                  //區分碼(指令第30位)
    output[31:0] exp_imm12,      //擴展後的imm12
    output[31:0] exp_imm20       //擴展後的imm20
);
    wire I_type,B_type,S_type,J_type,U_type;
    wire[11:0] imm12;
    wire[19:0] imm20;
    assign opcode=ins[6:0];
    assign rd=ins[11:7];
    assign func=ins[14:12];
    assign rs1=ins[19:15];
    assign rs2=ins[24:20];
    assign dis=ins[30];
    assign I_type=~ins[6]&~ins[5]&~ins[3]&~ins[2]&ins[1]&ins[0];   //I類指令：00x0011
    assign B_type=(&ins[6:5])&~(|ins[4:3])&(&ins[1:0]);            //B類指令：1100011
    assign S_type=~ins[6]&ins[5]&~(|ins[4:3])&(&ins[1:0]);         //S類指令：0100011
    assign J_type=(&opcode[6:5])&~opcode[4]&(&opcode[2:0]);        //J類指令：110x111
    assign U_type=~opcode[6]&opcode[4]&~opcode[3]&(&opcode[2:0]);  //U類指令：0x10111
    assign imm12={12{I_type}}&ins[31:20]|
                 {12{B_type}}&{ins[31],ins[7],ins[30:25],ins[11:8]}|
                 {12{S_type}}&{ins[31:25],ins[11:7]};
    assign imm20={20{U_type}}&ins[31:12]|
                 {20{J_type}}&{ins[31],ins[19:12],ins[20],ins[30:21]};
    assign exp_imm12={{20{imm12[11]}},imm12};    //imm12符號擴展為32位
    assign exp_imm20={{12{imm20[19]}},imm20};    //imm20符號擴展為32位
endmodule