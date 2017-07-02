module DataPath(i_clk,
                i_a_rst_n,
                //i_s_rst_dec,
                i_s_rst_exec,
                i_s_rst_MemAc,
                i_s_rst_WrBc,
                //i_we_dec,
                i_we_exec,
                i_we_MemAc,
                i_we_WrBc,
                i_we_pc,
                i_RegDst,
                i_RegWrite,
                i_ExtOp,
                i_Shift,
                i_ALUSrc,
                i_MemWrite,
                i_MemtoReg,
                i_Beq,
                i_Bne,
                i_J,
                i_Jr,
                i_ALUCtrl,
                i_lw,
                i_sw,
                i_beq_bit,
                i_mtc0,
                i_mfc0,
                i_eret,
                i_ext_int,
                o_Instr);

input   i_clk,
        i_a_rst_n,
        //i_s_rst_dec,
        i_s_rst_exec,
        i_s_rst_MemAc,
        i_s_rst_WrBc,
        //i_we_dec,
        i_we_exec,
        i_we_MemAc,
        i_we_WrBc,
        i_we_pc;

input   i_lw, i_sw, i_beq_bit;
input   i_RegDst, i_RegWrite, i_ExtOp,  i_Shift,
        i_ALUSrc, i_MemWrite, i_MemtoReg,
        i_Beq,    i_Bne,      i_J,      i_Jr,
        i_mtc0,   i_mfc0,     i_eret,   i_ext_int;

input    [5:0]    i_ALUCtrl;

output   [31:0] o_Instr;
/***********************************************/

wire  [31:0]  w_Instr_fetch, w_Instr_dec, w_Instr_exec, w_Instr_MemAc, w_Instr_WrBc;  
wire  [25:0]  Imm26_w;
wire  [15:0]  Imm16_w;
wire  [31:0]  PC_w, Next_PC_w, PC_4_dec_w, PC_4_w;
wire          zero_w, zero_dec_w, w_overflow, w_exeption, w_wrong_addr;
wire  [31:0]  w_op1_exec, w_op2_exec, w_op2_MemAc;
wire  [4:0]   Rs_dec_w, Rt_dec_w, Rt_WrBc_w, Rd_WrBc_w, Shamt_dec_w;
wire  [31:0]  GPreg_out1_w, GPreg_out2_w;
wire  [31:0]  Extender_out_w, ALU_result_w, MemData_out_w, ALU_result_MemAc_w;
wire  [4:0]   Mux_Rt_or_Rd_w; 
wire  [31:0]  Mux_Shamt_or_GpReg_w, Mux_Extend_or_GpReg_w, Mux_Mem_or_ALU_w, Mux_MemALU_or_COP0_w, Mux_Mem_or_ALU_WrBc_w;
wire  [31:0]  w_Cop0_data_out, EPC_w, w_GP2_exec, w_GP2_MemAc;
wire  [4:0] w_Rd_dec,
						w_Rd_exec,
						w_Rd_MemAc,
						w_Rd_WrBc,
						w_Rs_fetch,
						w_Rt_fetch;

wire    w_we_dec, w_s_rst_dec;

assign w_Rd_dec   = w_Instr_dec[15:11];						
assign w_Rd_exec  = w_Instr_exec[15:11];
assign w_Rd_MemAc = w_Instr_MemAc[15:11];
assign w_Rd_WrBc  = w_Instr_WrBc[15:11];
assign w_Rs_fetch = w_Instr_fetch[25:21];
assign w_Rt_fetch = w_Instr_fetch[20:16];

assign o_Instr = w_Instr_dec;
assign Imm26_w = w_Instr_dec[25:0];
assign Imm16_w = w_Instr_dec[15:0];

assign Rs_dec_w    = w_Instr_dec[25:21];
assign Rt_dec_w    = w_Instr_dec[20:16];
assign Shamt_dec_w = w_Instr_dec[10:6];
assign Rt_WrBc_w   = w_Instr_WrBc[20:16];
assign Rd_WrBc_w   = w_Instr_WrBc[15:11];


