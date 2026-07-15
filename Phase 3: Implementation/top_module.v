module top_module(
    input clk,
    input rst,

    input enterA,
    input enterB,
    input [2:0] letterIn,

    output [7:0] led,
    output a_out,b_out,c_out,d_out,e_out,f_out,g_out,p_out,
    output [3:0] an
  );

  ssd SSDManager(clk, SSD0_next, SSD1_next, SSD2_next, SSD3_next, {p_out, g_out, f_out, e_out, d_out, c_out, b_out, a_out},an);
  clk_divider clkDivider(clk, divClk);
  debouncer DebA(divClk, !rst, !enterA, AClean);
  debouncer DebB(divClk, !rst, !enterB, BClean);

  reg [4:0] current_state;
  reg [7:0] SSD0_next;
  reg [7:0] SSD1_next;
  reg [7:0] SSD2_next;
  reg [7:0] SSD3_next;
  reg [7:0] ledReg_next;

  reg [7:0] SSD0;
  reg [7:0] SSD1;
  reg [7:0] SSD2;
  reg [7:0] SSD3;
  reg [7:0] ledReg;


  //States
  parameter s0_idle = 5'd0;
  parameter s1_displayScores = 5'd1;
  parameter s2_showActivePlayer = 5'd2;
  parameter s3_codeMakerStart = 5'd3;
  parameter s4_codeMakerInput = 5'd4;
  parameter s5_displayNum = 5'd5;
  parameter s6_changeActivePlayer = 5'd6;
  parameter s7_displayActivePlayer = 5'd7;
  parameter s8_displayLives = 5'd8;
  parameter s9_codeBreakerStart = 5'd9;
  parameter s10_codeBreakerInput = 5'd10;
  parameter s11_displayGuess = 5'd11;
  parameter s12_comparison = 5'd12;
  parameter s13_comparison2 = 5'd13;
  parameter s14_comparison3 = 5'd14;
  parameter s15_comparison4 = 5'd15;
  parameter s16_correctnessCheck = 5'd16;
  parameter s17_displayCode = 5'd17;
  parameter s18_noLivesLeft = 5'd18;
  parameter s19_correctNum = 5'd19;
  parameter s20_ClickBTN0 = 5'd20;
  parameter s21_ClickBTN3 = 5'd21;
  parameter s22_displayScores2 = 5'd22;
  parameter s23_emptyScreen = 5'd23;
  parameter s24_idle = 5'd24;
  parameter s25_idle2 = 5'd25;
  parameter s26_idle3 = 5'd26;
  parameter s27_idle4 = 5'd27;
  parameter s28_idle5 = 5'd28;

  parameter letter_A = 8'b01110111;
  parameter letter_b = 8'b01111100;
  parameter letter_C = 8'b00111001;
  parameter letter_E = 8'b01111001;
  parameter letter_F = 8'b01110001;
  parameter letter_H = 8'b01110110;
  parameter letter_L = 8'b00111000;
  parameter letter_U = 8'b00111110;
  parameter letter_P = 8'b01110011;
  parameter letter_zero = 8'b00111111;
  parameter letter_one = 8'b00000110;
  parameter letter_two = 8'b01011011;
  parameter letter_three = 8'b01001111;
  parameter letter_Dash = 8'b01000000;

  wire timed;
  wire divClk;
  reg start_timer;
  wire AClean;
  wire BClean;

  reg timer_reset;
  reg timer_reset_d;

  wire timer_reset_pulse;
  assign timer_reset_pulse = timer_reset & ~timer_reset_d;

  timer timer1(divClk, rst, start_timer, timer_reset_pulse, timed);

  reg [2:0] num1, num2, num3, num4;
  reg [1:0] numCount;
  reg [2:0] guess1, guess2, guess3, guess4;
  reg [1:0] guessCount;
  reg [7:0] activePlayer;
  reg [1:0] scoreA, scoreB;
  reg [1:0] lives;
  reg [3:0] equality;

  assign led = ledReg;

  //FSM - Sequential block
  always @ (posedge divClk or negedge rst)
  begin
    if (!rst)
    begin
      current_state <= s0_idle;
      scoreA <= 2'b0;
      scoreB <= 2'b0;
      activePlayer <= 8'b0;
      start_timer <= 1'b0;
      // Initialize other registers
      num1 <= 3'b0;
      num2 <= 3'b0;
      num3 <= 3'b0;
      num4 <= 3'b0;
      numCount <= 2'b0;
      guess1 <= 3'b0;
      guess2 <= 3'b0;
      guess3 <= 3'b0;
      guess4 <= 3'b0;
      guessCount <= 2'b0;
      lives <= 2'b11;
      equality <= 4'b0;
    end
    else
    begin
      timer_reset_d <= timer_reset;
      if (timer_reset)
        timer_reset <= 1'b0;
      SSD0 <= SSD0_next;
      SSD1 <= SSD1_next;
      SSD2 <= SSD2_next;
      SSD3 <= SSD3_next;
      ledReg <= ledReg_next;
      case (current_state)
        s0_idle:
        begin
          activePlayer <= 8'b0;
          scoreA <= 2'b0;
          scoreB <= 2'b0;
          num1 <= 3'b0;
          num2 <= 3'b0;
          num3 <= 3'b0;
          num4 <= 3'b0;
          numCount <= 2'b0;
          guess1 <= 3'b0;
          guess2 <= 3'b0;
          guess3 <= 3'b0;
          guess4 <= 3'b0;
          guessCount <= 2'b0;
          lives <= 2'b11;
          equality <= 4'b0;
          timer_reset_d <= 1'b0;

          //Transition
          if (AClean)
          begin
            activePlayer <= letter_A;
            start_timer <= 1'b1;  // Set timer start
            current_state <= s1_displayScores;
          end
          else if (BClean)
          begin
            activePlayer <= letter_b;
            start_timer <= 1'b1;  // Set timer start
            current_state <= s1_displayScores;
          end
          else
          begin
            current_state <= s0_idle;
          end
        end

        s1_displayScores:
        begin
          start_timer <= 1'b0;
          if (timer_reset_d)  // Wait for reset to complete
          begin
            start_timer <= 1'b1;
            timer_reset <= 0;
          end
          //Transition
          if (timed)
          begin
            start_timer <= 1'b1;  // Set timer start
            timer_reset <= 1;
            current_state <= s24_idle;
          end
          else
          begin
            current_state <= s1_displayScores;
          end
        end

        s2_showActivePlayer:
        begin
          start_timer <= 1'b0;
          if (timer_reset_d)  // Wait for reset to complete
          begin
            start_timer <= 1'b1;
            timer_reset <= 0;
          end
          //Transition
          if (timed)
          begin
            current_state <= s3_codeMakerStart;
            num1 <= 3'b0;
            num2 <= 3'b0;
            num3 <= 3'b0;
            num4 <= 3'b0;
          end
          else
          begin
            current_state <= s2_showActivePlayer;
          end
        end

        s3_codeMakerStart:
        begin
          start_timer <= 1'b0;
          timer_reset <= 1'b1;
          //Transition
          if (activePlayer == letter_A)
          begin
            if (AClean && letterIn != 0)
            begin
              current_state <= s4_codeMakerInput;
            end
            else
            begin
              current_state <= s3_codeMakerStart;
            end
          end
          else
          begin  //Player B
            if (BClean && letterIn != 0)
            begin
              current_state <= s4_codeMakerInput;
            end
            else
            begin
              current_state <= s3_codeMakerStart;
            end
          end
        end

        s4_codeMakerInput:
        begin
          if(letterIn != 0)
          begin
            //Transition
            if (numCount == 2'b00)
            begin
              num1 <= letterIn;
              numCount <= 2'b01;
            end
            else if (numCount == 2'b01)
            begin
              num2 <= letterIn;
              numCount <= 2'b10;
            end
            else if (numCount == 2'b10)
            begin
              num3 <= letterIn;
              numCount <= 2'b11;
            end
            else if (numCount == 2'b11)
            begin
              num4 <= letterIn;
              numCount <= 2'b00;
            end
            current_state <= s5_displayNum;
          end
          else
          begin
            current_state <= s4_codeMakerInput;
          end
        end

        s5_displayNum:
        begin
          //Transition
          if (activePlayer == letter_A && AClean == 0)
          begin
            case (numCount)
              2'b00:
              begin
                current_state <= s6_changeActivePlayer;
              end
              2'b01:
              begin
                current_state <= s3_codeMakerStart;
              end
              2'b10:
              begin
                current_state <= s3_codeMakerStart;
              end
              2'b11:
              begin
                current_state <= s3_codeMakerStart;
              end
            endcase
          end
          else if (activePlayer == letter_b && BClean == 0)
          begin
            case (numCount)
              2'b00:
              begin
                current_state <= s6_changeActivePlayer;
              end
              2'b01:
              begin
                current_state <= s3_codeMakerStart;
              end
              2'b10:
              begin
                current_state <= s3_codeMakerStart;
              end
              2'b11:
              begin
                current_state <= s3_codeMakerStart;
              end
            endcase
          end
          else
          begin
            current_state <= s5_displayNum;
          end
        end

        s6_changeActivePlayer:
        begin
          //Transition
          if (activePlayer == letter_A)
          begin
            activePlayer <= letter_b;
          end
          else
          begin  //Active Player == B
            activePlayer <= letter_A;
          end
          start_timer <= 1'b1;  // Set timer start
          current_state <= s7_displayActivePlayer;
        end

        s7_displayActivePlayer:
        begin
          lives <= 2'b11;
          //Transition
          if (timed)
          begin
            start_timer <= 1'b1;  // Set timer start
            timer_reset <= 1'b1;
            current_state <= s25_idle2;
          end
          else
          begin
            current_state <= s7_displayActivePlayer;
          end
        end

        s8_displayLives:
        begin
          start_timer <= 1'b0;

          if (timer_reset_d)  // Wait for reset to complete
          begin
            start_timer <= 1'b1;
            timer_reset <= 0;
          end
          //Transition
          if (timed)
          begin
            guessCount <= 2'b00;
            guess1 <= 3'b0;
            guess2 <= 3'b0;
            guess3 <= 3'b0;
            guess4 <= 3'b0;
            current_state <= s9_codeBreakerStart;
          end
          else
          begin
            current_state <= s8_displayLives;
          end
        end

        s9_codeBreakerStart:
        begin
          start_timer <= 1'b0;
          timer_reset <= 1'b1;
          //Transition
          if (activePlayer == letter_A)
          begin
            if (AClean)
            begin
              current_state <= s10_codeBreakerInput;
            end
            else
            begin
              current_state <= s9_codeBreakerStart;
            end
          end
          else
          begin  //Player B
            if (BClean)
            begin
              current_state <= s10_codeBreakerInput;
            end
            else
            begin
              current_state <= s9_codeBreakerStart;
            end
          end
        end

        s10_codeBreakerInput:
        begin
          if(letterIn != 0)
          begin
            //Transition
            case (guessCount)
              2'b00:
              begin
                guess1 <= letterIn;
                guessCount <= 2'b01;
              end
              2'b01:
              begin
                guess2 <= letterIn;
                guessCount <= 2'b10;
              end
              2'b10:
              begin
                guess3 <= letterIn;
                guessCount <= 2'b11;
              end
              2'b11:
              begin
                guess4 <= letterIn;
                guessCount <= 2'b00;
              end
            endcase
            current_state <= s11_displayGuess;
          end
          else
          begin
            current_state <= s10_codeBreakerInput;
          end
        end

        s11_displayGuess:
        begin
          //Transition
          if (activePlayer == letter_A && AClean == 0)
          begin
            case (guessCount)
              2'b00:
              begin
                current_state <= s12_comparison;
              end
              2'b01:
              begin
                current_state <= s9_codeBreakerStart;
              end
              2'b10:
              begin
                current_state <= s9_codeBreakerStart;
              end
              2'b11:
              begin
                current_state <= s9_codeBreakerStart;
              end
            endcase
          end
          else if (activePlayer == letter_b && BClean == 0)
          begin
            case (guessCount)
              2'b00:
              begin
                current_state <= s12_comparison;
              end
              2'b01:
              begin
                current_state <= s9_codeBreakerStart;
              end
              2'b10:
              begin
                current_state <= s9_codeBreakerStart;
              end
              2'b11:
              begin
                current_state <= s9_codeBreakerStart;
              end
            endcase
          end
          else
          begin
            current_state <= s11_displayGuess;
          end
        end

        s12_comparison:
        begin
          equality <= 4'b0;
          //Transition
          case (guess1)
            num1:
            begin
              equality[3] <= 1'b1;
            end
          endcase
          current_state <= s13_comparison2;
        end

        s13_comparison2:
        begin
          //Transition
          case (guess2)
            num2:
            begin
              equality[2] <= 1'b1;
            end
          endcase
          current_state <= s14_comparison3;
        end

        s14_comparison3:
        begin
          //Transition
          case (guess3)
            num3:
            begin
              equality[1] <= 1'b1;
            end
          endcase
          current_state <= s15_comparison4;
        end

        s15_comparison4:
        begin
          start_timer <= 1'b0;
          //Transition
          case (guess4)
            num4:
            begin
              equality[0] <= 1'b1;
            end
          endcase
          current_state <= s16_correctnessCheck;
        end

        s16_correctnessCheck:
        begin
          //Transition
          if(equality == 4'b1111)
          begin
            current_state <= s19_correctNum;
          end
          else
          begin
            start_timer <= 1'b1;  // Set timer start
            current_state <= s17_displayCode;
          end
        end

        s17_displayCode:
        begin
          //Transition

          if (lives == 1 && timed)
          begin
            current_state <= s18_noLivesLeft;
            start_timer <= 1'b1;
            timer_reset <= 1'b1;
          end
          else if(lives > 1)
          begin
            start_timer <= 1'b1;
            timer_reset <= 1'b1;
            current_state <= s27_idle4;
            lives <= lives - 1;
          end

          else
          begin
            current_state <= s17_displayCode;
          end
        end

        s18_noLivesLeft:
        begin
          start_timer <= 1'b0;
          if (timer_reset_d)
          begin
            start_timer <= 1'b1;
            timer_reset <= 0;
          end
          if(timed)
          begin

            //Transition
            case (activePlayer)
              letter_A:
              begin
                case (scoreB)
                  2'b00:
                  begin
                    scoreB <= 2'b01;
                    start_timer <= 1'b1;  // Set timer start
                    timer_reset <= 1'b1;
                    current_state <= s28_idle5;
                  end
                  2'b01:
                  begin
                    scoreB <= 2'b10;
                    current_state <= s21_ClickBTN3;
                  end
                  default:
                  begin
                    scoreB <= 2'b10;
                    current_state <= s21_ClickBTN3;
                  end
                endcase
              end
              default:
              begin  //Player B
                case (scoreA)
                  2'b00:
                  begin
                    scoreA <= 2'b01;
                    start_timer <= 1'b1;  // Set timer start
                    timer_reset <= 1'b1;
                    current_state <= s28_idle5;
                  end
                  2'b01:
                  begin
                    scoreA <= 2'b10;
                    current_state <= s20_ClickBTN0;
                  end
                  default:
                  begin
                    scoreA <= 2'b10;
                    current_state <= s20_ClickBTN0;
                  end
                endcase
              end
            endcase
          end
        end

        s19_correctNum:
        begin
          //Transition
          if (activePlayer == letter_A)
          begin
            case (scoreA)
              2'b00:
              begin
                scoreA <= 2'b01;
                
                  start_timer <= 1;
                  timer_reset <= 1;
                  current_state <= s26_idle3;
              end
              2'b01:
              begin
                scoreA <= 2'b10;
                current_state <= s21_ClickBTN3;
              end
              default:
              begin
                scoreA <= 2'b10;
                current_state <= s21_ClickBTN3;
              end
            endcase
          end
          else
          begin  //Player B
            case (scoreB)
              2'b00:
              begin
                scoreB <= 2'b01;
                
                  start_timer <= 1;
                  timer_reset <= 1;
                  current_state <= s26_idle3;
              end
              2'b01:
              begin
                scoreB <= 2'b10;
                current_state <= s20_ClickBTN0;
              end
              default:
              begin
                scoreB <= 2'b10;
                current_state <= s20_ClickBTN0;
              end
            endcase
          end
        end

        s20_ClickBTN0:
        begin
          //Transition

          start_timer <= 1'b1;  // Set timer start
          current_state <= s22_displayScores2;

        end

        s21_ClickBTN3:
        begin
          //Transition

          start_timer <= 1'b1;  // Set timer start
          current_state <= s22_displayScores2;
        end

        s22_displayScores2:
        begin
          //Transition
          if (timed)
          begin
            current_state <= s23_emptyScreen;
          end
          else
          begin
            current_state <= s22_displayScores2;
          end
        end

        s23_emptyScreen:
        begin
          //Transition
          if(AClean || BClean)
            current_state <= s0_idle;
          else
            current_state <= s23_emptyScreen;
        end
        s24_idle:
        begin
          if (!timed)
          begin
            current_state <= s2_showActivePlayer;
          end
          else
            current_state <= s24_idle;
        end

        s25_idle2:
        begin
          if(!timed)
          begin
            current_state <= s8_displayLives;
          end
          else
          begin
            current_state <= s25_idle2;
          end
        end

        s26_idle3:
        begin
          if(!timed)
          begin
            current_state <= s1_displayScores;
          end
          else
          begin
            current_state <= s26_idle3;
          end
        end

        s27_idle4:
        begin
          if(!timed)
          begin
            current_state <= s8_displayLives;
          end
          else
          begin
            current_state <= s27_idle4;
          end
        end

        s28_idle5:
        begin
          if(!timed)
          begin
            current_state <= s1_displayScores;
          end
          else
          begin
            current_state <= s28_idle5;
          end
        end
      endcase
    end
  end

  // Combinational block for outputs
  always @ (*)
  begin
    SSD0_next = SSD0;  // HOLD by default
    SSD1_next = SSD1;
    SSD2_next = SSD2;
    SSD3_next = SSD3;
    ledReg_next  = ledReg;

    case (current_state)
      s0_idle:
      begin
        SSD3_next = 8'b0;
        SSD2_next = letter_A;
        SSD1_next = letter_Dash;
        SSD0_next = letter_b;
        ledReg_next = 8'b0;
      end

      s1_displayScores:
      begin
        //ledReg_next = 8'b0;
        SSD3_next = 8'b0;
        case (scoreA)
          2'b0:
            SSD2_next = letter_zero;
          2'b1:
            SSD2_next = letter_one;
          2'b10:
            SSD2_next = letter_two;
          2'b11:
            SSD2_next = letter_three;
        endcase
        SSD1_next = letter_Dash;
        case (scoreB)
          2'b0:
            SSD0_next = letter_zero;
          2'b1:
            SSD0_next = letter_one;
          2'b10:
            SSD0_next = letter_two;
          2'b11:
            SSD0_next = letter_three;
        endcase
      end

      s2_showActivePlayer:
      begin
        SSD2_next = letter_P;
        SSD1_next = letter_Dash;
        SSD0_next = activePlayer;
      end

      s3_codeMakerStart:
      begin
        case (numCount)
          2'd1:
          begin
            SSD2_next = 8'b0;
            SSD1_next = 8'b0;
            SSD0_next = 8'b0;
          end
          2'd2:
          begin
            SSD1_next = 8'b0;
            SSD0_next = 8'b0;
          end
          2'd3:
          begin
            SSD0_next = 8'b0;
          end
          default:
          begin
            SSD3_next = 8'b0;
            SSD2_next = 8'b0;
            SSD1_next = 8'b0;
            SSD0_next = 8'b0;
          end
        endcase

      end

      s5_displayNum:
      begin
        case (numCount)
          2'b01:
          begin
            case (num1)
              3'b001:
                SSD3_next = letter_A;
              3'b010:
                SSD3_next = letter_C;
              3'b011:
                SSD3_next = letter_E;
              3'b100:
                SSD3_next = letter_F;
              3'b101:
                SSD3_next = letter_H;
              3'b110:
                SSD3_next = letter_L;
              3'b111:
                SSD3_next = letter_U;
              default:
                SSD3_next = 8'b0;
            endcase
          end
          2'b10:
          begin
            SSD3_next = letter_Dash;
            case (num2)
              3'b001:
                SSD2_next = letter_A;
              3'b010:
                SSD2_next = letter_C;
              3'b011:
                SSD2_next = letter_E;
              3'b100:
                SSD2_next = letter_F;
              3'b101:
                SSD2_next = letter_H;
              3'b110:
                SSD2_next = letter_L;
              3'b111:
                SSD2_next = letter_U;
              default:
                SSD2_next = 8'b0;
            endcase
          end
          2'b11:
          begin
            SSD3_next = letter_Dash;
            SSD2_next = letter_Dash;
            case (num3)
              3'b001:
                SSD1_next = letter_A;
              3'b010:
                SSD1_next = letter_C;
              3'b011:
                SSD1_next = letter_E;
              3'b100:
                SSD1_next = letter_F;
              3'b101:
                SSD1_next = letter_H;
              3'b110:
                SSD1_next = letter_L;
              3'b111:
                SSD1_next = letter_U;
              default:
                SSD1_next = 8'b0;
            endcase
          end
        endcase
      end

      s7_displayActivePlayer:
      begin
        SSD3_next = 8'b0;
        SSD2_next = letter_P;
        SSD1_next = letter_Dash;
        SSD0_next = activePlayer;
      end

      s8_displayLives:
      begin
        //ledReg_next = 8'b0;
        SSD3_next = 8'b0;
        SSD2_next = letter_L;
        SSD1_next = letter_Dash;
        case (lives)
          2'b00:
            SSD0_next = letter_zero;
          2'b01:
            SSD0_next = letter_one;
          2'b10:
            SSD0_next = letter_two;
          2'b11:
            SSD0_next = letter_three;
          default:
            SSD0_next = 8'b0;
        endcase
      end
      s9_codeBreakerStart:
      begin
        case (guessCount)
          2'd1:
          begin
            SSD2_next = 8'b0;
            SSD1_next = 8'b0;
            SSD0_next = 8'b0;
          end
          2'd2:
          begin
            SSD1_next = 8'b0;
            SSD0_next = 8'b0;
          end
          2'd3:
          begin
            SSD0_next = 8'b0;
          end
          default:
          begin
            SSD3_next = 8'b0;
            SSD2_next = 8'b0;
            SSD1_next = 8'b0;
            SSD0_next = 8'b0;
          end
        endcase
      end

      s11_displayGuess:
      begin
        case (guessCount)
          2'b01:
          begin
            case (guess1)
              3'b001:
                SSD3_next = letter_A;
              3'b010:
                SSD3_next = letter_C;
              3'b011:
                SSD3_next = letter_E;
              3'b100:
                SSD3_next = letter_F;
              3'b101:
                SSD3_next = letter_H;
              3'b110:
                SSD3_next = letter_L;
              3'b111:
                SSD3_next = letter_U;
              default:
                SSD3_next = 8'b0;
            endcase
          end
          2'b10:
          begin
            case (guess2)
              3'b001:
                SSD2_next = letter_A;
              3'b010:
                SSD2_next = letter_C;
              3'b011:
                SSD2_next = letter_E;
              3'b100:
                SSD2_next = letter_F;
              3'b101:
                SSD2_next = letter_H;
              3'b110:
                SSD2_next = letter_L;
              3'b111:
                SSD2_next = letter_U;
              default:
                SSD2_next = 8'b0;
            endcase
          end
          2'b11:
          begin
            case (guess3)
              3'b001:
                SSD1_next = letter_A;
              3'b010:
                SSD1_next = letter_C;
              3'b011:
                SSD1_next = letter_E;
              3'b100:
                SSD1_next = letter_F;
              3'b101:
                SSD1_next = letter_H;
              3'b110:
                SSD1_next = letter_L;
              3'b111:
                SSD1_next = letter_U;
              default:
                SSD1_next = 8'b0;
            endcase
          end
        endcase
      end

      s12_comparison:
      begin
        case (guess1)
          num1:
          begin
            ledReg_next[7] = 1'b1;
            ledReg_next[6] = 1'b1;
          end
          num2,num3,num4:
          begin
            ledReg_next[7] = 1'b0;
            ledReg_next[6] = 1'b1;
          end
          default:
          begin
            ledReg_next[7] = 1'b0;
            ledReg_next[6] = 1'b0;
          end
        endcase
      end

      s13_comparison2:
      begin
        case (guess2)
          num2:
          begin
            ledReg_next[5] = 1'b1;
            ledReg_next[4] = 1'b1;
          end
          num1,num3,num4:
          begin
            ledReg_next[5] = 1'b0;
            ledReg_next[4] = 1'b1;
          end
          default:
          begin
            ledReg_next[5] = 1'b0;
            ledReg_next[4] = 1'b0;
          end
        endcase
      end

      s14_comparison3:
      begin
        case (guess3)
          num3:
          begin
            ledReg_next[3] = 1'b1;
            ledReg_next[2] = 1'b1;
          end
          num1,num2,num4:
          begin
            ledReg_next[3] = 1'b0;
            ledReg_next[2] = 1'b1;
          end
          default:
          begin
            ledReg_next[3] = 1'b0;
            ledReg_next[2] = 1'b0;
          end
        endcase
      end

      s15_comparison4:
      begin
        case (guess4)
          num4:
          begin
            ledReg_next[1] = 1'b1;
            ledReg_next[0] = 1'b1;
          end
          num1,num2,num3:
          begin
            ledReg_next[1] = 1'b0;
            ledReg_next[0] = 1'b1;
          end
          default:
          begin
            ledReg_next[1] = 1'b0;
            ledReg_next[0] = 1'b0;
          end
        endcase
      end

      s17_displayCode:
      begin
        if (lives == 1)
        begin
          case (num1)
            3'b001:
              SSD3_next = letter_A;
            3'b010:
              SSD3_next = letter_C;
            3'b011:
              SSD3_next = letter_E;
            3'b100:
              SSD3_next = letter_F;
            3'b101:
              SSD3_next = letter_H;
            3'b110:
              SSD3_next = letter_L;
            3'b111:
              SSD3_next = letter_U;
            default:
              SSD3_next = 8'b0;
          endcase

          case (num2)
            3'b001:
              SSD2_next = letter_A;
            3'b010:
              SSD2_next = letter_C;
            3'b011:
              SSD2_next = letter_E;
            3'b100:
              SSD2_next = letter_F;
            3'b101:
              SSD2_next = letter_H;
            3'b110:
              SSD2_next = letter_L;
            3'b111:
              SSD2_next = letter_U;
            default:
              SSD2_next = 8'b0;
          endcase

          case (num3)
            3'b001:
              SSD1_next = letter_A;
            3'b010:
              SSD1_next = letter_C;
            3'b011:
              SSD1_next = letter_E;
            3'b100:
              SSD1_next = letter_F;
            3'b101:
              SSD1_next = letter_H;
            3'b110:
              SSD1_next = letter_L;
            3'b111:
              SSD1_next = letter_U;
            default:
              SSD1_next = 8'b0;
          endcase

          case (num4)
            3'b001:
              SSD0_next = letter_A;
            3'b010:
              SSD0_next = letter_C;
            3'b011:
              SSD0_next = letter_E;
            3'b100:
              SSD0_next = letter_F;
            3'b101:
              SSD0_next = letter_H;
            3'b110:
              SSD0_next = letter_L;
            3'b111:
              SSD0_next = letter_U;
            default:
              SSD0_next = 8'b0;
          endcase
        end
      end

      s18_noLivesLeft:begin
        ledReg_next = 0;
      end

      s19_correctNum:begin
        ledReg_next = 0;
      end

      s22_displayScores2:
      begin
        SSD3_next <= 3'b0;
        case (scoreA)
          2'b00:
            SSD2_next = letter_zero;
          2'b01:
            SSD2_next = letter_one;
          2'b10:
            SSD2_next = letter_two;
          2'b11:
            SSD2_next = letter_three;
        endcase

        SSD1_next = letter_Dash;

        case (scoreB)
          2'b00:
            SSD0_next = letter_zero;
          2'b01:
            SSD0_next = letter_one;
          2'b10:
            SSD0_next = letter_two;
          2'b11:
            SSD0_next = letter_three;
        endcase
      end

      s23_emptyScreen:
      begin
        SSD3_next = 8'b0;
        SSD2_next = 8'b0;
        SSD1_next = 8'b0;
        SSD0_next = 8'b0;
      end

      default:
      begin
      end
    endcase
  end

endmodule
