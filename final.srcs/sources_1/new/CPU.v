`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/14 15:14:31
// Design Name: 
// Module Name: CPU
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
module CPU (
    input clk,
    input rst,
    input[3:0] n,
    output[31:0] result
);
    wire[31:0] addr,ins;                     //ȡָ��
    reg[31:0] next;
    wire[4:0] rs1,rs2,rd;                    //�g�a
    wire[31:0] exp_imm12,exp_imm20;
    wire[6:0] opcode;
    wire[2:0] func;
    wire dis,c,isimm,ismem,ispc4,usepc,rwe,mwe;    //������̖
    wire[1:0] pcs;
    wire[3:0] aluOP;
    wire[2:0] type;
    wire[31:0] rdata1,rdata2;                //RegFiles�x��
    reg[31:0] temp_rwdata;
    wire[31:0] rwdata,f;
    reg[31:0] a,b;                           //ALU�\��
    wire[31:0] mdata;                        //���O��DataRAM�x��Ĕ���
    wire[7:0] maddr;
    wire U_type;                             //U�ָ�0x10111
    assign maddr=f[7:0];
    assign U_type=~opcode[6]&opcode[4]&~opcode[3]&(&opcode[2:0]);    
    always @(*)
    begin
        //ALU��b�ā�Դ��(1)exp_imm20 (2)exp_imm12 (3)�Ĵ����x�˿�2�Ĕ���rdata2
        //ֻ��U�ָ������exp_imm20����Ӌ��
        if(isimm)
        begin
            if(U_type)
                b=exp_imm20;
            else
                b=exp_imm12;
         end
         else
            b=rdata2;
         //����Ĵ����Ĕ�����Դ��(1)pc+4 (2)IOmanagerݔ��Ĕ���mdata (3)ALU���\��Y��f
         if(ispc4)
            temp_rwdata=addr+4;
         else
         begin
            if(ismem)
                temp_rwdata=mdata;
            else
                temp_rwdata=f;
         end
         //ALU��a�ā�Դ��(1)pc (2)�Ĵ����x�˿�1�Ĕ���rdata1
        //ֻ��auipcָ������pc����Ӌ��
         if(usepc)
            a=addr;
         else
            a=rdata1;
        //�lָ���ַ��Դ
        case(pcs)                               
            2'b00:next=addr+4;                  //������
            2'b01:next=addr+(exp_imm12<<1);     //B����D
            2'b10:next=addr+(exp_imm20<<1);     //jal
            2'b11:next={f[31:1],1'b0};          //jalr
        endcase
    end
    assign rwdata=temp_rwdata;
    PC myPC(.rst(rst),.clk(clk),.next(next),.addr(addr));
    ID myID(.ins(ins),.rs1(rs1),.rs2(rs2),.rd(rd),.opcode(opcode),.func(func),.dis(dis),.exp_imm12(exp_imm12),.exp_imm20(exp_imm20));
    CU myCU(.opcode(opcode),.func(func),.dis(dis),.c(c),.pcs(pcs),.aluOP(aluOP),.type(type),.rwe(rwe),.mwe(mwe),.isimm(isimm),.ismem(ismem),.ispc4(ispc4),.usepc(usepc));
    RegFiles myRegFiles(.clk(clk),.raddr1(rs1),.raddr2(rs2),.waddr(rd),.rdata1(rdata1),.rdata2(rdata2),.wdata(rwdata),.we(rwe));
    ALU myALU(.a(a),.b(b),.op(aluOP),.f(f),.c(c));
    IOmanager myIOmanager(.clk(clk),.we(mwe),.type(type),.maddr(maddr),.wdata(rdata2),.data(mdata),.switch(n),.result(result));
    insROM myROM(.a(addr),.spo(ins));
    initial 
        $monitor($time,,"��ǰָ���ַaddr��%h",addr);
    initial 
        $monitor($time,,"��ǰָ��C���ains��%h",ins);
    initial 
        $monitor($time,,"�Ĵ���������ʹ�ܶ�=%b,Reg[%d]=%h ",rwe, rd, rwdata );                   
    initial 
        $monitor($time,,"�Ĵ����x���˿�1=Reg[%d]=%h �˿�2=Reg[%d]=%h ",rs1, rdata1, rs2, rdata2 );  
    initial 
        $monitor($time,,"������(��̖�Uչ��)��imm12=%h, imm20=%h ",exp_imm12, exp_imm20 );
    initial 
        $monitor($time,,"�lָ���Դpcs��%b",pcs );
    initial 
        $monitor($time,,"���D�l��c��%b",c );
endmodule