module Destination_fetch( i_instr,
                          o_re_rs,
                          o_re_rt
                         );
  
input       [31:0]  i_instr;
output  reg         o_re_rs, o_re_rt;

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
localparam ADDI = 6'b001000,  ADDIU = 6'b001001, LUI  = 6'b001111;
localparam ANDI = 6'b001100,  ORI   = 6'b001101, XORI = 6'b001110;
localparam LW   = 6'b100011,  SW    = 6'b101011;
localparam BEQ  = 6'b000100,  BNE   = 6'b000101, J    = 6'b000010;
/******************************************************************/

wire  [5:0] Opcode = i_instr[31:26];
wire  [5:0] Func   = i_instr[5:0];

always @* begin
  o_re_rs   = 0;
  o_re_rt   = 0;
  case(Opcode)
	  ANDI, ORI, XORI,
	  LUI, ADDI, ADDIU:
	                 begin
	                   o_re_rs = 1'b1;
	                   o_re_rt = 1'b0;
	                 end
	  BEQ, BNE, 
	  LW,  SW:		     begin
	                   o_re_rs = 1'b1;
	                   o_re_rt = 1'b1;
	                 end
	   0:case(Func)
	     AND,  OR,   NOR,
	     XOR,  ADD,  SUB, 
	     ADDU, SUBU, SLT, 
	     SLTU, SLLV, SRLV, 
	     SRAV,   SRL, SRA: 
	           begin
	             o_re_rs = 1'b1;
	             o_re_rt = 1'b1;     
	           end        
	   endcase
  endcase
end 
endmodule
