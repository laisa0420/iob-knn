`timescale 1ns/1ps
`include "iob_lib.vh"

module knn_core
  #(
    parameter DATA_W = 32,
    parameter K=4,
    parameter S=16,
    parameter N=10
    )
   (
    `INPUT(KNN_ENABLE, 1),    
    `INPUT(clk, 1),
    `INPUT(rst, 1),
    `INPUT(A, DATA_W),
    `INPUT(B, DATA_W),
    `OUTPUT(D, DATA_W)   
    );
    
    `SIGNAL(count,DATA_W)
    `SIGNAL(data,N*DATA_W)
    `SIGNAL(reg_in,N*DATA_W)
    `SIGNAL(X,S)    
    `SIGNAL(Y,S)
    `SIGNAL(X2,DATA_W)    
    `SIGNAL(Y2,DATA_W)
    `SIGNAL(d_int,DATA_W)
    
    `SWREG_W(d, DATA_W, 1'b0)
    `SIGNAL2OUT(D,d_int)
    
    
    `COMB begin
    	X=A[32:16]-B[32:16];
    	X2=X*X;
    	Y=A[15:0]-B[15:0];
    	Y2=Y*Y;
    	d_int=X2+Y2;
    end
    


      
endmodule

