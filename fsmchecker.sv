--Jessil--
module fsm_checker #() (
  input logic rst,clk,a,b,c,d,finished
);
  
  logic [2:0] fsm_state;
  typedef enum logic [2:0] {INIT,S0,S1,S2,S3} state_t;
  assign fsm_state = dut.U_FSM.curr_state;

  
// This property checks FSM transition from one state to another state.
property prop_a_causes_b_check (clk, a, b, delay, kill);
    @(posedge clk) disable iff (kill)
    a |-> ##[1:delay] b;
endproperty : prop_a_causes_b_check

  
// This property checks the output
property prop_fsm_out_check (clk, condition, signal, signal_val, kill);
    @(posedge clk) disable iff (kill)
    condition |-> (signal==signal_val);
endproperty : prop_fsm_out_check  
 
//CHECK  
//FSM STATE CHANGE  
  CHK_INIT_STATE: assert property ( prop_a_causes_b_check( clk,(fsm_state == INIT) && (!a && !b && !c && !d),(fsm_state == S0),1,rst)); 	//INIT STATE
  CHK_STATE0_TO_1: assert property ( prop_a_causes_b_check( clk,(fsm_state == S0) && b,(fsm_state == S1),1,rst)); 	//STATE0
  CHK_STATE0_TO_2: assert property ( prop_a_causes_b_check( clk,(fsm_state == S0) && c,(fsm_state == S2),1,rst)); 	//STATE0
  CHK_STATE1_TO_1: assert property ( prop_a_causes_b_check( clk,(fsm_state == S1) && !d,(fsm_state == S1),1,rst)); 	//STATE1
  CHK_STATE1_TO_INIT: assert property ( prop_a_causes_b_check( clk,(fsm_state == S1) && d,(fsm_state == INIT),1,rst)); 	//STATE1
  CHK_STATE2_TO_3: assert property ( prop_a_causes_b_check( clk,(fsm_state == S2)  && a,(fsm_state == S3),1,rst)); 	//STATE2_TO_3
  CHK_STATE3: assert property ( prop_a_causes_b_check( clk,(fsm_state == S3)  && !a,(fsm_state == S2),1,rst)); 	//STATE3
  CHK_STATE2_TO_1: assert property ( prop_a_causes_b_check( clk,(fsm_state == S2)  && b,(fsm_state == S1),1,rst)); 	//STATE2_TO_1

//OUTPUT CHECK  
  CHK_INIT_STATE_OUT: assert property ( prop_fsm_out_check( clk,(fsm_state == INIT),!finished,1,rst)); 	//INIT STATE
  CHK_STATE0_OUT: assert property ( prop_fsm_out_check( clk,(fsm_state == S0),!finished,1,rst)); 	//STATE0
  CHK_STATE1_OUT: assert property ( prop_fsm_out_check( clk,(fsm_state == S1),!finished,1,rst)); 	//STATE1
  CHK_STATE2_OUT: assert property ( prop_fsm_out_check( clk,(fsm_state == S2),!finished,1,rst)); 	//STATE2
  CHK_STATE3_OUT: assert property ( prop_fsm_out_check( clk,(fsm_state == S3),finished,1,rst)); 	//STATE3
  
//FSM STAY  
  CHK_INIT_STATE_STAY: assert property ( prop_a_causes_b_check( clk,(fsm_state == INIT) && !(!a && !b && !c && !d),(fsm_state == INIT),1,rst)); 	//INIT STATE
    CHK_STATE0_STAY: assert property ( prop_a_causes_b_check( clk,(fsm_state == S0) && (!b && !c),(fsm_state == S0),1,rst)); 	//STATE0
  CHK_STATE1_STAY: assert property ( prop_a_causes_b_check( clk,(fsm_state == S1) && !d,(fsm_state == S1),1,rst)); 	//STATE1
    CHK_STATE2_STAY: assert property ( prop_a_causes_b_check( clk,(fsm_state == S2) && (!b && !a),(fsm_state == S2),1,rst)); 	//STATE2
  CHK_STATE3_STAY: assert property ( prop_a_causes_b_check( clk,(fsm_state == S3)  && !(!a),(fsm_state == S3),1,rst)); 	//STATE3

