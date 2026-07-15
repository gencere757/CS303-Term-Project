module timer(
    input clk,
    input reset,    // active low reset
    input start,
    input timerReset,
    output reg timeout
  );

  parameter TIME_LIMIT = 7'd175;  // adjust for test

  reg [6:0] counter;
  reg counting;

  always @(posedge clk or negedge reset)
  begin
    if (!reset)
    begin
      counting <= 0;
      counter <= 0;
      timeout <= 0;
    end
    else
    begin
      if (timerReset)
      begin
        counting <= 0;
        counter <= 0;
        timeout <= 0;
      end
      if (counting)
      begin
        if (counter >= TIME_LIMIT)
        begin
          timeout <= 1;
        end
        else
        begin
          counter <= counter + 1;
          timeout <= 0;
        end
      end
      else if (start)
      begin
        counting <= 1'b1;
        counter <= 0;
        timeout <= 0;
      end
      else
      begin
        timeout <= 0;
        counter <= 0;
      end
    end
  end

endmodule