assign w_wrong_addr = |PC_w[1:0];

//******************Fetch**************************//
  
instruction_memory instruction_memory_Mips(.i_addr        (PC_w),
                                           .o_instruction (w_Instr_fetch)
                                           );
pc pc_Mips(.i_clk   (i_clk),
           .i_rst_n (i_a_rst_n),
           .i_we    (i_we_pc),
           .i_addr  (Next_PC_w),
           .o_addr  (PC_w)
           );
                          
NextPC NextPC_Mips (.i_Imm26        (Imm26_w),
                    .i_PC           (PC_w),
                    .i_PC_4_dec     (PC_4_dec_w),
                    .i_Rs           (GPreg_out1_w),
                    .i_Zero_dec     (zero_dec_w),
                    .i_J            (i_J),
                    .i_Jr           (i_Jr),
                    .i_Beq          (i_Beq),
                    .i_Bne          (i_Bne),
                    .i_exeption     (w_exeption),
                    .i_eret         (i_eret),
                    .i_epc_to_pc    (EPC_w),
                    .i_s_rst_dec    (w_s_rst_dec),
                    .o_NextPC       (Next_PC_w),
                    .o_PC_4         (PC_4_w)
                    );
//********************************************// 

//*******************Decode*******************//  
                 
feg_file feg_file_Mips(.i_clk   (i_clk),
                       .i_regA  (Rs_dec_w),
                       .i_regB  (Rt_dec_w),
                       .i_regW  (Mux_Rt_or_Rd_w),
                       .i_we    (i_RegWrite),
                       .i_BusW  (Mux_MemALU_or_COP0_w),
                       .o_BusA  (GPreg_out1_w),
                       .o_BusB  (GPreg_out2_w)
                       );
                       
Extender Extender_Mips(.i_data16  (Imm16_w),
                       .i_ExtOp   (i_ExtOp),
                       .o_data32  (Extender_out_w)
                       );
                       
Mux2   #(.WIDTH(5))
       Mux_Rt_or_Rd(.in0    (Rt_WrBc_w),
                    .in1    (Rd_WrBc_w),
                    .i_sel  (i_RegDst),
                    .out    (Mux_Rt_or_Rd_w)
                    );

assign zero_dec_w = (GPreg_out1_w == GPreg_out1_w);                
//*******************************************************//

