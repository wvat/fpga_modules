`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module top_module(clk,          // Master clock
                  rst,          // Active high reset
                  sw,           // Color input
                  p1_up,        // Paddle controls 
                  p1_down,      // .
                  p2_up,        // .
                  p2_down,      // .
                  color_out,    // Color output to display
                  h_sync,       // Horizontal sync to display
                  v_sync,       // Vertrical sync to display
                  anode_sel,    // Seven segment anode control
                  segments_out, // Seven segment digit output
                 );

  input clk;
  input rst;
  input [7:0] sw;
  input p1_up;
  input p1_down;
  input p2_up;
  input p2_down;

  output [7:0] color_out;       
  output h_sync;
  output v_sync;
  output [3:0] anode_sel;
  output [7:0] segments_out;

  localparam T_GAME_1MS = T_GAME_1MS; // Division factor to achieve a 1ms game clock period

  localparam PIXELS_X = 640;
  localparam PIXELS_Y = 480;

  localparam PADDLE_OFFSET = 10; // Pixel distance of paddle from screen edge

  // Player paddle dimensions and reset coords
  localparam P1_PADDLE_W = 20;
  localparam P1_PADDLE_H = 150;
  localparam P1_PADDLE_X = PADDLE_OFFSET;
  localparam P1_PADDLE_Y = 75;

  localparam P2_PADDLE_W = 20;
  localparam P2_PADDLE_H = 150;
  localparam P2_PADDLE_X = PIXELS_X - P2_PADDLE_W - PADDLE_OFFSET;
  localparam P2_PADDLE_Y = 75;
  
  // Ball dimensions
  localparam BALL_W = 32;
  localparam BALL_H = 32;
  localparam BALL_C_X = 305;
  localparam BALL_C_Y = 225;
  
  // X coord of the dividing line
  localparam DIVIDER_X = 320;   
  
  // Game states
  localparam IDLE      = 2'b00; 
  localparam RUNNING   = 2'b01; 
  localparam POINT     = 2'b10; 
  localparam FINISHED  = 2'b11;
 
  // Current state
  reg [1:0] state;
  
  // Player paddles
  reg [9:0] p1_paddle_x;
  reg [9:0] p1_paddle_y;
  reg p1_ball_dir_x;
  
  reg p1_up_r;
  reg p1_down_r;
  
  reg [9:0] p2_paddle_x;
  reg [9:0] p2_paddle_y;
  reg p2_ball_dir_x;
  
  reg p2_up_r;
  reg p2_down_r;

  // Ball
  reg [9:0] x;
  reg [9:0] y;
  reg ball_dir_x;
  reg ball_dir_y;
  
  // Color of the current pixel
  reg [7:0] color_reg;          
  
  // Point Conditions
  //wire p1_point = (x >= PIXELS_X);   
  //wire p2_point = (x <= 0);          
  reg p1_point;
  reg p2_point;
  
  wire color_enable;            // Used to signal if the current position is in
                                // the display area.

  wire [9:0] h_cnt;             // Pixel position X
  wire [9:0] v_cnt;             // Pixel position Y

  // Generate grid
  wire v_en = ~v_cnt[9] & (|v_cnt[8:5]) & (v_cnt[4:0] == 5'b00000); 
  wire h_en = (|h_cnt[9:5]) & (h_cnt[4:0] == 5'b00000); 

  // Contact points
  wire wall_left   = (x <= 0);
  wire wall_right  = (x + BALL_W >= PIXELS_X);
  wire wall_top    = (y <= 0);
  wire wall_bottom = (y + BALL_H >= PIXELS_Y);
  wire paddle_p1   = (x <= p1_paddle_x + P1_PADDLE_W && y >= p1_paddle_y && y <= p1_paddle_y + P1_PADDLE_H);
  wire paddle_p2   = (x + BALL_W >= p2_paddle_x  && y >= p2_paddle_y && y <= p2_paddle_y + P2_PADDLE_H);
  
  // Point counters
  reg [4:0] p1_point_cnt;
  reg [4:0] p2_point_cnt;
  
  reg gameover;
  reg [25:0] g_cnt;
  reg g_clk;
  
  wire g_clk_en = ~(state == IDLE);

  reg hold_done;     // Flag used to hold before accepting input from up/down inputs for the paddle.
  reg hold_cnt;      // Counter used to keep track of time before the hold flag is set.

  // VGA controller handles generation of h & v sync and outputs
  // h and v pixel positions as well as an active display area indicator.
  vga_controller vga_cntl(.mclk(clk),
                          .rst(rst),
                          .h_sync(h_sync),
                          .v_sync(v_sync),
                          .color_enable(color_enable),
                          .vga_v_cnt(v_cnt),
                          .vga_h_cnt(h_cnt),
                          .update()
                         );
 
  // Seven segment display module, used to display player scores.
  seven_seg seven_seg(.mclk(clk), 
                      .rst_N(~rst),
                      .digits_in({5'b0, p1_point_cnt, 5'b0, p2_point_cnt}),
                      .anode_sel(anode_sel),
                      .segments_out(segments_out)
                     );

  // Set the hold flag 
  always @(posedge g_cnt or posedge rst) begin
    if(rst) hold_done <= 0;
    else if(~hold_done) begin
      hold_cnt <= hold_cnt + 1;
      if(hold_cnt == 200) begin
        if()
                    
                    
  // Sync paddle control inputs to the master clock
  always @(posedge clk or posedge rst) begin
    if(rst) begin
      p1_up_r    <= 0;
      p2_up_r    <= 0;
      p1_down_r  <= 0;
      p2_down_r  <= 0;
    end
    else if(hold_done) begin
      p1_up_r    <= p1_up;
      p1_down_r  <= p1_down;
      p2_up_r    <= p2_up;
      p2_down_r  <= p2_down;
    end
  end
 
  // Generate game clock which is what game elements are clocked
  // off of. 
  always @(posedge clk or posedge rst) begin
    if(rst) begin
      g_cnt <= 0;
    end
    else if(g_clk_en) begin
      if(g_cnt >= T_GAME_1MS) begin
        g_cnt <= 0;
        g_clk <= ~g_clk;
      end
      else g_cnt <= g_cnt + 1;
    end
  end

  // Paddle/Player 1
  always @(posedge g_clk) begin
    if(rst) begin
      p1_paddle_x <= P1_PADDLE_X;
      p1_paddle_y <= P1_PADDLE_Y;
    end
    else begin
      if(p1_up_r)
        p1_paddle_y <= p1_paddle_y - 1;
      else if(p1_down_r)
        p1_paddle_y <= p1_paddle_y + 1;
    end
    if(p1_paddle_y + P1_PADDLE_H >= PIXELS_Y) p1_paddle_y <= PIXELS_Y - P1_PADDLE_H - 1;
    else if(p1_paddle_y <= 0)  p1_paddle_y <= 1;
  end

  // Paddle/Player 2
  always @(posedge g_clk) begin
    if(rst) begin
      p2_paddle_x <= P2_PADDLE_X;
      p2_paddle_y <= P2_PADDLE_Y;
    end
    else begin
      if(p2_up_r)
        p2_paddle_y <= p2_paddle_y - 1;
      else if(p2_down_r)
        p2_paddle_y <= p2_paddle_y + 1;
    end
    if(p2_paddle_y + P2_PADDLE_H >= PIXELS_Y) p2_paddle_y <= PIXELS_Y - P2_PADDLE_H - 1;
    else if(p2_paddle_y <= 0)  p2_paddle_y <= 1;
  end

  // Block
  always @(posedge g_clk) begin
    if(rst) begin
      x <= BALL_C_X;
      y <= BALL_C_Y;
      p1_point <= 0;
      p2_point <= 0;
      p1_point_cnt <= 0;
      p2_point_cnt <= 0;
    end
    else if(state == IDLE) begin
      x <= BALL_C_X;
      y <= BALL_C_Y;
      p1_point <= 0;
      p2_point <= 0;
    end
    else begin
      // X-axis
      if(wall_left || wall_right || paddle_p1 || paddle_p2) begin 
        if(wall_right) begin     
          x <= PIXELS_X - BALL_W - 1;
          p1_point_cnt <= p1_point_cnt + 1;
          p1_point <= 1;
        end
        else if(wall_left) begin
          x <= 1;
          p2_point_cnt <= p2_point_cnt + 1;
          p2_point <= 1;
        end
        else if(paddle_p1) 
          x <= p1_paddle_x + P1_PADDLE_W + 1;
        else if(paddle_p2) 
          x <= p2_paddle_x - BALL_W - 1;
        // Contact on X so change direction on X-axis
        ball_dir_x <= ~ball_dir_x; 
      end
      else begin
        if(ball_dir_x) x <= x + 1;
        else x <= x - 1;
      end

      // Y-axis
      if(wall_bottom || wall_top) begin 
        if(wall_bottom)    y <= PIXELS_Y - BALL_H - 1;
        else if(wall_top)  y <= 1;
        // Contact on Y so change direction on Y-axis
        ball_dir_y <= ~ball_dir_y; 
      end
      else begin
        if(ball_dir_y) y <= y + 1;
        else y <= y - 1;
      end
    end
  end

  // State machine
  always @(posedge clk or posedge rst) begin
    if(rst) begin
      state <= IDLE;
      gameover <= 0;
      //p1_point_cnt <= 0;
      //p2_point_cnt <= 0;
    end
    else begin
      case(state) 
        IDLE:
          if(p1_up || p2_up || p1_down || p2_down)
            state <= RUNNING;
        RUNNING:
          if(p1_point || p2_point)
            state <= POINT;
        POINT: begin
          //p1_point_cnt <= p1_point_cnt + 1;
          if(p1_point_cnt >= 4'hA || p2_point_cnt) state <= FINISHED;
          else state <= IDLE;
        end
        FINISHED:
          gameover <= 1; // 1
        default: begin
          state <= IDLE;
          gameover <= 0;
        end
      endcase
    end
  end
 
  // Current pixel control
  always @(posedge clk or posedge rst) begin
    if(rst)
      color_reg <= 0;
    else begin
      // Ball
      if(h_cnt >= x && h_cnt <= x + BALL_W && v_cnt >= y && v_cnt <= y + BALL_H)
        color_reg <= 8'h0;
      // Divider/Net
      else if(h_cnt == DIVIDER_X) 
        color_reg <= 8'hE0;
      // Paddle P1
      else if(h_cnt >= p1_paddle_x && h_cnt <= p1_paddle_x + P1_PADDLE_W && v_cnt >= p1_paddle_y && v_cnt <= p1_paddle_y + P1_PADDLE_H)
        color_reg <= 8'h0;
      // Paddle P2
      else if(h_cnt >= p2_paddle_x && h_cnt <= p2_paddle_x + P2_PADDLE_W && v_cnt >= p2_paddle_y && v_cnt <= p2_paddle_y + P2_PADDLE_H)
        color_reg <= 8'h0;
      // Background
      else color_reg <= 8'hFC;
    end
  end
 
  // Only output color if inside valid display area
  assign color_out = (color_enable) ? color_reg : 0; 

endmodule
