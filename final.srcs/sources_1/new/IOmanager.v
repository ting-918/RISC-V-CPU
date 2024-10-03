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
    input[2:0] type,                //DataRAM讀寫類型
    input[7:0] maddr,               //[7:6]判斷是否為對外設的操作、[5:0]為訪問DataRAM的內存地址
    input[3:0] switch,              //從外設讀入的數據
    input[31:0] wdata,              //store數據(從cpu輸出的數據):去向1.寫入DataRAM(mwdata) 去向2.外設輸出(result)
    output[31:0] data,              //load數據(輸入cpu的數據):來源1.DataRAM讀入(mdata) 來源2.外設讀入(switch)
    output reg[31:0] result         //外設輸出結果
);
    wire[31:0] mdata;               //從DataRAM讀入的數據
    wire[31:0] mdata_with_type;     //經類型處理後的DataRAM讀入數據
    wire[31:0] mwdata;              //寫入DataRAM的數據(經類型處理)
    wire mwe;                       //DataRAM的寫使能端(僅在"並非對外設的操作"且"IOmanager的寫使能端有效"時有效)
    assign mwe=~(|maddr[7:6])&we; 

    //對外設的操作
    always @(posedge clk)                                 //maddr[7]==1,通過store進行外設輸出
        if(we&&maddr[7])
            result<=wdata; 
    assign data=maddr[6]?{28'h0,switch}:mdata_with_type;  //maddr[6]==1,通過load進行外設輸入

    //對DataRAM的操作
    assign mwdata = {32{mwe}}&({24'b0,{8{~type[0]}}}|   //sb
                               {16'b0,{16{type[0]}}}|   //sh
                               {32{type[1]}})&wdata;    //sw

    assign mdata_with_type = ({32{~type[0]}}&{{24{~type[2]}}&{24{mdata[7]}},{8{~type[0]}}}|   //lb,lbu
                              {32{type[0]}}&{{16{~type[2]}}&{16{mdata[15]}},{16{type[0]}}}|   //lh,lhu
                              {32{type[1]}})&mdata;                                           //lw
    DataRAM myDataRAM(.a(maddr[5:0]),.clk(clk),.we(mwe),.d(mwdata),.spo(mdata));
    initial 
        $monitor($time,,"存儲器寫:寫使能端=%b, 類型:%b, RAM[%d]=%h",mwe,type[1:0],maddr[5:0],mwdata);
    initial 
        $monitor($time,,"存儲器讀:讀使能端=%b, 類型:%b, RAM[%d]=%h",~mwe,type,maddr[5:0],mdata_with_type);

endmodule