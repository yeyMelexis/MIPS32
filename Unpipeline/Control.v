module Control(i_instr,
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

input   [31:0] i_instr;
output  o_RegDst, o_RegWrite, o_ExtOp, o_Shift,
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
wire rotr_bit   = i_instr[21];
wire rotrv_bit  = i_instr[6];
wire mtc0_bit   = i_instr[23];
wire mfc0_bit   = ~ i_instr[23];
wire eret_bit   = i_instr[25];

 

wire [4:0] Rs, Sa;
wire [5:0] OpCode, Func;  

assign OpCode = i_instr[31:26];
assign Func   = i_instr[5:0];

reg  [13:0] MainCtrl;
assign {o_RegDst, o_RegWrite, o_ExtOp, o_Shift, o_ALUSrc, o_MemWrite, o_MemtoReg, o_Beq, o_Bne, o_J, o_Jr, o_mtc0, o_mfc0, o_eret} = MainCtrl;


always @* begin
  MainCtrl = 0;
  o_beq_bit = 1'b0;
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
              o_beq_bit = 1'b1;
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
  o_ALUCtrl = 0;
  o_lw = 1'b0;
  o_sw = 1'b0;
  case(OpCode)
    ADDI  : o_ALUCtrl = OpCode;
    LUI   : o_ALUCtrl = OpCode;
    ADDIU : o_ALUCtrl = OpCode;
    ANDI  : o_ALUCtrl = OpCode;
    ORI   : o_ALUCtrl = OpCode;
    XORI  : o_ALUCtrl = OpCode;
    LW    : begin
              o_ALUCtrl = OpCode;
              o_lw = 1'b1;
            end
    SW    : begin
              o_ALUCtrl = OpCode;
              o_sw = 1'b1;
            end
    BEQ   : o_ALUCtrl = OpCode;
    BNE   : o_ALUCtrl = OpCode;
    6'b0  : case(Func)
              JR    : o_ALUCtrl = Func;
              SLL   : o_ALUCtrl = Func;
              SRL   : begin
                        if(rotr_bit) o_ALUCtrl = ROTR;
                        else o_ALUCtrl = Func;   
                      end
              SLLV  : o_ALUCtrl = Func;
              SRLV  : begin
                        if(rotrv_bit) o_ALUCtrl = ROTRV;
                        else o_ALUCtrl = Func;   
                      end
              SRA   : o_ALUCtrl = Func;
              SRAV  : o_ALUCtrl = Func;
              ADD,
              ADDU,
              SUB,
              SUBU,
              XOR,
              AND,
              OR,
              NOR,
              SLT,
              SLTU  : o_ALUCtrl = Func;
              //default : ALUCtrl = 0;
            endcase
  endcase
end
  
  
endmodule
