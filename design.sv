// DESIGN FSM

module fsm(input logic clk, rst, a, b, c, d,
	    output logic finished);
  
  
  typedef enum {INIT, S0,S1,S2,S3} state_t;
  state_t curr_state,next_state;

  
  always_ff @(posedge clk or posedge rst) begin
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
      
      //S1 to INIT state change has been included by us inorder to avoid Deadlock and Livelock.
      //Here we used signal 'd' as this has not been used for any other state transition.
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
      // Tying default states to INIT or these can be formed as Don't care state and might pave way for inserting trojan
    endcase    
  end

assign finished = (curr_state == S3)?1'b1: 1'b0;
  
endmodule

//TOP MODULE
module top(input logic rst,clk,a,b,c,d,
          output logic finished);
  fsm U_FSM(.rst(rst),.clk(clk),.a(a),.b(b),.c(c),.d(d), .finished(finished));
endmodule 
