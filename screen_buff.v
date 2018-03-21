`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:53:13 11/29/2017 
// Design Name: 
// Module Name:    screen_buff 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module screen_buff(clk, h_addr, v_addr, enable, color_out);

  input clk;
  input enable;
  input [19:0] address;

  output color_out;

  reg[639:0] buff [479:0];
  reg[639:0] line;

  always @(posedge clk)
  begin
    line = buff[v_addr];
    color_out = line[h_addr];
  end

endmodule
