`timescale 1ns/1ps
`include "iob_lib.vh"

module knn_core
  #(
    parameter DATA_W = 40,
    parameter K=4,
    parameter S=16,
    parameter N=10
    )
   (
    `INPUT(KNN_ENABLE, 1),    
    `INPUT(clk, 1),
    `INPUT(rst, 1),
    `INPUT(T_point, DATA_W),
    `INPUT(D_point1, DATA_W),
    `INPUT(D_point2, DATA_W),
    `INPUT(D_point3, DATA_W),
    `INPUT(D_point4, DATA_W),
    `INPUT(D_point5, DATA_W),
    `INPUT(D_point6, DATA_W),
    `INPUT(D_point7, DATA_W),
    `INPUT(D_point8, DATA_W),
    `INPUT(D_point9, DATA_W),
    `INPUT(D_point10, DATA_W),
    `OUTPUT(D, DATA_W)   
    );
    
    
    `SIGNAL(data,N*DATA_W)
    `SIGNAL(reg_in,N*DATA_W)
    `SIGNAL(X,S)    
    `SIGNAL(Y,S)
    `SIGNAL(X2,DATA_W)    
    `SIGNAL(Y2,DATA_W)
    `SIGNAL(d_int,DATA_W)
    `SIGNAL(cnt_data, 4)
    
    //Signal to have all data points
    `SIGNAL(All_data,10*DATA_W)
    
    //Neighbours signal
    `SIGNAL(neighbours_in,K*DATA_W)
    `SIGNAL(neighbours_out,K*DATA_W)
    
    `SWREG_W(d, DATA_W, 1'b0)
    `SIGNAL2OUT(D,d_int)
    
    `COUNTER_RE(clk, rst, (en & cnt1!=N), cnt_data+DATA_W)
    `COUNTER_RE(clk, rst, (en & cnt1!=N), cnt_n+DATA_W)
    
    //Put all data points in one register
    assign All_data={D_point1,D_point2,D_point3,D_point4,D_point5,D_point6,D_point7,D_point8,D_point9,D_point10};
    `REG_RE(clk, rst, 1'b0, 1, data_out, All_data)
    
    assign neighbours_in=(DATA_W*K)'b1;
    `REG_RE(clk, rst, 1'b0, 1, neighbours_out, neighbours_in)
    
    
    
    
    `COMB begin
    	X=T_point[32:16]-data_out[cnt_data+32:cnt_data+16];
    	X2=X*X;
    	Y=T_point[15:0]-data_out[cnt_data+15:cnt_data];
    	Y2=Y*Y;
    	d_int=X2+Y2;
    	
    	
    	always @(posedge CLK, posedge cnt_n){	
    	   if (d_int < neighbours_out[cnt_n+15:cnt_n])
    	      neighbours_out[cnt_n+15:0] >> DATA_W;
    	      neighbours_out[cnt_n+15:cnt_n]=
    	         
    	}
    	
    	
    end
    


      
endmodule