// STATE SECURITY CHECKS
    CHK_INIT_STATE_SECURITY_TEST: assert property ( prop_a_causes_b_check( clk,(fsm_state == INIT),(fsm_state != S3),2,rst)); 	//INIT STATE
CHK_STATE0_SECURITY_TEST: assert property ( prop_a_causes_b_check( clk,(fsm_state == S0),(fsm_state != S3),1,rst)); 	//STATE0
CHK_STATE1_SECURITY_TEST: assert property ( prop_a_causes_b_check( clk,(fsm_state == S1),(fsm_state != S3),3,rst)); 	//STATE1
    
//COVER
//FSM STATE CHANGE  
  COV_INIT_STATE: cover property ( prop_a_causes_b_check( clk,(fsm_state == INIT) && (!a && !b && !c && !d),(fsm_state == S0),1,rst)); 	//INIT STATE
  COV_STATE0_TO_1: cover property ( prop_a_causes_b_check( clk,(fsm_state == S0) && b,(fsm_state == S1),1,rst)); 	//STATE0
  COV_STATE0_TO_2: cover property ( prop_a_causes_b_check( clk,(fsm_state == S0) && c,(fsm_state == S2),1,rst)); 	//STATE0
  COV_STATE1: cover property ( prop_a_causes_b_check( clk,(fsm_state == S1),(fsm_state == S1),1,rst)); 	//STATE1
  COV_STATE2_TO_3: cover property ( prop_a_causes_b_check( clk,(fsm_state == S2)  && a,(fsm_state == S3),1,rst)); 	//STATE2_TO_3
  COV_STATE3: cover property ( prop_a_causes_b_check( clk,(fsm_state == S3)  && !a,(fsm_state == S2),1,rst)); 	//STATE3
  COV_STATE2_TO_1: cover property ( prop_a_causes_b_check( clk,(fsm_state == S2)  && b,(fsm_state == S1),1,rst)); 	//STATE2_TO_1
  
// OUTPUT CHECK  
  COV_INIT_STATE_OUT: cover property ( prop_fsm_out_check( clk,(fsm_state == INIT),!finished,1,rst)); 	//INIT STATE
  COV_STATE0_OUT: cover property ( prop_fsm_out_check( clk,(fsm_state == S0),!finished,1,rst)); 	//STATE0
  COV_STATE1_OUT: cover property ( prop_fsm_out_check( clk,(fsm_state == S1),!finished,1,rst)); 	//STATE1
  COV_STATE2_OUT: cover property ( prop_fsm_out_check( clk,(fsm_state == S2),!finished,1,rst)); 	//STATE2
  COV_STATE3_OUT: cover property ( prop_fsm_out_check( clk,(fsm_state == S3),finished,1,rst)); 	//STATE3
  
// FSM STAY  
  COV_INIT_STATE_STAY: cover property ( prop_a_causes_b_check( clk,(fsm_state == INIT) && !(!a && !b && !c && !d),(fsm_state == INIT),1,rst)); 	//INIT STATE
  COV_STATE0_STAY: cover property ( prop_a_causes_b_check( clk,(fsm_state == S0) && (!b || !c),(fsm_state == S0),1,rst)); 	//STATE0
  COV_STATE1_STAY: cover property ( prop_a_causes_b_check( clk,(fsm_state == S1) && !d,(fsm_state == S1),1,rst)); 	//STATE1
  COV_STATE2_STAY: cover property ( prop_a_causes_b_check( clk,(fsm_state == S2) && (!b || !a),(fsm_state == S2),1,rst)); 	//STATE2
  COV_STATE3_STAY: cover property ( prop_a_causes_b_check( clk,(fsm_state == S3)  && !(!a),(fsm_state == S3),1,rst)); 	//STATE3
  
  COV_INIT_STATE_SECURITY_TEST: cover property ( prop_a_causes_b_check( clk,(fsm_state == INIT),(fsm_state != S3),2,rst)); 	//INIT STATE
COV_STATE0_SECURITY_TEST: cover property ( prop_a_causes_b_check( clk,(fsm_state == S0),(fsm_state != S3),1,rst)); 	//STATE0
COV_STATE1_SECURITY_TEST: cover property ( prop_a_causes_b_check( clk,(fsm_state == S1),(fsm_state != S3),3,rst)); 	//STATE1  
    
 endmodule    
