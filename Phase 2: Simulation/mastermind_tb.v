module mastermind_tb ();

  reg clk;
  reg rst;
  reg enterA;
  reg enterB;
  reg [2:0] letterIn;

  wire [6:0] SSD3;
  wire [6:0] SSD2;
  wire [6:0] SSD1;
  wire [6:0] SSD0;
  wire [7:0] LEDX;
  wire [4:0] cState;

  mastermind dut (
               .clk(clk),
               .rst(rst),
               .enterA(enterA),
               .enterB(enterB),
               .letterIn(letterIn),
               .SSD3(SSD3),
               .SSD2(SSD2),
               .SSD1(SSD1),
               .SSD0(SSD0),
               .LEDX(LEDX),
               .cState(cState)
             );

  parameter HP = 5;
  parameter FP = (2*HP);

  always #(HP) clk = ~clk; // Clock with half period HP

  initial
  begin

    $dumpfile("mastermind_tb.vcd");
    $dumpvars(0, mastermind_tb);
    $display("Simulation started");
    // Initialize inputs
    clk = 0;
    rst = 0;
    enterA = 0;
    enterB = 0;
    letterIn = 3'b000;

    // Release reset after some time
    #25;
    rst = 1;
    enterA = 1;
    #30
     enterA = 0;

    // Simulate some inputs
    #60;
    letterIn = 3'b010; // Example letter input
    enterA = 1;
    #45;
    enterA = 0;
    #45;
    letterIn = 3'b000;
    enterA = 1;
    #45;
    enterA = 0;
    #45;
    letterIn = 3'b010; // Example letter input
    enterA = 1;
    #45;
    enterA = 0;
    #25;
    enterB = 1;
    #25;
    enterB = 0;
    #45;
    letterIn = 3'b010; // Example letter input
    enterA = 1;
    #45;
    enterA = 0;
    #45;
    letterIn = 3'b010; // Example letter input
    enterA = 1;
    #55;
    enterA = 0;
    #45;


    #70;
    letterIn = 3'b010; // Example letter input

    #45;
    enterB = 1;
    #45;
    enterB = 0;
    letterIn = 3'b010; // Example letter input

    #45;
    enterB = 1;
    #45;
    enterB = 0;
    letterIn = 3'b010; // Example letter input

    #45;
    letterIn = 3'b000;
    enterB = 1;
    #45;
    enterB = 0;

    #45;
    enterB = 1;
    #45;
    enterB = 0;
    letterIn = 3'b010; // Example letter input

    #45;
    enterB = 1;
    #50;
    enterB = 0;
    #50;
    enterB = 1;
    #40;
    enterB = 0;
    #60;

    //Num2
    letterIn = 3'b001; // Example letter input
    enterB = 1;
    #45;
    enterB = 0;
    #45;
    letterIn = 3'b001; // Example letter input
    enterB = 1;
    #45;
    enterB = 0;
    #45;
    letterIn = 3'b001; // Example letter input
    enterB = 1;
    #45;
    enterB = 0;
    #25;
    enterA = 1;
    #25;
    enterA = 0;
    #45;
    letterIn = 3'b001; // Example letter input
    enterB = 1;
    #45;
    enterB = 0;
    #45;


    #70;
    letterIn = 3'b111; // Example letter input

    #45;
    enterA = 1;
    #45;
    enterA = 0;
    letterIn = 3'b111; // Example letter input

    #45;
    enterA = 1;
    #45;
    enterA = 0;
    letterIn = 3'b111; // Example letter input

    #45;
    enterA = 1;
    #45;
    enterA = 0;
    letterIn = 3'b111; // Example letter input

    #45;
    enterA = 1;
    #50;
    enterA = 0;
    #50;
    enterA = 1;
    #40;
    enterA = 0;
    #60;


    // Finish simulation after some time
    $finish;
  end

endmodule
