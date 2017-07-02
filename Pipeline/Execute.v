module Execute (i_clk,
                i_a_rst_n,
                i_s_rst,
                i_we,
                i_instr_dec,
                i_op1_dec,
                i_op2_dec,
                o_instr_exec,
                o_op1_exec,
                o_op2_exec,
                i_GP2_dec,
                o_GP2_exec
                );
              

input   [31:0] i_instr_dec, i_op1_dec, i_op2_dec, i_GP2_dec;
input          i_clk, i_a_rst_n, i_s_rst, i_we;
output  [31:0] o_instr_exec, o_op1_exec, o_op2_exec, o_GP2_exec;

Pipe_register 
#(.WIDTH(32)) instr_exec( .i_clk       (i_clk),
                          .i_a_rst_n   (i_a_rst_n),
                          .i_s_rst     (i_s_rst),
                          .i_we        (i_we),
                          .i_data      (i_instr_dec),
                          .o_data      (o_instr_exec)
                        );

Pipe_register 
#(.WIDTH(32)) op1_exec(   .i_clk       (i_clk),
                          .i_a_rst_n   (i_a_rst_n),
                          .i_s_rst     (i_s_rst),
                          .i_we        (i_we),
                          .i_data      (i_op1_dec),
                          .o_data      (o_op1_exec)
                       );

Pipe_register 
#(.WIDTH(32)) op2_exec(   .i_clk       (i_clk),
                          .i_a_rst_n   (i_a_rst_n),
                          .i_s_rst     (i_s_rst),
                          .i_we        (i_we),
                          .i_data      (i_op2_dec),
                          .o_data      (o_op2_exec)
                       );
                       
Pipe_register 
#(.WIDTH(32)) GP2_exec(   .i_clk       (i_clk),
                          .i_a_rst_n   (i_a_rst_n),
                          .i_s_rst     (i_s_rst),
                          .i_we        (i_we),
                          .i_data      (i_GP2_dec),
                          .o_data      (o_GP2_exec)
                       );                      
endmodule

