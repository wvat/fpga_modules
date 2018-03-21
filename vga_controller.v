`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module vga_controller(mclk, rst, h_sync, v_sync, color_enable, vga_v_cnt, vga_h_cnt, update );

  input mclk;                // Master clock.
  input rst;                 // Active low Reset.

  output h_sync;             // Horizontal sync signal.
  output v_sync;             // Vertical sync signal.
  output color_enable;       // Enable color output when in display area.
  output [9:0] vga_v_cnt;
  output [9:0] vga_h_cnt;
  output update;

  // Horizontal display timing.
  localparam H_DISPLAY          = 640;
  localparam H_FRONTPORCH       = 16;
  localparam H_BACKPORCH        = 48;
  localparam H_PULSE            = 96;
  localparam H_TOTAL            = H_DISPLAY + H_FRONTPORCH + H_BACKPORCH + H_PULSE;

  // Vertical display timing.
  localparam V_DISPLAY          = 480;
  localparam V_FRONTPORCH       = 10;
  localparam V_BACKPORCH        = 29;
  localparam V_PULSE            = 2;
  localparam V_TOTAL            = V_DISPLAY + V_FRONTPORCH + V_BACKPORCH + V_PULSE;

  reg clk_cnt;               // 25MHz internal clock.
  wire terminal_count;       // Indicates to the vertical counter to step by 1.
  wire color_enable;         // Enable color output when in display area.
  
  reg [9:0] h_cnt;           // Pixel count.
  reg [9:0] v_cnt;           // Line count.  
  
  // Clock Divider
  always @(posedge mclk or posedge rst)
  begin
    if(rst)
      clk_cnt <= 1'b0;
    else
      clk_cnt <= ~clk_cnt;
  end

  assign terminal_count = (h_cnt == H_TOTAL);
  
  // Horizontal Counter
  always @(posedge clk_cnt or posedge rst)
  begin
    if(rst)
      h_cnt <= 0;
    else
    begin
      if(terminal_count)
        h_cnt <= 0;
      else
        h_cnt <= h_cnt + 1;
    end
  end
  
  // Vertical Counter
  always @(posedge clk_cnt or posedge rst)
  begin
    if(rst)
      v_cnt <= 0;
    else
    begin
      if(v_cnt == V_TOTAL)
        v_cnt <= 0;
      else if(terminal_count)
        // Only increment line count at the end of the row.
        v_cnt <= v_cnt + 1;
      else
        v_cnt <= v_cnt;
    end
  end
  
  // Horizontal Sync Comparator (active low for 96 pixels)
  assign h_sync = ~(h_cnt >= H_DISPLAY + H_BACKPORCH && h_cnt <= H_DISPLAY + H_FRONTPORCH + H_PULSE - 1);
    
  // Vertical Sync Comparator (active low for 2 lines)
  assign v_sync = ~(v_cnt >= V_DISPLAY + V_BACKPORCH && v_cnt <= V_DISPLAY + V_BACKPORCH + V_PULSE - 1);

  // Display Area Comparator
  assign color_enable = (h_cnt < H_DISPLAY && v_cnt < V_DISPLAY);
 
  // Output Counter Values
  assign vga_h_cnt = h_cnt;
  assign vga_v_cnt = v_cnt;

  // Output the clock frequency used to update counter.
  assign update = clk_cnt; 

endmodule
