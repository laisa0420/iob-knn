`timescale 1ns / 1ps
`include "iob_lib.vh"

`define DATA_W  32


module circuit_tb;

 `CLOCK(clk, 10)
 `RESET(rst, 1, 10)
 `SIGNAL(en, 1)
 `SIGNAL(test_p, `DATA_W)
 `SIGNAL(data_p, 40)
 `SIGNAL_OUT(out, 40)

   initial begin
        $dumpfile("circuit.vcd");
        $dumpvars();

   @(negedge rst);
      @(posedge clk) #1 en= 0;
      test_p = 32'b0000000000000110000000000000010;
      en = 1;
      data_p = 40'b0000000000001011000000000000101100000001;
      $write("Ax = 3\nAy = 2\nBx = 11\nBy = 11\n");
    

      @(posedge clk) #1 en = 1;
      data_p = 40'b0000000000001000000000000000100000000001;
      $write("Ax = 3\nAy = 2\nBx = 8\nBy = 8\n");

      @(posedge clk);
      data_p = 40'b0000000000000011000000000000001100000000;
      $write("Ax = 3\nAy = 2\nBx = 3\nBy = 3\n");

      @(posedge clk);
      data_p = 40'b0000000000000010000000000000001000000001;
      $write("Ax = 3\nAy = 2\nBx = 2\nBy = 2\n");

      @(posedge clk);
      data_p = 40'b0000000000000001000000000000000100000000;
      $write("Ax = 3\nAy = 2\nBx = 1\nBy = 1\n");

      @(posedge clk);
      data_p = 40'b0000000000000010000000000000000100000001;
      $write("Ax = 3\nAy = 2\nBx = 2\nBy = 1\n");

      @(posedge clk);
      data_p = 40'b0000000000001111000000000000101100000001;
      $write("Ax = 3\nAy = 3\nBx = 15\nBy = 11\n");

      @(posedge clk);
      data_p = 40'b0000000000000111000000000000011100000000;
      $write("Ax = 3\nAy = 2\nBx = 7\nBy = 7\n");


      $finish;
   end

   calc_insert
     #(
       .DATA_W(`DATA_W)
       )
   testaaaa
     (
      .test_point(test_p),
      .data_point(data_p),
      .clk(clk),
      .rst(rst),
      .enable(en),
      .neighbours(out)
      );

endmodule
