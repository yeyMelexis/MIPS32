module instruction_memory(i_addr,
                          o_instruction);
                           
  input    [31:0] i_addr;      
  output   [31:0] o_instruction;
  
  parameter   MEM_WIDTH = 128;// Memory width
  
  reg [31:0]  instr_MEM [MEM_WIDTH - 1:0];
  
  assign o_instruction = instr_MEM[i_addr[31:2]];
    
endmodule
