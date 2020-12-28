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
     `INPUT(en_tp, 1),
     `INPUT(en_dp, 1),
     `INPUT(en_dist, 1),
     `INPUT(en_nb, 1),
     `OUTPUT(insert, 1)
    );



    reg [data_info-1:0] nbregin [K-1:0];
    reg [data_info-1:0] nbregout [K-1:0];
    wire [data_info-1:0] nbwireout [K-1:0];

    
    `SIGNAL(cnt, S)

    `SIGNAL(dist_out, DATA_W)
    `SIGNAL_OUT(dist_in, DATA_W)

    `SIGNAL(tp_in, DATA_W)
    `SIGNAL(tp_out, DATA_W)
    
    `SIGNAL(dp_in, data_info)
    `SIGNAL(dp_out, data_info

    `REG_RE(clk, rst, 'b1, en_tp, tp_out,tp_in)
    `REG_RE(clk, rst, 'b1, en_dp, dp_out,dp_in)
    `REG_RE(clk, rst, 'b1, en_nb, nbregout[cnt],nbregin[cnt])
    `REG_RE(clk, rst, 'b0, en_dist, dist_out,dist_in)

    
    `COUNTER_RE(clk, rst, en_nb != 'b1, cnt)

    calc_distances dists (test_point, dp_out, dist_in);    


    comparator comp (dist_out,nbregout[cnt],insert);
    integer i;


    `COMB begin    


        if (en_nb == 1) begin 
            for (i = K-1; i > cnt ; i = i-1) begin
            nbregin[i] = nbregin[i-1];
            end
            nbregin[cnt] = {dist_out,dp_out[7:0]};
        end
    end

    


endmodule

