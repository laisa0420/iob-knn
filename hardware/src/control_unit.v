`timescale 1ns / 1ps
`include "iob_lib.vh"

module control_unit
	#(
	  parameter state0 = 'd0,
	  parameter state1 = 'd1,
	  parameter state2 = 'd2,
	  parameter state3 = 'd3,
	  parameter state4 = 'd4
	 )
	(
	 `INPUT(rst, 1),
	 `INPUT(clk, 1),
	 `INPUT(insert,1),
	 `INPUT(valid, 1),
	 `INPUT(wstrb, 4),
	 `INPUT(cnt_flag, 1),
	 `OUTPUT(en_dist, 1), 
	 `OUTPUT(en_nb, 1), 
	 `OUTPUT(start_cnt,1),
	 `OUTPUT(inc_cnt,1)
	);

	//adicionar "start" para quando todos os test_points estiverem carregados

	`SIGNAL(current_state, 3)
	`SIGNAL(next_state, 3)
	`SIGNAL(en_nb_aux, 1)
	`SIGNAL2OUT(en_nb, en_nb_aux)
	`SIGNAL(en_dist_aux, 1)
	`SIGNAL2OUT(en_dist, en_dist_aux)
	`SIGNAL(start_cnt_aux,1)
	`SIGNAL2OUT(start_cnt, start_cnt_aux)
	`SIGNAL(inc_cnt_aux,1)
	`SIGNAL2OUT(inc_cnt, inc_cnt_aux)



	always @(posedge clk or posedge rst) begin : proc_
		if(rst) 
			current_state = state0;
		else 
			current_state = next_state;
	end

	
	`COMB begin : define_states
		
		//lÊ test point
		case (current_state)
			state0: begin 
				en_nb_aux = 'b0;
				if (wstrb && valid)
					next_state = state1;
				else next_state = current_state;
			end
			//data point
			state1: begin 
				en_nb_aux = 'b0;
				if (wstrb && valid)
					next_state = state2;
				else next_state = current_state;
			end
			//label e guarda a distancia
			state2: begin 
				start_cnt_aux = 'b1;
				en_dist_aux ='b1;
				if (wstrb && valid)
					next_state = state3;
				else next_state = current_state;
			end
			//compara
			state3: begin 
				start_cnt_aux = 'b0;
				en_dist_aux ='b0;
				next_state = state4;
			end
			//insere
			state4: begin 
				if (insert) begin
					en_nb_aux = 'b1;
					next_state = state1;
				end
				else if (cnt_flag == 1)
					next_state = state1;
				else 
					inc_cnt_aux = 'b1;								
			end

			default : next_state = state0;
		endcase
	end
endmodule 

/* S4: se não inserir e o cnt != K, mandar incrementar o cnt
endmodule */