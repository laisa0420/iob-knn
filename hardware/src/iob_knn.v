`timescale 1ns/1ps
`include "iob_lib.vh"
`include "interconnect.vh"
`include "iob_knn.vh"

module iob_knn 
  #(
    parameter ADDR_W = `KNN_ADDR_W, //NODOC Address width
    parameter DATA_W = `DATA_W, //NODOC Data word width
    parameter WDATA_W = `DATA_W, //NODOC Data word width on writes
    parameter K = 4,
    parameter data_info = 40
    )
   (
`include "cpu_nat_s_if.v"
`include "gen_if.v"
    );

//BLOCK Register File & Configuration, control and status registers accessible by the sofware
`include "KNNsw_reg.v"
`include "KNNsw_reg_gen.v"

    //combined hard/soft reset 
   `SIGNAL(rst_int, 1)
   `COMB rst_int = rst | KNN_RESET;

   //write signal
   `SIGNAL(write, 1) 
   `COMB write = | wstrb;

   `SIGNAL_OUT(nb_list,K*data_info)
   //
   //BLOCK 64-bit time counter & Free-running 64-bit counter with enable and soft reset capabilities
   //
   //`SIGNAL_OUT(KNN_VALUE, 2*DATA_W)

   top_circuit knn_core
     (
      .clk(clk),
      .rst(KNN_RESET),
      .test_point(TESTP),
      .data_point(DATAP_REG), 
      .label(LABEL_REG),
      .enable(KNN_ENABLE),
      .valid(valid),
      .wstrb(wstrb),
      .nb_list(nb_list),
      .saida(OUT_REG)
      );
   
   
   //ready signal   
   `SIGNAL(ready_int, 1)
   `REG_AR(clk, rst, 0, ready_int, valid)

   `SIGNAL2OUT(ready, ready_int)

   //rdata signal
   //`COMB begin
   //end
      
endmodule

