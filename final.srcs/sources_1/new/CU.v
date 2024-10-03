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
    input c,                //�Ƿ�M��B�ָ������D�l��
    output reg[1:0] pcs,    //�lָ���ַ��Դ(00:pc+4, 01:pc+exp_imm12����һλ, 10:pc+exp_imm20����һλ, 11:ALUӋ��Y��(���λҪ�O��0))
    output reg rwe,         //RegFiles ��ʹ�ܶ���̖
    output reg mwe,         //DataRAM ��ʹ�ܶ���̖
    output reg[3:0] aluOP,  //ALU�\�����
    output reg isimm,
    output reg ismem,
    output reg ispc4,
    output reg usepc,       //U�ָ���е�auipcָ���ʹ�î�ǰpcֵ�M��Ӌ��
    output reg[2:0] type    //DataRAM�x�����(type[2]�Д��Пo��̖,type[1:0]�Д����֡����֡��ֹ�)
);
    wire R_type,I_type,B_type,S_type,J_type,U_type;
    assign R_type=~opcode[6]&(&opcode[5:4])&~(|opcode[3:2])&(&opcode[1:0]);         //R�ָ�0110011 
    assign I_type=~opcode[6]&~opcode[5]&~opcode[3]&~opcode[2]&opcode[1]&opcode[0];  //I�ָ�00x0011
    assign B_type=(&opcode[6:5])&~(|opcode[4:2])&(&opcode[1:0]);                    //B�ָ�1100011
    assign S_type=~opcode[6]&opcode[5]&~(|opcode[4:2])&(&opcode[1:0]);              //S�ָ�0100011
    assign J_type=(&opcode[6:5])&~opcode[4]&(&opcode[2:0]);                         //J�ָ�110x111
    assign U_type=~opcode[6]&opcode[4]&~opcode[3]&(&opcode[2:0]);                   //U�ָ�0x10111
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
                3'b001: begin                        //�������\��ָ�� 
                            if({dis,func}==4'b1101)
                                aluOP={1'b1,func};   //srai
                            else
                                aluOP={1'b0,func}; 
                            pcs=2'b00;
                            ismem=1'b0;
                            ispc4=1'b0;
                        end
                3'b000: begin                        //load?ָ��(lw,lh,lb,lhu,lbu)
                            aluOP=4'b0000;           //��add��Ӌ��rs1+exp_imm12(����ȴ��ַ)
                            pcs=2'b00;
                            ismem=1'b1;
                            ispc4=1'b0;
                            type=func;              //DataRAM�x�����func�o��
                        end
                3'b110: begin                       //jalr
                            aluOP=4'b0000;          //��add��Ӌ��rs1+exp_imm20(Ӌ����ĵ�ַ���λ�O��0���������D��ַ)     
                            pcs=2'b11;              //jal:�lָ���Դ��2'b11�
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
                3'b000:aluOP=4'b1000;       //beq(��sub�\�����c���Д�)
                3'b001:aluOP=4'b0100;       //bne(��xor�\�����c���Д�)
                3'b100:aluOP=4'b0010;       //blt(��slt�\�����c���Д�)
                3'b101:aluOP=4'b1010;       //bge(��bge�\�����c���Д�)
                3'b110:aluOP=4'b0011;       //bltu(��sltu�\�����c���Д�)
                3'b111:aluOP=4'b1011;       //bgeu(��bgeu�\�����c���Д�)
            endcase
            pcs=(c==0)?2'b00:2'b01;         //�M�����D�l�����t�lָ���Դ��2'b01�
        end
        if(S_type)
        begin                               //Storeָ��(sw,sh,sb)
            pcs=2'b00;
            rwe=1'b0;
            mwe=1'b1;
            aluOP=4'b0000;                  //��add��Ӌ��rs1+exp_imm12(����ȴ��ַ)
            isimm=1'b1;
            ismem=1'b0;
            ispc4=1'b0;
            usepc=1'b0;
            type=func;                      //DataRAM�������func�o��      
        end
        if(J_type)
        begin
            pcs=2'b10;                      //jal:�lָ���Դ��2'b10�
            rwe=1'b1;
            mwe=1'b0;
            isimm=1'b0;
            ismem=1'b0;
            ispc4=1'b1;                     //��pc+4��ֵ����RegFiles(rd)
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
            usepc=opcode[5]?1'b0:1'b1;       //ǰ�ߞ�luiָ����ߞ�auipcָ��
            aluOP=opcode[5]?4'b1110:4'b1111;                
        end
   end
   initial 
        $monitor($time,,"��ǰָ����ͣ�R=%b,I=%b,B=%b,S=%b,J=%b,U=%b",R_type,I_type,B_type,S_type,J_type,U_type);
endmodule
