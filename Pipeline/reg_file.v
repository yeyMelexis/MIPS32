module feg_file(i_clk,
                i_regA,
                i_regB,
                i_regW,
                i_we,
                i_BusW,
                o_BusA,
                o_BusB
                );

input   [4:0]  i_regA, i_regB, i_regW;
input          i_clk;
input          i_we;
input   [31:0]  i_BusW;
output  [31:0]  o_BusA, o_BusB;
/////////////////////////////////////
reg [31:0] memory [31:0];

assign o_BusA = memory[i_regA];
assign o_BusB = memory[i_regB];

always @(posedge i_clk) begin
  if(i_we) begin 
    memory[i_regW] <= i_BusW;
  end  
  memory[0] <= 32'b0;
end
  
  
  
endmodule
