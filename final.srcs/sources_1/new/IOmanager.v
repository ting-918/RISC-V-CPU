`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/14 15:12:51
// Design Name: 
// Module Name: IOmanager
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

module IOmanager (
    input clk,
    input we,
    input[2:0] type,                //DataRAM�x�����
    input[7:0] maddr,               //[7:6]�Д��Ƿ�錦���O�Ĳ�����[5:0]���L��DataRAM�ăȴ��ַ
    input[3:0] switch,              //�����O�x��Ĕ���
    input[31:0] wdata,              //store����(��cpuݔ���Ĕ���):ȥ��1.����DataRAM(mwdata) ȥ��2.���Oݔ��(result)
    output[31:0] data,              //load����(ݔ��cpu�Ĕ���):��Դ1.DataRAM�x��(mdata) ��Դ2.���O�x��(switch)
    output reg[31:0] result         //���Oݔ���Y��
);
    wire[31:0] mdata;               //��DataRAM�x��Ĕ���
    wire[31:0] mdata_with_type;     //�����̎�����DataRAM�x�딵��
    wire[31:0] mwdata;              //����DataRAM�Ĕ���(�����̎��)
    wire mwe;                       //DataRAM�Č�ʹ�ܶ�(�H��"�K�ǌ����O�Ĳ���"��"IOmanager�Č�ʹ�ܶ���Ч"�r��Ч)
    assign mwe=~(|maddr[7:6])&we; 

    //�����O�Ĳ���
    always @(posedge clk)                                 //maddr[7]==1,ͨ�^store�M�����Oݔ��
        if(we&&maddr[7])
            result<=wdata; 
    assign data=maddr[6]?{28'h0,switch}:mdata_with_type;  //maddr[6]==1,ͨ�^load�M�����Oݔ��

    //��DataRAM�Ĳ���
    assign mwdata = {32{mwe}}&({24'b0,{8{~type[0]}}}|   //sb
                               {16'b0,{16{type[0]}}}|   //sh
                               {32{type[1]}})&wdata;    //sw

    assign mdata_with_type = ({32{~type[0]}}&{{24{~type[2]}}&{24{mdata[7]}},{8{~type[0]}}}|   //lb,lbu
                              {32{type[0]}}&{{16{~type[2]}}&{16{mdata[15]}},{16{type[0]}}}|   //lh,lhu
                              {32{type[1]}})&mdata;                                           //lw
    DataRAM myDataRAM(.a(maddr[5:0]),.clk(clk),.we(mwe),.d(mwdata),.spo(mdata));
    initial 
        $monitor($time,,"�惦����:��ʹ�ܶ�=%b, ���:%b, RAM[%d]=%h",mwe,type[1:0],maddr[5:0],mwdata);
    initial 
        $monitor($time,,"�惦���x:�xʹ�ܶ�=%b, ���:%b, RAM[%d]=%h",~mwe,type,maddr[5:0],mdata_with_type);

endmodule