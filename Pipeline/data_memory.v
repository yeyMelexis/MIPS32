module data_memory(i_clk,
                   i_addr,
                   i_data,
                   o_data,
                   i_we
                   );

input   [31:0]  i_addr, i_data;
input           i_clk, i_we;
output  [31:0]  o_data;
//////////////////////////////////

parameter MEM_WIDTH = 128;
reg     [31:0]  Data_Memory [MEM_WIDTH - 1: 0];


always @(posedge i_clk) begin
  if(i_we) Data_Memory[i_addr[31:2]] = i_data;
end//Data writing 

assign o_data = (i_we == 0) ? Data_Memory[i_addr[31:2]] : 32'b0; //Data reading
  
endmodule
