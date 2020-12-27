`timescale 1ns/1ps
`include "iob_lib.vh"


//Module to compute distances
module calc_distances 
    #(
    parameter DATA_W = 32,
    parameter K=4,
    parameter S=16,
    parameter N=10,
    parameter data_info=40
    )
    (
     `INPUT(test_point, DATA_W),
     `INPUT(data_point, data_info),
     `OUTPUT(dist, DATA_W)
    );

    //Auxiliary signals
    `SIGNAL(X,S)
    `SIGNAL(Y,S)
    `SIGNAL(X2,DATA_W)
    `SIGNAL(Y2,DATA_W)

    //Output signal conversion
    `SIGNAL(D,DATA_W)
    `SIGNAL2OUT(dist, D)

   
    `COMB begin
        X = test_point[DATA_W-1:15] - data_point[data_info-1:data_info-S-1];
        X2 = X*X;
        Y = test_point[15:0]- data_point[data_info-S-2:8];
        Y2 = Y*Y;
        D = X2 + Y2;
    end

endmodule

module comparator
    #(
    parameter DATA_W = 32,
    parameter K=4,
    parameter S=16,
    parameter N=10,
    parameter data_info=40
    )
    (
     `INPUT(A, DATA_W),
     `INPUT(B, data_info),
     `OUTPUT(C,1)
    );

    `SIGNAL(aux, 1)
    `SIGNAL2OUT(C,aux)

    `COMB aux = (A<B[data_info-1:data_info-DATA_W-1]?1:0);
    

endmodule



module calc_insert
    #(  
    parameter DATA_W = 32,
    parameter K=4,
    parameter S=16,
    parameter N=10,
    parameter data_info=40
    )
    (
     `INPUT(test_point, DATA_W),
     `INPUT(data_point, data_info),
     `INPUT(clk, 1),
     `INPUT(rst, 1),
     `INPUT(enable, 1),
     `OUTPUT(neighbours, data_info)
    );



    reg [data_info-1:0] neighregin [K-1:0];
    reg [data_info-1:0] neighregout [K-1:0];
    wire [data_info-1:0] neighwireout [K-1:0];


    `SIGNAL_OUT(en_neigh, 1)
    `SIGNAL(en_neigh_reg, 1)

    assign en_neigh_reg = 'b0;
    assign en_neigh = en_neigh_reg;


    
    `SIGNAL(cnt, S)

    `SIGNAL_OUT(distance, DATA_W)


    `SIGNAL_OUT(compout, DATA_W)
    `SIGNAL_OUT(compout1, DATA_W)

    `REG_RE(clk, rst, 'b1, en_neigh, neighregout[cnt],neighregin[cnt])
    
    `COUNTER_RE(clk, rst, en_neigh != 'b1, cnt)

    calc_distances dists (test_point, data_point, distance);    


    comparator comp (distance,neighregout[cnt],en_neigh);
    integer i;


    `COMB begin    


        if (en_neigh == 1) begin 
            for (i = K-1; i > cnt ; i = i-1) begin
            neighregin[i] = neighregin[i-1];
            end
            neighregin[cnt] = {distance,data_point[7:0]};
        end
    end

    


endmodule

