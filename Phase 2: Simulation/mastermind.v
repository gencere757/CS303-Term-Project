module mastermind(

    input clk,
    input rst,

    input enterA,
    input enterB,
    input [2:0] letterIn,

    output reg [7:0] LEDX,
    output reg [6:0] SSD3,
    output reg [6:0] SSD2,
    output reg [6:0] SSD1,
    output reg [6:0] SSD0,
    output reg [4:0] cState
  );

  reg [4:0] current_state;

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

  parameter letter_A = 7'b1110111;
  parameter letter_b = 7'b1111100;
  parameter letter_C = 7'b0111001;
  parameter letter_E = 7'b1111001;
  parameter letter_F = 7'b1110001;
  parameter letter_H = 7'b1100110;
  parameter letter_L = 7'b0111000;
  parameter letter_U = 7'b0111110;
  parameter letter_P = 7'b1110011;
  parameter letter_zero = 7'b0111111;
  parameter letter_one = 7'b0000110;
  parameter letter_two = 7'b1011011;
  parameter letter_three = 7'b1001111;
  parameter letter_Dash = 7'b0000001;

  wire timed;
  //wire timed_wire;
  reg start_timer;

  timer timer1(clk, rst, start_timer, timed);

  reg [2:0] num1, num2, num3, num4;
  reg [1:0] numCount;
  reg [2:0] guess1, guess2, guess3, guess4;
  reg [1:0] guessCount;
  reg [6:0] activePlayer;
  reg [1:0] scoreA, scoreB;
  reg [1:0] lives;
  reg [3:0] equality;
  wire [6:0] SSD3_wire, SSD2_wire, SSD1_wire, SSD0_wire;

  //Reset Logic
  always @(negedge rst)
  begin
    if (!rst)
      current_state <= s0_idle;
  end

  //FSM
  always @ (posedge clk)
  begin
    current_state <= current_state;
    case (current_state)
      s0_idle:
      begin
        activePlayer <= 7'b0;
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
        //Transition
        if (enterA)
        begin
          activePlayer <= letter_A;
          start_timer = 1'b1;
          current_state <= s1_displayScores;
        end
        else if (enterB)
        begin
          activePlayer <= letter_b;
          start_timer = 1'b1;
          current_state <= s1_displayScores;
        end
        else
        begin
          current_state <= s0_idle;
        end
      end
      s1_displayScores:
      begin
        //Transition
        if (timed)
        begin
          start_timer = 1'b1;
          current_state <= s2_showActivePlayer;
        end
        else
        begin
          current_state <= s1_displayScores;
        end
      end
      s2_showActivePlayer:
      begin
        start_timer = 1'b0;
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
        //Transition
        if (activePlayer == letter_A)
        begin
          if (enterA)
          begin
            current_state <= s4_codeMakerInput;
          end
          else
          begin
            current_state <=s3_codeMakerStart;
          end
        end
        else
        begin  //Player B
          if (enterB)
          begin
            current_state <= s4_codeMakerInput;
          end
          else
          begin
            current_state <=s3_codeMakerStart;
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
          current_state <=s4_codeMakerInput;
        end
      end
      s5_displayNum:
      begin
        //Transition
        if (activePlayer == letter_A && enterA == 0)
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
        else if (activePlayer == letter_b && enterB == 0)
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
          start_timer = 1'b1;
        end
        else
        begin  //Active Player == B
          activePlayer <= letter_A;
          start_timer = 1'b1;
        end
        current_state <= s7_displayActivePlayer;
      end
      s7_displayActivePlayer:
      begin
        start_timer = 1'b0;
        lives <= 2'b11;
        //Transition
        if (timed)
        begin
          start_timer = 1'b1;
          current_state <= s8_displayLives;
        end
        else
        begin
          current_state <= s7_displayActivePlayer;
        end
      end
      s8_displayLives:
      begin
        start_timer = 1'b0;
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
        //Transition
        if (activePlayer == letter_A)
        begin
          if (enterA)
          begin
            current_state <= s10_codeBreakerInput;
          end
          else
          begin
            current_state <=s9_codeBreakerStart;
          end
        end
        else
        begin  //Player B
          if (enterB)
          begin
            current_state <= s10_codeBreakerInput;
          end
          else
          begin
            current_state <=s9_codeBreakerStart;
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
        if (activePlayer == letter_A && enterA == 0)
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
        else if (activePlayer == letter_b && enterB == 0)
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
          start_timer = 1'b1;
          current_state <= s17_displayCode;
        end
      end
      s17_displayCode:
      begin
        start_timer = 1'b0;
        //Transition
        if (timed)
        begin

          if (lives == 0)
          begin
            current_state <= s18_noLivesLeft;
          end
          else if(lives ==1)
          begin
            start_timer = 1'b1;
            current_state <= s8_displayLives;
            lives <= 2'b00;
          end
          else if(lives == 2)
          begin
            start_timer = 1'b1;
            current_state <= s8_displayLives;
            lives <= 2'b01;
          end
          else if(lives == 3)
          begin
            start_timer = 1'b1;
            current_state <= s8_displayLives;
            lives <= 2'b10;
          end
        end
        else
        begin
          current_state <= s17_displayCode;
        end
      end
      s18_noLivesLeft:
      begin
        //Transition
        case (activePlayer)
          letter_A:
          begin
            case (scoreA)
              2'b00:
              begin
                scoreA <= 2'b01;
                start_timer = 1'b1;
                current_state <= s1_displayScores;
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
          default:
          begin  //Player B
            case (scoreB)
              2'b00:
              begin
                scoreB <= 2'b01;
                start_timer = 1'b1;
                current_state <= s1_displayScores;
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
        endcase
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
              start_timer = 1'b1;
              current_state <= s1_displayScores;
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
              start_timer = 1'b1;
              current_state <= s1_displayScores;
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
        if (enterB)
        begin
          start_timer = 1'b1;
          current_state <= s22_displayScores2;
        end
        else
        begin
          current_state <= s20_ClickBTN0;
        end
      end
      s21_ClickBTN3:
      begin
        //Transition
        if (enterA)
        begin
          start_timer = 1'b1;
          current_state <= s22_displayScores2;
        end
        else
        begin
          current_state <= s21_ClickBTN3;
        end
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
        if(enterA || enterB)
          current_state <= s0_idle;
        else
          current_state <= s23_emptyScreen;
      end
    endcase
  end

  always @ (*)
  begin
    cState = current_state;

    case (current_state)
      s0_idle:
      begin
        SSD3 = 7'b0;
        SSD2 = letter_A;
        SSD1 = letter_Dash;
        SSD0 = letter_b;
        LEDX = 8'b0;
      end

      s1_displayScores:
      begin
        LEDX <= 8'b0;
        case (scoreA)
          2'b0:
            SSD2 = letter_zero;
          2'b1:
            SSD2 = letter_one;
          2'b10:
            SSD2 = letter_two;
          2'b11:
            SSD2 = letter_three;
        endcase
        SSD1 = letter_Dash;
        case (scoreB)
          2'b0:
            SSD0 = letter_zero;
          2'b1:
            SSD0 = letter_one;
          2'b10:
            SSD0 = letter_two;
          2'b11:
            SSD0 = letter_three;
        endcase
      end

      s2_showActivePlayer:
      begin
        SSD2 = letter_P;
        SSD1 = letter_Dash;
        SSD0 = activePlayer;
      end

      s5_displayNum:
      begin
        //Transition
        case (numCount)
          2'b01:
          begin
            case (num1)
              3'b001:
                SSD3 = letter_A;
              3'b010:
                SSD3 = letter_C;
              3'b011:
                SSD3 = letter_E;
              3'b100:
                SSD3 = letter_F;
              3'b101:
                SSD3 = letter_H;
              3'b110:
                SSD3 = letter_L;
              3'b111:
                SSD3 = letter_U;
              default:
                SSD3 = 7'b0; // Default case
            endcase
          end
          2'b10:
          begin
            SSD3 = letter_Dash;
            case (num2)
              3'b001:
                SSD2 = letter_A;
              3'b010:
                SSD2 = letter_C;
              3'b011:
                SSD2 = letter_E;
              3'b100:
                SSD2 = letter_F;
              3'b101:
                SSD2 = letter_H;
              3'b110:
                SSD2 = letter_L;
              3'b111:
                SSD2 = letter_U;
              default:
                SSD2 = 7'b0; // Default case
            endcase
          end
          2'b11:
          begin
            SSD3 = letter_Dash;
            SSD2 = letter_Dash;
            case (num3)
              3'b001:
                SSD1 = letter_A;
              3'b010:
                SSD1 = letter_C;
              3'b011:
                SSD1 = letter_E;
              3'b100:
                SSD1 = letter_F;
              3'b101:
                SSD1 = letter_H;
              3'b110:
                SSD1 = letter_L;
              3'b111:
                SSD1 = letter_U;
              default:
                SSD1 = 7'b0; // Default case
            endcase
          end
        endcase
      end

      s7_displayActivePlayer:
      begin
        SSD2 = letter_P;
        SSD1 = letter_Dash;
        SSD0 = activePlayer;
      end

      s8_displayLives:
      begin
        LEDX <= 8'b0;
        SSD2 = letter_L;
        SSD1 = letter_Dash;
        case (lives)
          2'b00:
            SSD0 = letter_zero;
          2'b01:
            SSD0 = letter_one;
          2'b10:
            SSD0 = letter_two;
          2'b11:
            SSD0 = letter_three;
          default:
            SSD0 = 7'b0;
        endcase
      end

      s11_displayGuess:
      begin
        //Transition
        case (guessCount)
          2'b01:
          begin
            case (guess1)
              3'b001:
                SSD3 = letter_A;
              3'b010:
                SSD3 = letter_C;
              3'b011:
                SSD3 = letter_E;
              3'b100:
                SSD3 = letter_F;
              3'b101:
                SSD3 = letter_H;
              3'b110:
                SSD3 = letter_L;
              3'b111:
                SSD3 = letter_U;
              default:
                SSD3 = 7'b0; // Default case
            endcase
          end
          2'b10:
          begin
            case (guess2)
              3'b001:
                SSD2 = letter_A;
              3'b010:
                SSD2 = letter_C;
              3'b011:
                SSD2 = letter_E;
              3'b100:
                SSD2 = letter_F;
              3'b101:
                SSD2 = letter_H;
              3'b110:
                SSD2 = letter_L;
              3'b111:
                SSD2 = letter_U;
              default:
                SSD2 = 7'b0; // Default case
            endcase
          end
          2'b11:
          begin
            case (guess3)
              3'b001:
                SSD1 = letter_A;
              3'b010:
                SSD1 = letter_C;
              3'b011:
                SSD1 = letter_E;
              3'b100:
                SSD1 = letter_F;
              3'b101:
                SSD1 = letter_H;
              3'b110:
                SSD1 = letter_L;
              3'b111:
                SSD1 = letter_U;
              default:
                SSD1 = 7'b0; // Default case
            endcase
          end
        endcase
      end

      s12_comparison:
      begin
        //Transition
        case (guess1)
          num1:
          begin
            LEDX[7] = 1'b1;
            LEDX[6] = 1'b1;
          end
          num2:
          begin
            LEDX[7] = 1'b0;
            LEDX[6] = 1'b1;
          end
          num3:
          begin
            LEDX[7] = 1'b0;
            LEDX[6] = 1'b1;
          end
          num4:
          begin
            LEDX[7] = 1'b0;
            LEDX[6] = 1'b1;
          end
          default:
          begin
            LEDX[7] = 1'b0;
            LEDX[6] = 1'b0;
          end
        endcase
      end

      s13_comparison2:
      begin
        //Transition
        case (guess2)
          num2:
          begin
            LEDX[5] = 1'b1;
            LEDX[4] = 1'b1;
          end
          num1:
          begin
            LEDX[5] = 1'b0;
            LEDX[4] = 1'b1;
          end
          num3:
          begin
            LEDX[5] = 1'b0;
            LEDX[4] = 1'b1;
          end
          num4:
          begin
            LEDX[5] = 1'b0;
            LEDX[4] = 1'b1;
          end
          default:
          begin
            LEDX[5] = 1'b0;
            LEDX[4] = 1'b0;
          end
        endcase
      end

      s14_comparison3:
      begin
        //Transition
        case (guess3)
          num3:
          begin
            LEDX[3] = 1'b1;
            LEDX[2] = 1'b1;
          end
          num1:
          begin
            LEDX[3] = 1'b0;
            LEDX[2] = 1'b1;
          end
          num2:
          begin
            LEDX[3] = 1'b0;
            LEDX[2] = 1'b1;
          end
          num4:
          begin
            LEDX[3] = 1'b0;
            LEDX[2] = 1'b1;
          end
          default:
          begin
            LEDX[3] = 1'b0;
            LEDX[2] = 1'b0;
          end
        endcase

      end

      s15_comparison4:
      begin
        //Transition
        case (guess4)
          num4:
          begin
            LEDX[1] = 1'b1;
            LEDX[0] = 1'b1;
          end
          num1:
          begin
            LEDX[1] = 1'b0;
            LEDX[0] = 1'b1;
          end
          num2:
          begin
            LEDX[1] = 1'b0;
            LEDX[0] = 1'b1;
          end
          num3:
          begin
            LEDX[1] = 1'b0;
            LEDX[0] = 1'b1;
          end
          default:
          begin
            LEDX[1] = 1'b0;
            LEDX[0] = 1'b0;
          end
        endcase

      end

      s17_displayCode:
      begin
        case (num1)
          3'b001:
            SSD3 = letter_A;
          3'b010:
            SSD3 = letter_C;
          3'b011:
            SSD3 = letter_E;
          3'b100:
            SSD3 = letter_F;
          3'b101:
            SSD3 = letter_H;
          3'b110:
            SSD3 = letter_L;
          3'b111:
            SSD3 = letter_U;
          default:
            SSD3 = 7'b0; // Default case
        endcase

        case (num2)
          3'b001:
            SSD2 = letter_A;
          3'b010:
            SSD2 = letter_C;
          3'b011:
            SSD2 = letter_E;
          3'b100:
            SSD2 = letter_F;
          3'b101:
            SSD2 = letter_H;
          3'b110:
            SSD2 = letter_L;
          3'b111:
            SSD2 = letter_U;
          default:
            SSD2 = 7'b0; // Default case
        endcase

        case (num3)
          3'b001:
            SSD1 = letter_A;
          3'b010:
            SSD1 = letter_C;
          3'b011:
            SSD1 = letter_E;
          3'b100:
            SSD1 = letter_F;
          3'b101:
            SSD1 = letter_H;
          3'b110:
            SSD1 = letter_L;
          3'b111:
            SSD1 = letter_U;
          default:
            SSD1 = 7'b0; // Default case
        endcase

        case (num4)
          3'b001:
            SSD0 = letter_A;
          3'b010:
            SSD0 = letter_C;
          3'b011:
            SSD0 = letter_E;
          3'b100:
            SSD0 = letter_F;
          3'b101:
            SSD0 = letter_H;
          3'b110:
            SSD0 = letter_L;
          3'b111:
            SSD0 = letter_U;
          default:
            SSD0 = 7'b0; // Default case
        endcase

      end

      s22_displayScores2:
      begin
        case (scoreA)
          3'b001:
            SSD2 = letter_A;
          3'b010:
            SSD2 = letter_C;
          3'b011:
            SSD2 = letter_E;
          3'b100:
            SSD2 = letter_F;
          3'b101:
            SSD2 = letter_H;
          3'b110:
            SSD2 = letter_L;
          3'b111:
            SSD2 = letter_U;
          default:
            SSD2 = 7'b0; // Default case
        endcase

        SSD1 = letter_Dash;

        case (scoreB)
          3'b001:
            SSD0 = letter_A;
          3'b010:
            SSD0 = letter_C;
          3'b011:
            SSD0 = letter_E;
          3'b100:
            SSD0 = letter_F;
          3'b101:
            SSD0 = letter_H;
          3'b110:
            SSD0 = letter_L;
          3'b111:
            SSD0 = letter_U;
          default:
            SSD0 = 7'b0; // Default case
        endcase

      end

      s23_emptyScreen:
      begin
        SSD3 = 7'b0;
        SSD2 = 7'b0;
        SSD1 = 7'b0;
        SSD0 = 7'b0;
      end

      default:
      begin

      end
    endcase
  end

endmodule
