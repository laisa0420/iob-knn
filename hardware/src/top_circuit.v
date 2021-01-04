`timescale 1ns / 1ps
`include "iob_lib.vh"


module top_circuit
	#(
	parameter DATA_W = 32,
	parameter K=4,
	parameter S=16,
	parameter N=10,
	parameter data_info=40
	)
	(
  `INPUT(knn_start, 1),
	`INPUT(clk, 1),
	`INPUT(rst, 1),
	`INPUT(test_point, DATA_W),
	`INPUT(data_point, DATA_W),
  `INPUT(label, 8),
	`INPUT(enable, 1),
	`INPUT(valid, 1),
	`INPUT(wstrb, 4),
	`OUTPUT(nb_list, K*data_info)
  //`OUTPUT(saida, DATA_W)
	);

	
	`SIGNAL_OUT(en_dist, 1)
	`SIGNAL_OUT(en_nb, 1)
	`SIGNAL_OUT(insert, 1)
	`SIGNAL_OUT(start_cnt,1)
	`SIGNAL_OUT(inc_cnt,1)
	`SIGNAL_OUT(cnt_flag,1)
  //`SIGNAL(saida_in, DATA_W)
  //`SIGNAL2OUT(saida, saida_in)

  //`COMB
  //saida_in = 32'b1;


 calc_insert test
     (
      .test_point(test_point),
      .data_point(data_point),
      .label(label),
      .clk(clk),
      .rst(rst),
      .enable(enable),
      .en_dist(en_dist),
      .en_nb(en_nb),
      .start_cnt(start_cnt),
      .inc_cnt(inc_cnt),
      .insert(insert),
      .nb_list(nb_list),
      .cnt_flag(cnt_flag)
      );

 control_unit control_tb
     (
     .knn_start(knn_start),  
     .rst(rst),
     .clk(clk),
     .insert(insert),
     .valid(valid),
     .wstrb(wstrb),
     .cnt_flag(cnt_flag),
     .en_dist(en_dist),
     .en_nb(en_nb),
     .start_cnt(start_cnt),
     .inc_cnt(inc_cnt)
      );

endmodule
