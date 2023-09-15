--Jess--
`include "fsm_checker.sv"
`include "bind.sv"

// For providing random reset
class reset_variation;
    rand int reset_timing;
  constraint c_const {reset_timing>10; reset_timing<150;};
 endclass

// Only one input will be high at a time, so used one hot encoding technique
class const_one_hot;
  randc logic [3:0] vector;
  constraint onehot {$countones(vector) <= 1;}
endclass

module tb;
  
  logic rst,clk,a,b,c,d, finished;
  logic [2:0] fsm_state;
  enum logic [2:0] {INIT,S0,S1,S2,S3} state_e;
  top dut(.*); 
  
  
  // To check coverage from all the pins
   covergroup cg @(posedge clk);            
     cp_a   : coverpoint a {option.at_least = 10;} 
     cp_b   : coverpoint b {option.at_least = 10;} 
     cp_c   : coverpoint c {option.at_least = 10;}  
     cp_d   : coverpoint d {option.at_least = 10;}
     cp_rst : coverpoint rst {option.at_least = 10;}   
     
 //    cp_a_max : coverpoint a {bins one = {1}; bins zero = {0}; option.at_least = 10;}
   //  cp_b_max : coverpoint b {bins one = {1}; bins zero = {0}; option.at_least = 10; }
 //    cp_c_max : coverpoint c {bins one = {1}; bins zero = {0}; option.at_least = 10;}
 //    cp_d_max : coverpoint d {bins one = {1}; bins zero = {0}; option.at_least = 10;}
     
     reset: coverpoint rst{ bins b0= (1=>0);
                           bins b1 = (0=>1);}
     a: coverpoint a{ bins b0= (1=>0);
                           bins b1 = (0=>1);}
     b: coverpoint b{ bins b0= (1=>0);
                           bins b1 = (0=>1);}
     c: coverpoint c{ bins b0= (1=>0);
                           bins b1 = (0=>1);}
     d: coverpoint d{ bins b0= (1=>0);
                           bins b1 = (0=>1);}
     fsm_state: coverpoint fsm_state{ bins b0= (INIT=>S0);
                                     bins b1= (S0=>S1);
                                     bins b2= (S1=>INIT);
                                     bins b3= (S2=>S3);
                                     bins b4= (S3=>S2);}
     fsm_state_tran : coverpoint fsm_state {bins b0 = (INIT => S0 =>S1);
                                            bins b1 = (INIT => S0 =>S2=>S3);
                                            bins b2 = (INIT => S0 =>S2 => S3 => S2 =>S1 =>INIT);
                                            bins b3 = (S3 => S2 =>S1 =>INIT);}   
   endgroup
  
  initial begin:clock
    clk=0;
    while(1) #5 clk= ~clk;
  end
 
  reset_variation r;
  const_one_hot oh=new();
  cg cg_inst=new();
  
  
  initial begin : generate_reset
    while(1) begin 
      r=new();
      r.randomize();
      rst = 1'b1;
      @(negedge clk);
      rst=1'b0;
      #(r.reset_timing);
      end     
  end
  
  initial begin: sequencer
    
    
    @(posedge clk) begin
      {d,c,b,a} = 4'b0000;
    end
    
     @(posedge clk) begin
      {d,c,b,a} = 4'b0010; 
    end
    @(negedge clk) rst=1'b1;
    
    #5;
    
    @(posedge clk) rst =1'b0;
   
 // COMPLETE CYCLE AND FLOW OF FSM TRANSITION    
    repeat(10) begin
    @(posedge clk) begin
       {d,c,b,a} = 4'b0000;
    end
    
    @(posedge clk) begin
      {d,c,b,a} = 4'b0100;
    end
    
    @(posedge clk) begin
      {d,c,b,a} = 4'b0001;
    end
    
    @(posedge clk) begin
      {d,c,b,a} = 4'b0000;
    end
    
    @(posedge clk) begin
      {d,c,b,a} = 4'b0010;
    end
    
    @(posedge clk) begin
      {d,c,b,a} = 4'b1000;
    end
    
    @(posedge clk) begin
      {d,c,b,a} = 4'b0000;
    end
    
    @(posedge clk) begin
      {d,c,b,a} = 4'b0010;
    end
    
    @(posedge clk) begin
      {d,c,b,a} = 4'b1000;
    end
    end
    
// FIXED REVOLVING SEQUENCE WITH RANDOM RESET
    repeat(20) begin
     @(posedge clk) begin
       {d,c,b,a} = 4'b0000;
    end
    
    @(posedge clk) begin
      {d,c,b,a} = 4'b0100;
    end
      
     @(posedge clk) begin
      {d,c,b,a} = 4'b0100;
    end 
    
    @(posedge clk) begin
      {d,c,b,a} = 4'b0001;
    end
    
    @(posedge clk) begin
      {d,c,b,a} = 4'b0001;
    end
      
    @(posedge clk) begin
      {d,c,b,a} = 4'b0000;
    end
    
    @(posedge clk) begin
      {d,c,b,a} = 4'b0010;
    end
    
    @(posedge clk) begin
      {d,c,b,a} = 4'b0010;
    end
      
    @(posedge clk) begin
      {d,c,b,a} = 4'b0000;
    end
    
     @(posedge clk) begin
       {d,c,b,a} = 4'b0010;
    end
     
    end

//RANDOM SEQUENCE AND RANDOM RESET    
    repeat (50) begin
      if(! oh.randomize()) $display("Randomization Failed!");
      {d,c,b,a}=oh.vector;  
      @(posedge clk); 
    end
    
    disable generate_reset;
    disable clock;
  end
  
  //CHECKING FINISHED STATE VALUE
  always begin : scoreboard
    @(posedge clk  or posedge rst);
  // WHEN RESET IS SET, FSM_STATE should be INIT 
    if (rst) begin
      #1;                                        
      if (fsm_state != INIT) $error ("RESET WORKING INCORRECTLY");
    end
    
    else begin
      
      if(fsm_state == S0 && finished) begin
        #1;
        $error ("Time:%0t Finished value Error. Expected value:0 Recieved value:1",$time);
      end
      
      if(fsm_state == S1 && finished) begin
        #1;
        $error ("Time:%0t Finished value Error. Expected value:0 Recieved value:1",$time);
      end
      
      if(fsm_state == S2 && finished) begin
        #1;
        $error ("Time:%0t Finished value Error. Expected value:0 Recieved value:1",$time);
      end
      
      if(fsm_state == S3 && !finished) begin
        #1;
        $error ("Time:%0t Finished value Error. Expected value:1 Recieved value:0",$time);
      end
    end
    
  end
  
  
  initial begin
    $dumpvars;
    $dumpfile("dump.vcd");
  end
  
  assign fsm_state = dut.U_FSM.curr_state; 
  
endmodule
      


