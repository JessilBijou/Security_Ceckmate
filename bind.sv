 bind fsm fsm_checker#() fsm_checker_inst (
        .rst(rst),
        .clk(clk),
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .finished(finished)
      );
