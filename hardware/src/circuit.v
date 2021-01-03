`timescale 1ns / 1ps
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
     `INPUT(data_point, DATA_W),
     `OUTPUT(result, DATA_W)
    );

    //Auxiliary signals
    `SIGNAL_SIGNED(X,S)
    `SIGNAL_SIGNED(Y,S)
    `SIGNAL_SIGNED(X2,DATA_W)
    `SIGNAL_SIGNED(Y2,DATA_W)

    //Output signal conversion
    `SIGNAL(D,DATA_W)
    `SIGNAL2OUT(result, D)

   
    `COMB begin
        X = test_point[DATA_W-1:S] - data_point[DATA_W-1:S];
        X2 = X*X;
        Y = test_point[S-1:0]- data_point[S-1:0];
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

    `COMB aux = (A<B[data_info-1:data_info-DATA_W]?1:0);    

endmodule


module calc_insert
    #(  
    parameter DATA_W = 32,
    parameter K=4,
    parameter S=16,
    parameter N=10,
    parameter data_info = 40,
    parameter C=8
    )
    (
     `INPUT(test_point, DATA_W),
     `INPUT(data_point, DATA_W),
     `INPUT(label, C),
     `INPUT(clk, 1),
     `INPUT(rst, 1),
     `INPUT(enable, 1),
     `INPUT(en_dist, 1),
     `INPUT(en_nb, 1),
     `INPUT(start_cnt,1),
     `INPUT(inc_cnt,1),
     `OUTPUT(insert, 1),
     `OUTPUT(nb_list, K*DATA_W),
     `OUTPUT(cnt_flag,1)
    );

    reg [data_info-1:0] nbregin [K-1:0];
    reg [data_info-1:0] nbregout [K-1:0];
//  wire [data_info-1:0] nbwireout [K-1:0];

    
    `SIGNAL(cnt, S)

    `SIGNAL(nb_list_aux, K*data_info)
    `SIGNAL2OUT(nb_list, nb_list_aux)


    `SIGNAL(dist_out, DATA_W)
    `SIGNAL_OUT(dist_in, DATA_W)

    `SIGNAL(cnt_flag_aux,1)
    `SIGNAL2OUT(cnt_flag, cnt_flag_aux)


    genvar a;

    generate
        for (a = 0; a < K; a = a+1) begin
            `REG_RE(clk, rst, '1, en_nb, nbregout[a],nbregin[a])          
        end
    endgenerate


    `REG_RE(clk, rst, 'b0, en_dist, dist_out,dist_in)    
    `COUNTER_RE(clk, start_cnt, (inc_cnt==1 && cnt != K-1), cnt)


    calc_distances dists (test_point, data_point, dist_in);    
    comparator comp (dist_out,nbregout[cnt],insert);

    integer i;
    integer j;


    `COMB begin    

        for (j = 0; j < K; j = j+1) 
        nb_list_aux = {nb_list_aux, nbregout[j]};

        if (en_nb == 1) begin 
            for (i = K-1; i > cnt ; i = i-1) begin
                nbregin[i]  = nbregout[i-1];
                nbregin[cnt] = {dist_out,label};
            end
        end
        if (cnt == K-1) 
            cnt_flag_aux = 'b1;
        else
            cnt_flag_aux = 'b0;
    end
    
endmodule



