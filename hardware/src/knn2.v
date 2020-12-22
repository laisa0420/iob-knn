`timescale 1ns/1ps
`include "iob_lib.vh"


//Module to compute distances
module calc_distances 
    #(
    parameter DATA_W = 32,
    parameter K=4,
    parameter S=16,
    parameter N=10
    )
    (
     `INPUT(test_point, DATA_W),
     `INPUT(data_point, DATA_W),
     `OUTPUT(dist, DATA_W)
    );

    //Auxiliary signals
    `SIGNAL(X,S)
    `SIGNAL(Y,S)
    `SIGNAL(X2,DATA_W)
    `SIGNAL(Y2,DATA_W)

    //Output signal conversion
    `SIGNAL(D,DATA_W)


    `COMB begin
        X = test_point[31:15]- data_point[31:15];
        X2 = X*X;
        Y = test_point[15:0]- data_point[15:0];
        Y2 = Y*Y;
        D = X2 + Y2;
    end

endmodule


//Module to identify minimum of two numbers

module cmp_max
    #(
    parameter DATA_W = 32,
    parameter K=4,
    parameter S=16,
    parameter N=10
    )
    (
    `INPUT(Neib_reg,K*2*DATA_W),
    `OUTPUT(new_worst,2*DATA_W+2)
    );

    `SIGNAL(A,DATA_W)
    `SIGNAL(B,DATA_W)
    `SIGNAL(C,DATA_W)
    `SIGNAL(D,DATA_W)
    `SIGNAL(c1, 2*DATA_W+2)
    `SIGNAL(c2, 2*DATA_W+2)
    `SIGNAL(c3, 2*DATA_W+2)
    `SIGNAL(c4, 2*DATA_W+2)
    `SIGNAL(c5, 2*DATA_W+2)
    `SIGNAL(c6, 2*DATA_W+2)
    `SIGNAL2OUT(new_worst, c6)


    `COMB begin
        D = Neib_reg[2*DATA_W-1:0];
        C = Neib_reg[4*DATA_W-1:2*DATA_W];
        B = Neib_reg[6*DATA_W-1:4*DATA_W];
        A = Neib_reg[8*DATA_W-1:6*DATA_W];

        c1 <= (A[DATA_W-1:0] > B[DATA_W-1:0])?{A,2'b00}:{B,2'b01};
        c2 <= (B[DATA_W-1:0] > C[DATA_W-1:0])?{B,2'b01}:{C,2'b10};
        c3 <= (C[DATA_W-1:0] > D[DATA_W-1:0])?{C,2'b10}:{D,2'b11};
        c4 = (c1[DATA_W+1:2] > c2[DATA_W+1:2])?c1:c2;
        c5 = (c2[DATA_W+1:2] > c3[DATA_W+1:2])?c2:c3;
        c6 = (c4[DATA_W+1:2] > c5[DATA_W+1:2])?c4:c5;
    end 


endmodule

module det_min 
    #(
    parameter DATA_W = 32,
    parameter K=4,
    parameter S=16,
    parameter N=10
    )
    (
    `INPUT(index, DATA_W),
    `INPUT(dist, DATA_W), 
    `INPUT(worst_n, 2*DATA_W+2),
    `OUTPUT(new_n, 2*DATA_W)
    );

    `SIGNAL(internal, 2*DATA_W)
    `SIGNAL2OUT(new_n,internal)

    `COMB  begin
        internal <= (dist < worst_n[DATA_W+1-:2])?{index,dist}:worst_n[DATA_W+1:2];
    end
endmodule

module shift 
    #(
    parameter DATA_W = 32,
    parameter K=4,
    parameter S=16,
    parameter N=10
    )
    (
    `INPUT(clk,1),
    `INPUT(rst,1),
    `INPUT(en,1),
    `INPUT(d,DATA_W),
    `OUTPUT(OUT,N*DATA_W)
    );

    `SIGNAL(tmp, N*DATA_W)
    `SIGNAL2OUT(OUT,tmp)

    always @ (posedge clk)
        if (rst)
            tmp <= 0;
        else begin
            if (en)
                tmp <= d; //shift right
            else
                tmp <= tmp;
        end       
          
endmodule 

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
    `INPUT(T_POINT, DATA_W),
    `INPUT(D_POINT1, DATA_W),
    `INPUT(D_POINT2, DATA_W),
    `INPUT(D_POINT3, DATA_W),
    `INPUT(D_POINT4, DATA_W),
    `INPUT(D_POINT5, DATA_W),
    `INPUT(D_POINT6, DATA_W),
    `INPUT(D_POINT7, DATA_W),
    `INPUT(D_POINT8, DATA_W),
    `INPUT(D_POINT9, DATA_W),
    `INPUT(D_POINT10, DATA_W),
    `OUTPUT(NB, 2*K*DATA_W)   
    );
    
    
    `SIGNAL(data,N*DATA_W)
    `SIGNAL(reg_in,N*DATA_W)
    `SIGNAL(X,N*S)    
    `SIGNAL(Y,N*S)
    `SIGNAL(X2,N*DATA_W)    
    `SIGNAL(Y2,N*DATA_W)
    `SIGNAL(d_int,DATA_W)
    `SIGNAL(cnt_data, 4)
    
    //Data register signals

    `SIGNAL_OUT(data_in,N*DATA_W)
    `SIGNAL(data_out,N*DATA_W)
    `SIGNAL(en_data,1)
    
    //Neighbours register signals
    `SIGNAL_OUT(nb_in,K*2*DATA_W)

    `SIGNAL(nb_out,K*2*DATA_W)
    `SIGNAL(en_nb,1)

    //Distances register signals
    `SIGNAL_OUT(dist_in,N*DATA_W)
    
    `SIGNAL(dist_out,N*DATA_W)
    `SIGNAL(en_dist,1)

    //Signals and register to hold the worst neighbour
    `SIGNAL_OUT(worst_n_in,2*DATA_W+2)

    `SIGNAL(worst_n_out,2*DATA_W+2)
    `SIGNAL(en_worst,1)
    `REG_RE(clk, rst, 'b1, en_worst, worst_n_out, worst_n_in)

    `SIGNAL2OUT(NB,nb_out)


    `SIGNAL(cnt, DATA_W)

    `COUNTER_RE(clk, rst, cnt != N, cnt)


    
    //Put all data points in one register
    //Initialization of neighbours register 
    //initial data_in={,D_POINT9,D_POINT8,D_POINT7,D_POINT6,D_POINT5,D_POINT4,D_POINT3,D_POINT2,D_POINT1};
    assign nb_in='b1;
   

    //Data point register
    `REG_RE(clk, rst, 'b0, cnt != N, data_out, data_in)
 
    //Neighbour register
    `REG_RE(clk, rst, 'b1, cnt != N, nb_out, nb_in)
      
    //Distances register
    `REG_RE(clk, rst, 'b0, cnt != N, dist_out, dist_in)


    genvar i;

    generate
        for (i = 0; i < N; i = i + 1) begin
            calc_distances dists (T_POINT, data_out[(i+1)*DATA_W-1:i*DATA_W], dist_in[(i+1)*DATA_W-1:i*DATA_W]);
        end
    endgenerate

    det_min new_n (cnt, dist_out[DATA_W-1:0],worst_n_out,nb_in[2*DATA_W-1:0]);        
    cmp_max det_new_worst (nb_out, worst_n_in);  

    
      
endmodule

