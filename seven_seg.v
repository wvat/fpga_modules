`timescale 1ns / 1ps

module seven_seg(mclk, rst_N, digits_in, anode_sel, segments_out);

  input mclk;
  input rst_N;
  input [19:0] digits_in;             // D3 -> [19:15], D2 -> [14:10]
                                      // D1 -> [9:5].   D0 -> [4:0]
  output [3:0] anode_sel;             // MSB -> An0
  output reg [7:0] segments_out;      // MSB -> CA, LSB -> DP
  
  reg [4:0] digit;
  reg [15:0] count;

  // Refresh Counter (1kHz)
  always @(posedge mclk, negedge rst_N)
  begin
    if(~rst_N) 
    begin  
      count <= 0;
    end
    else if(count >= 50000) count <= 0; 
    else count <= count + 1; 
  end

  assign anode_sel[0] = ~(count >= 0 && count < 12500),
         anode_sel[1] = ~(count >= 12500 && count < 25000),
         anode_sel[2] = ~(count >= 25000 && count < 37500),
         anode_sel[3] = ~(count >= 37500 && count < 50000);

 // Digit Converter (BCD -> Sevenseg)
 always @ (*)
 begin
  // Determine current digit input based on anode select
  case(anode_sel)
    4'b1110: digit <= digits_in[4:0];
    4'b1101: digit <= digits_in[9:5];
    4'b1011: digit <= digits_in[14:10];
    4'b0111: digit <= digits_in[19:15];
    default: digit <= 0;
  endcase
 
  if(~rst_N)
    // Clear the display
    segments_out <= 8'hFF;
  else
  begin
    // BCD to seven segment conversion LUT (digit[5] is the DP) 
    case(digit[3:0])
      //                        ABCDEFG  DP
      4'h0: segments_out <= ~{7'b1111110, digit[4]};
      4'h1: segments_out <= ~{7'b0110000, digit[4]};
      4'h2: segments_out <= ~{7'b1101101, digit[4]};
      4'h3: segments_out <= ~{7'b1111001, digit[4]};
      4'h4: segments_out <= ~{7'b0110011, digit[4]};
      4'h5: segments_out <= ~{7'b1011011, digit[4]};
      4'h6: segments_out <= ~{7'b1011111, digit[4]};
      4'h7: segments_out <= ~{7'b1110000, digit[4]};
      4'h8: segments_out <= ~{7'b1111111, digit[4]};
      4'h9: segments_out <= ~{7'b1110011, digit[4]};
      4'hA: segments_out <= ~{7'b1110011, digit[4]};
      4'hB: segments_out <= ~{7'b0011111, digit[4]};
      4'hC: segments_out <= ~{7'b1001110, digit[4]};
      4'hD: segments_out <= ~{7'b0111101, digit[4]};
      4'hE: segments_out <= ~{7'b1001111, digit[4]};
      4'hF: segments_out <= ~{7'b1000111, digit[4]};
      default: segments_out <= ~8'b10010011;
    endcase
  end
 end

endmodule
