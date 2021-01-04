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



   wire [K*data_info-1:0] nb_list_regin [K-1:0];
    //wire [K*data_info-1:0] nb_list_regout [K-1:0];
    



   /*alterações malta para generate muitos modulos*/
   genvar j;
  generate 
  for (j = 0;j<K ;j = j+1 ) begin
    top_circuit knn_core
        (
        .knn_start(KNN_START),  
        .clk(clk),
        .rst(KNN_RESET),
        .test_point(BANK_TESTP[j]),
        .data_point(DATAP_REG), 
        .label(LABEL_REG),
        .enable(KNN_ENABLE),
        .valid(valid),
        .wstrb(wstrb),
        .nb_list(nb_list_regin[j])
        //.saida(OUT_REG)
        );
        //`REG_RE(clk, rst, '1, 'b1, nb_list_regout[j],nb_list_regin[j])
    labelconverter knn_coverter
        (
        .a_input(nb_list_regin[j]),
        .b_output(BANK_LABELS[j])
        );
        
        end
        
  endgenerate
   
   //ready signal   
   `SIGNAL(ready_int, 1)
   `REG_AR(clk, rst, 0, ready_int, valid)

   `SIGNAL2OUT(ready, ready_int)

   //rdata signal
   //`COMB begin
   //end
      
endmodule



  


module labelconverter
    #(
    parameter DATA_W = 32,
    parameter K=4,
    parameter S=16,
    parameter N=10,
    parameter data_info=40
    )
    (
     `INPUT(a_input, 160), //falta parametrizar 159:0
     `OUTPUT(b_output,32) //8*4=32
    );

    wire [7:0] aux [K-1:0];
    `SIGNAL(labels, K*8)
    `SIGNAL2OUT(b_output,labels)

     genvar x;
     integer i;
      generate
        for (x = 0 ;x <K ;x=x+1) begin //NUMERO DE LABELS
        //x=3 || x=2 || x=1
          label_calculator get_label (a_input[((x+1)*data_info - 1) : (x*data_info)],aux[x]);
          
          //159:159-DATA_W cagar ->159-DATA_W-1:159-DATA_W-1-8        
        end
        //x=0
    endgenerate
    `COMB begin
      for ( i = 0; i< K; i = i+1) begin
        labels = {labels,aux[i]};
      end
    end 
endmodule


module label_calculator
    #(
    parameter DATA_W = 32,
    parameter K=4,
    parameter S=16,
    parameter N=10,
    parameter data_info=40
    )
    (
     `INPUT(distance_input, data_info), //falta parametrizar 159:0
     `OUTPUT(label_output,8) //8*4=32
    );

    `SIGNAL(aux, 8)
    `SIGNAL2OUT(label_output,aux)

    `COMB begin
        aux = distance_input[(data_info - DATA_W - 1) : (data_info - DATA_W - 8)];
    end 

endmodule