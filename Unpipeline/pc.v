module pc(i_clk,
          i_rst_n,
          i_addr,
          o_addr);
  
input  i_clk, i_rst_n;
input       [31:0] i_addr;
output reg  [31:0] o_addr;

always @(posedge i_clk or negedge i_rst_n) begin
  if(!i_rst_n)  o_addr <= 0;
  else          o_addr <= i_addr;
end
  
endmodule
