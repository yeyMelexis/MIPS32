module Control(i_clk,
               i_a_rst_n,
               i_s_rst_exec,
               i_s_rst_MemAc,
               i_s_rst_WrBc,
               i_we_exec,
               i_we_MemAc,
               i_we_WrBc,
               i_instr,
               o_RegDst,
               o_RegWrite,
               o_ExtOp,
               o_Shift,
               o_ALUSrc,
               o_MemWrite,
               o_MemtoReg,
               o_Beq,
               o_Bne,
               o_J,
               o_Jr,
               o_ALUCtrl,
               o_lw,
               o_sw,
               o_beq_bit,
               o_mtc0,
               o_mfc0,
               o_eret
               );

input   i_clk, i_a_rst_n, i_s_rst_exec, i_s_rst_MemAc, i_s_rst_WrBc, i_we_exec, i_we_MemAc, i_we_WrBc;
input   [31:0] i_instr;
output reg  o_RegDst, o_RegWrite, o_ExtOp, o_Shift,
            o_ALUSrc, o_MemWrite, o_MemtoReg,
            o_Beq, o_Bne, o_J, o_Jr, o_mtc0, o_mfc0, o_eret;
        
output reg  [5:0] o_ALUCtrl;
output reg  o_lw, o_sw, o_beq_bit;
/******************************************************************/
/********************Opcodes and Functions*************************/
//Functions
localparam AND  = 6'b100100,  OR    = 6'b100101, NOR  = 6'b100111,  XOR  = 6'b100110;
localparam ADD  = 6'b100000,  SUB   = 6'b100010, ADDU = 6'b100001,  SUBU = 6'b100011;  
localparam SLT  = 6'b101010,  SLTU  = 6'b101011;
localparam SLL  = 6'b000000,  SLLV  = 6'b000100, SRL  = 6'b000010,  SRLV = 6'b000110;
localparam SRA  = 6'b000011,  SRAV  = 6'b000111;   
localparam ROTR = 6'b111110,  ROTRV = 6'b111111;
localparam JR   = 6'b001000;
//OpCodes
localparam ADDI  = 6'b001000,  ADDIU = 6'b001001, LUI  = 6'b001111;
localparam ANDI  = 6'b001100,  ORI   = 6'b001101, XORI = 6'b001110;
localparam LW    = 6'b100011,  SW    = 6'b101011;
localparam BEQ   = 6'b000100,  BNE   = 6'b000101, J    = 6'b000010;
localparam Rtype = 6'b000000,  COP0  = 6'b010000;
/******************************************************************/
wire    w_RegDst, w_RegWrite, w_ExtOp, w_Shift,
        w_ALUSrc, w_MemWrite, w_MemtoReg,
        w_Beq,    w_Bne,      w_J,     w_Jr, 
        w_mtc0,   w_mfc0,     w_eret;

reg     r_lw, r_sw, r_beq_bit;

wire rotr_bit   = i_instr[21];
wire rotrv_bit  = i_instr[6];
wire mtc0_bit   = i_instr[23];
wire mfc0_bit   = ~ i_instr[23];
wire eret_bit   = i_instr[25]; 

wire [5:0] OpCode, Func;  

assign OpCode = i_instr[31:26];
assign Func   = i_instr[5:0];

reg  [5:0] r_ALUCtrl;
reg MemWrite_exec,
    MemtoReg_exec,
    RegWrite_exec, 
    RegDst_exec,   
    mfc0_exec,     
    mtc0_exec,
    RegWrite_MemAc,
    RegDst_MemAc,
    mfc0_MemAc,
    mtc0_MemAc;

reg  [13:0] MainCtrl;
assign {w_RegDst, w_RegWrite, w_ExtOp, w_Shift, w_ALUSrc, w_MemWrite, w_MemtoReg, w_Beq, w_Bne, w_J, w_Jr, w_mtc0, w_mfc0, w_eret} = MainCtrl;

always @* {o_ExtOp, o_Shift, o_ALUSrc, o_Jr, o_J, o_Beq, o_Bne, o_eret} = {w_ExtOp, w_Shift, w_ALUSrc, w_Jr, w_J, w_Beq, w_Bne, w_eret};

always @* begin
  MainCtrl = 0;
  r_beq_bit = 1'b0;
  case(OpCode)
    ADDI,
    ADDIU : MainCtrl = 14'b0110_1000_0000_00;//addi
    LUI   : MainCtrl = 14'b0100_1000_0000_00;//lui 
    ANDI,   
    ORI,   
    XORI  : MainCtrl = 14'b0100_1000_0000_00;
    LW    : MainCtrl = 14'b0110_1010_0000_00;//lw
    SW    : MainCtrl = 14'bx010_11x0_0000_00;//sw
    BEQ   : begin
              r_beq_bit = 1'b1;
              MainCtrl = 14'bx0x0_00x1_0000_00;//beq
            end
    BNE   : MainCtrl = 14'bx0x0_00x0_1000_00;//bne
    J     : MainCtrl = 14'bx0xx_x0xx_x100_00;//j
    COP0  : begin
              if(eret_bit)
                MainCtrl = 14'bx0xx_x0x0_0000_01;//eret
              else if(mtc0_bit)
                MainCtrl = 14'b00xx_x0x0_0001_00;//mtc0
              else if(mfc0_bit)
                MainCtrl = 14'b00xx_x0x0_0000_10;//mfc0
            end
    6'b0  : case(Func)
              JR    : MainCtrl = 14'bx0xx_x0xx_xx10_00;//jr
              SLL,
              SRL,
              SRA   : MainCtrl = 14'b11x1_0000_0000_00;//logical shift instruction with using Shift Amount
              default : MainCtrl = 14'b11x0_0000_0000_00;//other R-type instructions
            endcase
  endcase
