`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/14 15:10:39
// Design Name: 
// Module Name: CU
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

module CU (
    input[6:0] opcode,
    input[2:0] func,
    input dis,
    input c,                //是否滿足B類指令的跳轉條件
    output reg[1:0] pcs,    //下條指令地址來源(00:pc+4, 01:pc+exp_imm12左移一位, 10:pc+exp_imm20左移一位, 11:ALU計算結果(最低位要設為0))
    output reg rwe,         //RegFiles 寫使能端信號
    output reg mwe,         //DataRAM 寫使能端信號
    output reg[3:0] aluOP,  //ALU運算類型
    output reg isimm,
    output reg ismem,
    output reg ispc4,
    output reg usepc,       //U類指令中的auipc指令，需使用當前pc值進行計算
    output reg[2:0] type    //DataRAM讀寫類型(type[2]判斷有無符號,type[1:0]判斷為字、半字、字節)
);
    wire R_type,I_type,B_type,S_type,J_type,U_type;
    assign R_type=~opcode[6]&(&opcode[5:4])&~(|opcode[3:2])&(&opcode[1:0]);         //R類指令：0110011 
    assign I_type=~opcode[6]&~opcode[5]&~opcode[3]&~opcode[2]&opcode[1]&opcode[0];  //I類指令：00x0011
    assign B_type=(&opcode[6:5])&~(|opcode[4:2])&(&opcode[1:0]);                    //B類指令：1100011
    assign S_type=~opcode[6]&opcode[5]&~(|opcode[4:2])&(&opcode[1:0]);              //S類指令：0100011
    assign J_type=(&opcode[6:5])&~opcode[4]&(&opcode[2:0]);                         //J類指令：110x111
    assign U_type=~opcode[6]&opcode[4]&~opcode[3]&(&opcode[2:0]);                   //U類指令：0x10111
    always @(*)
    begin
        if(R_type)
        begin    
            pcs=2'b00;
            rwe=1'b1;
            mwe=1'b0;
            aluOP={dis,func};
            isimm=1'b0;
            ismem=1'b0;
            ispc4=1'b0;
            usepc=1'b0;
        end
        if(I_type)
        begin
            rwe=1'b1;
            mwe=1'b0;
            isimm=1'b1;
            usepc=1'b0;
            case(opcode[6:4])
                3'b001: begin                        //立即數運算指令 
                            if({dis,func}==4'b1101)
                                aluOP={1'b1,func};   //srai
                            else
                                aluOP={1'b0,func}; 
                            pcs=2'b00;
                            ismem=1'b0;
                            ispc4=1'b0;
                        end
                3'b000: begin                        //load?指令(lw,lh,lb,lhu,lbu)
                            aluOP=4'b0000;           //用add來計算rs1+exp_imm12(作為內存地址)
                            pcs=2'b00;
                            ismem=1'b1;
                            ispc4=1'b0;
                            type=func;              //DataRAM讀類型由func給出
                        end
                3'b110: begin                       //jalr
                            aluOP=4'b0000;          //用add來計算rs1+exp_imm20(計算後的地址最低位設為0後作為跳轉地址)     
                            pcs=2'b11;              //jal:下條指令來源為2'b11類
                            ismem=1'b0;
                            ispc4=1'b1;
                        end
            endcase
        end
        if(B_type)
        begin
            rwe=1'b0;
            mwe=1'b0;
            isimm=1'b0;
            ismem=1'b0;
            ispc4=1'b0;
            usepc=1'b0;
            case(func)
                3'b000:aluOP=4'b1000;       //beq(用sub運算後的c來判斷)
                3'b001:aluOP=4'b0100;       //bne(用xor運算後的c來判斷)
                3'b100:aluOP=4'b0010;       //blt(用slt運算後的c來判斷)
                3'b101:aluOP=4'b1010;       //bge(用bge運算後的c來判斷)
                3'b110:aluOP=4'b0011;       //bltu(用sltu運算後的c來判斷)
                3'b111:aluOP=4'b1011;       //bgeu(用bgeu運算後的c來判斷)
            endcase
            pcs=(c==0)?2'b00:2'b01;         //滿足跳轉條件，則下條指令來源為2'b01類
        end
        if(S_type)
        begin                               //Store指令(sw,sh,sb)
            pcs=2'b00;
            rwe=1'b0;
            mwe=1'b1;
            aluOP=4'b0000;                  //用add來計算rs1+exp_imm12(作為內存地址)
            isimm=1'b1;
            ismem=1'b0;
            ispc4=1'b0;
            usepc=1'b0;
            type=func;                      //DataRAM寫類型由func給出      
        end
        if(J_type)
        begin
            pcs=2'b10;                      //jal:下條指令來源為2'b10類
            rwe=1'b1;
            mwe=1'b0;
            isimm=1'b0;
            ismem=1'b0;
            ispc4=1'b1;                     //將pc+4的值寫入RegFiles(rd)
            usepc=1'b0;
        end
         if(U_type)
        begin
            pcs=2'b00;                      
            rwe=1'b1;
            mwe=1'b0;
            isimm=1'b1;
            ismem=1'b0;
            ispc4=1'b0;
            usepc=opcode[5]?1'b0:1'b1;       //前者為lui指令，後者為auipc指令
            aluOP=opcode[5]?4'b1110:4'b1111;                
        end
   end
   initial 
        $monitor($time,,"當前指令類型：R=%b,I=%b,B=%b,S=%b,J=%b,U=%b",R_type,I_type,B_type,S_type,J_type,U_type);
endmodule
