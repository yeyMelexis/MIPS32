module DataPath(i_clk,
                i_rst_n,
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

input   i_clk,    i_rst_n, i_lw, i_sw, i_beq_bit;
input   i_RegDst, i_RegWrite, i_ExtOp,  i_Shift,
        i_ALUSrc, i_MemWrite, i_MemtoReg,
        i_Beq,    i_Bne,      i_J,      i_Jr,
        i_mtc0,   i_mfc0,     i_eret,   i_ext_int;

input    [5:0]    i_ALUCtrl;

output   [31:0] o_Instr;
/***********************************************/

wire  [31:0]  Instr_w;  
wire  [25:0]  Imm26_w;
wire  [15:0]  Imm16_w;
wire  [31:0]  PC_w, Next_PC_w;
wire          zero_w, w_overflow, w_exeption, w_wrong_addr;
wire  [31:0]  ALU_op1_w, ALU_op2_w;
wire  [4:0]   Rs_w, Rt_w, Rd_w, Shamt_w;
wire  [31:0]  GPreg_out1_w, GPreg_out2_w;
wire  [31:0]  Extender_out_w, ALU_result_w, MemData_out_w;
wire  [4:0]   Mux_Rt_or_Rd_w; 
wire  [31:0]  Mux_Shamt_or_GpReg_w, Mux_Extend_or_GpReg_w, Mux_Mem_or_ALU_w, Mux_MemALU_or_COP0_w;
wire  [31:0]  w_Cop0_data_out, EPC_w;

assign Imm26_w = o_Instr[25:0];
assign Imm16_w = o_Instr[15:0];

assign Instr_w = o_Instr;
assign Rs_w    = Instr_w[25:21];
assign Rt_w    = Instr_w[20:16];
assign Rd_w    = Instr_w[15:11];
assign Shamt_w = Instr_w[10:6];

assign w_wrong_addr = |PC_w[1:0];
  
instruction_memory instruction_memory_Mips(.i_addr        (PC_w),
                                           .o_instruction (o_Instr)
                                           );
                          
NextPC NextPC_Mips (.i_Imm26        (Imm26_w),
                    .i_PC           (PC_w),
                    .i_Rs           (GPreg_out1_w),
                    .i_Zero         (zero_w),
                    .i_J            (i_J),
                    .i_Jr           (i_Jr),
                    .i_Beq          (i_Beq),
                    .i_Bne          (i_Bne),
                    .i_exeption     (w_exeption),
                    .i_eret         (i_eret),
                    .i_epc_to_pc    (EPC_w),
                    .o_NextPC       (Next_PC_w)
                    );
ALU ALU_Mips(.i_op1       (Mux_Shamt_or_GpReg_w),
             .i_op2       (Mux_Extend_or_GpReg_w),
             .i_control   (i_ALUCtrl),
             .i_lw        (i_lw),
             .i_sw        (i_sw),
             .i_beq_bit   (i_beq_bit),
             .o_result    (ALU_result_w),
             .o_overflow  (w_overflow),
             .o_zero      (zero_w)
             );
           
feg_file feg_file_Mips(.i_clk   (i_clk),
                       .i_regA  (Rs_w),
                       .i_regB  (Rt_w),
                       .i_regW  (Mux_Rt_or_Rd_w),
                       .i_we    (i_RegWrite),
                       .i_BusW  (Mux_MemALU_or_COP0_w),
                       .o_BusA  (GPreg_out1_w),
                       .o_BusB  (GPreg_out2_w)
                       );
                
data_memory data_memory_Mips(.i_clk   (i_clk),
                             .i_addr  (ALU_result_w),
                             .i_data  (GPreg_out2_w),
                             .o_data  (MemData_out_w),
                             .i_we    (i_MemWrite)
                             );
                   
pc pc_Mips(.i_clk   (i_clk),
           .i_rst_n (i_rst_n),
           .i_addr  (Next_PC_w),
           .o_addr  (PC_w)
           );
          
Extender Extender_Mips(.i_data16  (Imm16_w),
                       .i_ExtOp   (i_ExtOp),
                       .o_data32  (Extender_out_w)
                       );
                
Mux2   Mux_Rt_or_Rd(.in0    (Rt_w),
                    .in1    (Rd_w),
                    .i_sel  (i_RegDst),
                    .out    (Mux_Rt_or_Rd_w)
                    );

Mux2   #(.WIDTH(32))
       Mux_Shamt_or_GpReg(.in0    (GPreg_out1_w),
                          .in1    ({{27{1'b0}},Shamt_w}),
                          .i_sel  (i_Shift),
                          .out    (Mux_Shamt_or_GpReg_w)
                          );
                    
Mux2   #(.WIDTH(32))  
       Mux_Extend_or_GpReg(.in0   (GPreg_out2_w),
                           .in1   (Extender_out_w),
                           .i_sel (i_ALUSrc),
                           .out   (Mux_Extend_or_GpReg_w)
                           );
                    
Mux2   #(.WIDTH(32))
       Mux_Mem_or_ALU(.in0    (ALU_result_w),
                      .in1    (MemData_out_w),
                      .i_sel  (i_MemtoReg),
                      .out    (Mux_Mem_or_ALU_w)
                      );                               


Mux2   #(.WIDTH(32))
       Mux_MemALU_or_COP0(.in0    (Mux_Mem_or_ALU_w),
                          .in1    (Cop0_data_w),
                          .i_sel  (i_mfc0),
                          .out    (Mux_MemALU_or_COP0_w)
                          ); 


                          
cop0 coproc0 (.i_clk          (i_clk), 
              .i_rst_n        (i_rst_n),
				      .i_overflow     (w_overflow),
				      .i_wrong_addr   (w_wrong_addr),
				      .i_ext_int      (i_ext_int),
				      .i_data         (GPreg_out2_w),
				      .i_addr         (Rd_w),
				      .i_pc_to_epc    (PC_w),
				      .i_mtc0         (i_mtc0),
				      .i_eret         (i_eret),
				      .o_epc_to_pc    (EPC_w),
				      .o_exeption     (w_exeption),
				      .o_data         (w_Cop0_data_out)
				      );                          
                          
                                                                                                                                                 
endmodule
