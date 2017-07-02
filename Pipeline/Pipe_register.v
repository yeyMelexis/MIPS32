module Pipe_register( i_clk,
                      i_a_rst_n,
                      i_s_rst,
                      i_we,
                      i_data,
                      o_data
                      );

parameter WIDTH = 32;

input   [WIDTH - 1:0]   i_data;
input                   i_clk, i_we, i_a_rst_n, i_s_rst;
output reg  [WIDTH - 1:0]   o_data;
/////////////////////////////////////

always @(posedge i_clk or negedge i_a_rst_n) begin
  if(!i_a_rst_n)  
      o_data <= 0;
  else if(i_s_rst)
      o_data <= 0;
  else if(i_we)
      o_data <= i_data;
end  
 
endmodule