//***********************Execute*************************//                                           
Mux2   #(.WIDTH(32))
       Mux_Shamt_or_GpReg(.in0    (GPreg_out1_w),
                          .in1    ({{27{1'b0}},Shamt_dec_w}),
                          .i_sel  (i_Shift),
                          .out    (Mux_Shamt_or_GpReg_w)
                          );
                    
Mux2   #(.WIDTH(32))  
       Mux_Extend_or_GpReg(.in0   (GPreg_out2_w),
                           .in1   (Extender_out_w),
                           .i_sel (i_ALUSrc),
                           .out   (Mux_Extend_or_GpReg_w)
                           );
                                               
ALU ALU_Mips(.i_op1       (w_op1_exec),
             .i_op2       (w_op2_exec),
             .i_control   (i_ALUCtrl),
             .i_lw        (i_lw),
             .i_sw        (i_sw),
             .i_beq_bit   (i_beq_bit),
             .o_result    (ALU_result_w),
             .o_overflow  (w_overflow),
             .o_zero      (zero_w)
             );
           
//********************************************************//

//*******************Memory Access***********************//                
data_memory data_memory_Mips(.i_clk   (i_clk),
                             .i_addr  (ALU_result_MemAc_w),
                             .i_data  (w_GP2_MemAc),
                             .o_data  (MemData_out_w),
                             .i_we    (i_MemWrite)
                             );
//********************************************************//                                           

//***********************Write Back***********************//                    
Mux2   #(.WIDTH(32))
       Mux_Mem_or_ALU(.in0    (ALU_result_MemAc_w),
                      .in1    (MemData_out_w),
                      .i_sel  (i_MemtoReg),
                      .out    (Mux_Mem_or_ALU_w)
                      );                               


Mux2   #(.WIDTH(32))
       Mux_MemALU_or_COP0(.in0    (Mux_Mem_or_ALU_WrBc_w),
                          .in1    (w_Cop0_data_out),
                          .i_sel  (i_mfc0),
                          .out    (Mux_MemALU_or_COP0_w)
                          ); 
//********************************************************//

                          
cop0 coproc0 (.i_clk          (i_clk), 
              .i_rst_n        (i_a_rst_n),
				      .i_overflow     (w_overflow),
				      .i_wrong_addr   (w_wrong_addr),
				      .i_ext_int      (i_ext_int),
				      .i_data         (GPreg_out2_w),
				      .i_addr         (Rd_WrBc_w),
				      .i_pc_to_epc    (PC_w),
				      .i_mtc0         (i_mtc0),
				      .i_eret         (i_eret),
				      .o_epc_to_pc    (EPC_w),
				      .o_exeption     (w_exeption),
				      .o_data         (w_Cop0_data_out)
				      );  
				      
//******PIPELINED REGISRERS******//
/*********************************/


Decode decode(.i_clk           (i_clk),
              .i_a_rst_n       (i_a_rst_n),
              .i_s_rst         (w_s_rst_dec),
              .i_we            (1'b1),
              .i_instr_fetch   (w_Instr_fetch),
              .i_PC_4_fetch    (PC_4_w),
              .o_instr_dec     (w_Instr_dec),
              .o_PC_4_dec      (PC_4_dec_w)
              );				      
				                              
Execute execute ( .i_clk         (i_clk),
                  .i_a_rst_n     (i_a_rst_n),
                  .i_s_rst       (i_s_rst_exec),
                  .i_we          (i_we_exec),
                  .i_instr_dec   (w_Instr_dec),
                  .i_op1_dec     (Mux_Shamt_or_GpReg_w),
                  .i_op2_dec     (Mux_Extend_or_GpReg_w),
                  .o_instr_exec  (w_Instr_exec),
                  .o_op1_exec    (w_op1_exec),
                  .o_op2_exec    (w_op2_exec),
                  .i_GP2_dec     (GPreg_out2_w),
                  .o_GP2_exec    (w_GP2_exec)
                );
 
                                           
MemAcces memAcces(.i_clk                (i_clk),
                  .i_a_rst_n            (i_a_rst_n),
                  .i_s_rst              (i_s_rst_MemAc),
                  .i_we                 (i_we_MemAc),
                  .i_instr_exec         (w_Instr_exec),
                  .i_op2_exec           (w_op2_exec),
                  .i_ALU_result_exec    (ALU_result_w),
                  .o_instr_MemAc        (w_Instr_MemAc),
                  .o_op2_MemAc          (w_op2_MemAc),
                  .o_ALU_result_MemAc   (ALU_result_MemAc_w),
                  .i_GP2_exec           (w_GP2_exec),
                  .o_GP2_MemAc          (w_GP2_MemAc)
                  );                                                                                                                                                 

WriteBack writeBack ( .i_clk                (i_clk),
                      .i_a_rst_n            (i_a_rst_n),
                      .i_s_rst              (i_s_rst_WrBc),
                      .i_we                 (i_we_WrBc),
                      .i_instr_MemAc        (w_Instr_MemAc),
                      .i_Mem_out_MemAc      (Mux_Mem_or_ALU_w),
                      .o_instr_WrBc         (w_Instr_WrBc),
                      .o_Mem_out_WrBc       (Mux_Mem_or_ALU_WrBc_w)
                    );

HazardControl hazardControl(	.i_instr_fetch  (w_Instr_fetch),
                             .i_instr_dec    (w_Instr_dec),
						                 .i_instr_exec   (w_Instr_exec),
						                 .i_instr_MemAc  (w_Instr_MemAc),
						                 .i_instr_WrBc   (w_Instr_WrBc),
						                 .o_s_rst_dec    (w_s_rst_dec),
						                 .o_we_dec       (w_we_dec)
						                );	

endmodule
