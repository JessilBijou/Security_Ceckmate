module fsm(input logic clk, rst, a, b, c, d,
	    output logic finished);
  
  typedef enum {INIT, S0,S1,S2,S3} state_t;
  state_t curr_state,next_state;

  
  always_ff @(posedge clk) begin
    if(rst == 1'b1)
	curr_state <= INIT;
    else
	curr_state <= next_state;
 
  end
  
  always_comb begin
    next_state = curr_state;
    case(curr_state)
      INIT: begin
        if(!a  && !b && !c & !d) next_state = S0;
      end

      S0: begin
        if(b) next_state = S1;
        if(c) next_state = S2;
      end
      
      S1:begin
        if(d) next_state = INIT;
      end
      
      S2: begin
        if(b) next_state = S1;
        if(a) next_state = S3;
      end
      
      S3: begin
        if(!a) next_state = S2;
      end
      default: next_state = INIT;
    endcase    
  end

assign finished = (curr_state == S3)?1'b1: 1'b0;
  
endmodule
