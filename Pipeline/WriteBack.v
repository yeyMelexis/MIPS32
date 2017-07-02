module WriteBack (i_clk,
                  i_a_rst_n,
                  i_s_rst,
                  i_we,
                  i_instr_MemAc,
                  i_Mem_out_MemAc,
                  o_instr_WrBc,
                  o_Mem_out_WrBc
                  );
              

input   [31:0]  i_instr_MemAc,  i_Mem_out_MemAc;
input           i_clk, 
                i_a_rst_n, 
                i_s_rst, 
                i_we;
output  [31:0]  o_instr_WrBc,   o_Mem_out_WrBc;

Pipe_register 
#(.WIDTH(32)) instr_WrBc( .i_clk       (i_clk),
                          .i_a_rst_n   (i_a_rst_n),
                          .i_s_rst     (i_s_rst),
                          .i_we        (i_we),
                          .i_data      (i_instr_MemAc),
                          .o_data      (o_instr_WrBc)
                        );

Pipe_register 
#(.WIDTH(32)) Mem_WrBc(   .i_clk       (i_clk),
                          .i_a_rst_n   (i_a_rst_n),
                          .i_s_rst     (i_s_rst),
                          .i_we        (i_we),
                          .i_data      (i_Mem_out_MemAc),
                          .o_data      (o_Mem_out_WrBc)
                       );

endmodule



