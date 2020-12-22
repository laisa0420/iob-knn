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



module calc_insert
    #(  
    parameter DATA_W = 32,
    parameter K=4,
    parameter S=16,
    parameter N=10
    )
    (
     `INPUT(test_point, DATA_W),
     `INPUT(data_point, DATA_W),
     `INPUT(clk, 1),
     `INPUT(rst, 1),
     `INPUT(enable, 1),
     `OUTPUT(neigbours, )
    );



    reg [DATA_W-1:0] neighregin [K-1:0];
    reg [DATA_W-1:0] neighregout [K-1:0];
    wire [DATA_W-1:0] neighwireout [K-1:0];

    `SIGNAL_OUT(distance, DATA_W)
    `SIGNAL_OUT(compout, DATA_W)
    `SIGNAL_OUT(compout1, DATA_W)


    calc_distances dists (test_point, data_point,distance);    


    genvar i;   
    genvar j;   

    generate    
        for (i = 0; i < K; i = i + 1) 
            begin 
                generate
                    for (j = K-1; j = 0 ; j = j-1) begin
                        comparator comp(neighbours[i],neigbours[i+1],compout[i]);
                    end
                endgenerate
            end
        end
    endgenerate

    generate    
        for (j = K-1; j = 0 ; j = j-1)
            begin 
                generate
                    for (i = 0; i < K; i = i + 1) begin
                        comparator comp(neighbours[i],neigbours[i+1],compout[i]);
                    end
                endgenerate
            end
            comparator comp1(compout[i],compout[i+1],compout1[i]);
        end
    endgenerate


    




endmodule

module comparator
    #(
    parameter DATA_W = 32,
    parameter K=4,
    parameter S=16,
    parameter N=10
    )
    (
     `INPUT(A, DATA_W),
     `INPUT(B, DATA_W),
     `OUTPUT(C, DATA_W)
    );

    `COMB C = (A>B?A:B);
    

endmodule