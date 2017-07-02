module Decode(i_clk,
              i_a_rst_n,
              i_s_rst,
              i_we,
              i_instr_fetch,
              i_PC_4_fetch,
              o_instr_dec,
              o_PC_4_dec
              );

input   [31:0] i_instr_fetch, i_PC_4_fetch;
input          i_clk, i_a_rst_n, i_s_rst, i_we;
output  [31:0] o_instr_dec, o_PC_4_dec;

Pipe_register 
#(.WIDTH(32)) instr_dec(  .i_clk       (i_clk),
                          .i_a_rst_n   (i_a_rst_n),
                          .i_s_rst     (i_s_rst),
                          .i_we        (i_we),
                          .i_data      (i_instr_fetch),
                          .o_data      (o_instr_dec)
                        );

Pipe_register 
#(.WIDTH(32)) PC4_dec(    .i_clk       (i_clk),
                          .i_a_rst_n   (i_a_rst_n),
                          .i_s_rst     (i_s_rst),
                          .i_we        (i_we),
                          .i_data      (i_PC_4_fetch),
                          .o_data      (o_PC_4_dec)
                      );
endmodule