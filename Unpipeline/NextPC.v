module NextPC(i_Imm26,
              i_PC,
              i_Rs,
              i_Zero,
              i_J,
              i_Jr,
              i_Beq,
              i_Bne,
              i_exeption,
              i_eret,
              i_epc_to_pc,
              o_NextPC
              );
              
input   [25:0]  i_Imm26;
input   [31:0]  i_PC, i_Rs, i_epc_to_pc;
input           i_J, i_Jr, i_Zero, i_Bne, i_Beq, i_eret, i_exeption;
output  [31:0]  o_NextPC;

wire [15:0] Imm16 = i_Imm26[15:0];
wire [27:0] Imm28 = i_Imm26 << 2;

wire [31:0] branch, jump, jumpreg, epc_mux, eret_mux;
wire branch_ctrl;
wire [31:0] PC_4;

assign branch_ctrl = i_Beq & i_Zero | i_Bne & !i_Zero;
assign PC_4 = {i_PC[31:2] + 1'b1, 2'b0};


// Multiplexors for NEXT PC //
assign branch   = branch_ctrl ? ({{16{Imm16[15]}}, Imm16} << 2) + PC_4 : PC_4;
assign jump     = i_J         ? {PC_4[31:28], Imm28}  : branch;
assign jumpreg  = i_Jr        ? i_Rs                  : jump;
assign epc_mux  = i_exeption  ? 32'd12                : jumpreg;
assign eret_mux = i_eret      ? i_epc_to_pc           : epc_mux; 
assign o_NextPC = eret_mux;
//////////////////////////////
  
endmodule