end//Main Control

always @* begin
  r_ALUCtrl = 0;
  r_lw = 1'b0;
  r_sw = 1'b0;
  case(OpCode)
    ADDI  : r_ALUCtrl = OpCode;
    LUI   : r_ALUCtrl = OpCode;
    ADDIU : r_ALUCtrl = OpCode;
    ANDI  : r_ALUCtrl = OpCode;
    ORI   : r_ALUCtrl = OpCode;
    XORI  : r_ALUCtrl = OpCode;
    LW    : begin
              r_ALUCtrl = OpCode;
              r_lw = 1'b1;
            end
    SW    : begin
              r_ALUCtrl = OpCode;
              r_sw = 1'b1;
            end
    BEQ   : r_ALUCtrl = OpCode;
    BNE   : r_ALUCtrl = OpCode;
    6'b0  : case(Func)
              JR    : r_ALUCtrl = Func;
              SLL   : r_ALUCtrl = Func;
              SRL   : begin
                        if(rotr_bit) r_ALUCtrl = ROTR;
                        else r_ALUCtrl = Func;   
                      end
              SLLV  : r_ALUCtrl = Func;
              SRLV  : begin
                        if(rotrv_bit) r_ALUCtrl = ROTRV;
                        else r_ALUCtrl = Func;   
                      end
              SRA   : r_ALUCtrl = Func;
              SRAV  : r_ALUCtrl = Func;
              ADD,
              ADDU,
              SUB,
              SUBU,
              XOR,
              AND,
              OR,
              NOR,
              SLT,
              SLTU  : r_ALUCtrl = Func;
              //default : ALUCtrl = 0;
            endcase
  endcase
end

  
//****Execute****//
always @(posedge i_clk or negedge i_a_rst_n) begin
  if(!i_a_rst_n) begin
    o_ALUCtrl     <= 0;
    o_lw          <= 0;
    o_sw          <= 0;
    MemWrite_exec <= 0;
    MemtoReg_exec <= 0;
    RegWrite_exec <= 0;
    RegDst_exec   <= 0;
    mfc0_exec     <= 0;
    mtc0_exec     <= 0;
  end
  else if(i_s_rst_exec) begin
    o_ALUCtrl     <= 0;
    o_lw          <= 0;
    o_sw          <= 0;
    MemWrite_exec <= 0;
    MemtoReg_exec <= 0;
    RegWrite_exec <= 0;
    RegDst_exec   <= 0;
    mfc0_exec     <= 0;
    mtc0_exec     <= 0;
  end
  else if (i_we_exec) begin
    o_ALUCtrl     <= r_ALUCtrl;
    o_lw          <= r_lw;
    o_sw          <= r_sw;
    o_beq_bit     <= r_beq_bit;
    MemWrite_exec <= w_MemWrite;
    MemtoReg_exec <= w_MemtoReg;
    RegWrite_exec <= w_RegWrite;
    RegDst_exec   <= w_RegDst;
    mfc0_exec     <= w_mfc0;
    mtc0_exec     <= w_mtc0;
  end
end//Execute

//****Memory Access****//
always @(posedge i_clk or negedge i_a_rst_n) begin
  if(!i_a_rst_n) begin
    o_MemWrite      <= 0;
    o_MemtoReg      <= 0;
    RegWrite_MemAc  <= 0;
    RegDst_MemAc    <= 0;
    mfc0_MemAc      <= 0;
    mtc0_MemAc      <= 0;
  end
  else if(i_s_rst_MemAc) begin
    o_MemWrite      <= 0;
    o_MemtoReg      <= 0;
    RegWrite_MemAc  <= 0;
    RegDst_MemAc    <= 0;
    mfc0_MemAc      <= 0;
    mtc0_MemAc      <= 0;
  end
  else if (i_we_MemAc) begin
    o_MemWrite      <= MemWrite_exec;
    o_MemtoReg      <= MemtoReg_exec;
    RegWrite_MemAc  <= RegWrite_exec;
    RegDst_MemAc    <= RegDst_exec;
    mfc0_MemAc      <= mfc0_exec;
    mtc0_MemAc      <= mtc0_exec;
  end
end//Memory Access


//********Write Back********//
always @(posedge i_clk or negedge i_a_rst_n) begin
  if(!i_a_rst_n) begin
    o_RegWrite  <= 0;
    o_RegDst    <= 0;
    o_mfc0      <= 0;
    o_mtc0      <= 0;
  end
  else if(i_s_rst_WrBc) begin
    o_RegWrite  <= 0;
    o_RegDst    <= 0;
    o_mfc0      <= 0;
    o_mtc0      <= 0;
  end
  else if (i_we_WrBc) begin
    o_RegWrite  <= RegWrite_MemAc;
    o_RegDst    <= RegDst_MemAc;
    o_mfc0      <= mfc0_MemAc;
    o_mtc0      <= mtc0_MemAc;
  end
end//Write Back
  
endmodule