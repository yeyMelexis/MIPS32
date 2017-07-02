module MemAcces(i_clk,
                i_a_rst_n,
                i_s_rst,
                i_we,
                i_instr_exec,
                i_op2_exec,
                i_ALU_result_exec,
                o_instr_MemAc,
                o_op2_MemAc,
                o_ALU_result_MemAc,
                i_GP2_exec,
                o_GP2_MemAc
                );
              

input   [31:0]  i_instr_exec,  i_op2_exec,  i_ALU_result_exec, i_GP2_exec;
input           i_clk, 
                i_a_rst_n, 
                i_s_rst, 
                i_we;
output  [31:0]  o_instr_MemAc, o_op2_MemAc, o_ALU_result_MemAc, o_GP2_MemAc;

Pipe_register 
#(.WIDTH(32)) instr_MemAc(.i_clk       (i_clk),
                          .i_a_rst_n   (i_a_rst_n),
                          .i_s_rst     (i_s_rst),
                          .i_we        (i_we),
                          .i_data      (i_instr_exec),
                          .o_data      (o_instr_MemAc)
                        );

Pipe_register 
#(.WIDTH(32)) op2_MemAc(  .i_clk       (i_clk),
                          .i_a_rst_n   (i_a_rst_n),
                          .i_s_rst     (i_s_rst),
                          .i_we        (i_we),
                          .i_data      (i_op2_exec),
                          .o_data      (o_op2_MemAc)
                       );

Pipe_register 
#(.WIDTH(32)) ALU_MemAc(  .i_clk       (i_clk),
                          .i_a_rst_n   (i_a_rst_n),
                          .i_s_rst     (i_s_rst),
                          .i_we        (i_we),
                          .i_data      (i_ALU_result_exec),
                          .o_data      (o_ALU_result_MemAc)
                       );

Pipe_register 
#(.WIDTH(32)) GP2_MemAc(  .i_clk       (i_clk),
                          .i_a_rst_n   (i_a_rst_n),
                          .i_s_rst     (i_s_rst),
                          .i_we        (i_we),
                          .i_data      (i_GP2_exec),
                          .o_data      (o_GP2_MemAc)
                       );
endmodule


