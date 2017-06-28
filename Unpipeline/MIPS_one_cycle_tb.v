module MIPS_one_cycle_tb;


reg i_clk, i_rst_n, i_ext_int;

initial begin
  i_clk = 0;
  forever #5 i_clk = ~ i_clk;
end

initial begin
  i_rst_n = 0;
  repeat(3) @(posedge i_clk)
  i_rst_n = 1;
end

integer i;
integer number_of_Test = 1;
initial begin
  i_ext_int = 0;

  case(number_of_Test)
    1: $readmemb("D:/Melexis/labs/MIPS/Unpipeline/Tests/Test_1.txt",MIPS_one_cycle1.DataP1.instruction_memory_Mips.instr_MEM);
    2: $readmemb("D:/Melexis/labs/MIPS/Unpipeline/Tests/Test_2.txt",MIPS_one_cycle1.DataP1.instruction_memory_Mips.instr_MEM);
    3: $readmemb("D:/Melexis/labs/MIPS/Unpipeline/Tests/Test_3.txt",MIPS_one_cycle1.DataP1.instruction_memory_Mips.instr_MEM);
    4: $readmemb("D:/Melexis/labs/MIPS/Unpipeline/Tests/Test_4.txt",MIPS_one_cycle1.DataP1.instruction_memory_Mips.instr_MEM);
    5: $readmemb("D:/Melexis/labs/MIPS/Unpipeline/Tests/Test_5.txt",MIPS_one_cycle1.DataP1.instruction_memory_Mips.instr_MEM);
    6: $readmemb("D:/Melexis/labs/MIPS/Unpipeline/Tests/Test_6.txt",MIPS_one_cycle1.DataP1.instruction_memory_Mips.instr_MEM);
  endcase
  
  #60 i_ext_int = 1'b1;
  #10 i_ext_int = 1'b0;
     
  $finish;
end

MIPS_one_cycle MIPS_one_cycle1(i_clk,
                               i_rst_n,
                               i_ext_int
                               );

endmodule