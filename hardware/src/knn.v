`timescale 1ns/1ps
`include "iob_lib.vh"


//Module to compute distances
module calc_distances 
    #(
    parameter DATA_W = 32,
    parameter K=4,
    parameter S=16,
    parameter N=10
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

   
    `COMB begin
        X = test_point[DATA_W-1:15] - data_point[data_info-1:data_info-S-1];
        X2 = X*X;
        Y = test_point[15:0]- data_point[data_info-S-2:8];
        Y2 = Y*Y;
        D = X2 + Y2;
    end

endmodule



module calc_insert
    #(  
    parameter DATA_W = 32,
    parameter K=4,
    parameter S=16,
    parameter N=10
    parameter data_info=40
    )
    (
     `INPUT(test_point, DATA_W),
     `INPUT(data_point, data_info),
     `INPUT(clk, 1),
     `INPUT(rst, 1),
     `INPUT(enable, 1),
     `OUTPUT(neigbours, data_info)
    );



    reg [data_info-1:0] neighregin [K-1:0];
    reg [data_info-1:0] neighregout [K-1:0];
    wire [data_info-1:0] neighwireout [K-1:0];


    `SIGNAL_OUT(en_neigh, 1)

    `SIGNAL_OUT(distance, DATA_W)


    `SIGNAL_OUT(compout, DATA_W)
    `SIGNAL_OUT(compout1, DATA_W)


    calc_distances dists (test_point, data_point,distance);    


    always @(posedge clk) begin
        for (i = 0; i < K && en_neigh == 0; i = i + 1) 
            begin
                comparator comp(distance,neighregout[i],en_neigh); 
                neighregin[K-1:i+1] = neighregin[K-2:i];
                neighregin[i] = {distance,data_point[7:0]}    

            end
    end

    `REG_RE(clk, rst, '1', en_neigh, neighregout ,neighregin)


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
     `OUTPUT(C, DATA_W)
    );

    `COMB C = (A<B[data_info-1:data_info-DATA_W-1]?1:0);
    

endmodule