module MIPS_one_cycle(i_clk,
                      i_rst_n,
                      i_ext_int
                      );
input i_clk, i_rst_n, i_ext_int;

wire    w_RegDst, w_RegWrite, w_ExtOp,  w_Shift,
        w_ALUSrc, w_MemWrite, w_MemtoReg,
        w_Beq,    w_Bne,      w_J,      w_Jr;
wire    w_lw, w_sw, w_mtc0, w_mfc0, w_eret, w_beq_bit;
wire    [5:0]     w_ALUCtrl;

wire    [31:0] w_Instr;

DataPath DataP1(.i_clk        (i_clk),
                .i_rst_n      (i_rst_n),
                .i_RegDst     (w_RegDst),
                .i_RegWrite   (w_RegWrite),
                .i_ExtOp      (w_ExtOp),
                .i_Shift      (w_Shift),
                .i_ALUSrc     (w_ALUSrc),
                .i_MemWrite   (w_MemWrite),
                .i_MemtoReg   (w_MemtoReg),
                .i_Beq        (w_Beq),
                .i_Bne        (w_Bne),
                .i_J          (w_J),
                .i_Jr         (w_Jr),
                .i_ALUCtrl    (w_ALUCtrl),
                .i_lw         (w_lw),
                .i_sw         (w_sw),
                .i_beq_bit    (w_beq_bit),
                .i_mtc0       (w_mtc0),
                .i_mfc0       (w_mfc0),
                .i_eret       (w_eret),
                .i_ext_int    (i_ext_int),
                .o_Instr      (w_Instr)
                );

Control Ctrl_1(.i_instr       (w_Instr),
               .o_RegDst      (w_RegDst),
               .o_RegWrite    (w_RegWrite),
               .o_ExtOp       (w_ExtOp),
               .o_Shift       (w_Shift),
               .o_ALUSrc      (w_ALUSrc),
               .o_MemWrite    (w_MemWrite),
               .o_MemtoReg    (w_MemtoReg),
               .o_Beq         (w_Beq),
               .o_Bne         (w_Bne),
               .o_J           (w_J),
               .o_Jr          (w_Jr),
               .o_ALUCtrl     (w_ALUCtrl),
               .o_lw          (w_lw),
               .o_sw          (w_sw),
               .o_beq_bit     (w_beq_bit),
               .o_mtc0        (w_mtc0),
               .o_mfc0        (w_mfc0),
               .o_eret        (w_eret)
               );  
endmodule
