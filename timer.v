module timer(
    input clk,
    input reset,    // active low reset
    input start,
    output reg timeout
);

    parameter TIME_LIMIT = 7'd4;  // adjust for test

    reg [6:0] counter;
    reg counting;

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            counting <= 0;
            counter <= 0;
            timeout <= 0;
        end else if (start) begin
            counting <= 1'b1;
        end else if(counting == 0) begin
            counter <= 0;
            timeout <= 0;
        end
    end
    always @ (posedge clk) begin
        if (counter >= TIME_LIMIT) begin
            timeout <= 1;
            counter <= counter; // hold counter
        end else begin
            counter <= counter + 1;
            timeout <= 0;
        end
    end

endmodule