module ALU(i_op1,
           i_op2,
           i_control,
           i_sw,
           i_lw,
           i_beq_bit,
           o_result,
           o_overflow,
           o_zero
           );
  
input   [31:0]  i_op1, i_op2;
input   [5:0]   i_control;
input           i_lw, i_sw, i_beq_bit;
output          o_zero;
output  reg [31:0]  o_result;
output  reg         o_overflow;

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

reg carry;

assign o_zero = (o_result == 0);

always @* begin
  o_result = 0;
  carry = 0;
  o_overflow = 0;
  case(i_control)
    AND,
    ANDI : o_result = i_op1 & i_op2;
    OR,
    ORI  : o_result =   i_op1 | i_op2;
    NOR  : o_result = ~(i_op1 | i_op2);
    XOR,
    XORI : o_result = i_op1 ^ i_op2;
    ADD,
    ADDI :begin
          {carry, o_result} = {i_op1[31],i_op1} + {i_op2[31],i_op2};
          o_overflow = carry ^ o_result[31];
         end
    SUB :begin
          {carry, o_result} = {i_op1[31],i_op1} - {i_op2[31],i_op2};
          o_overflow = carry ^ o_result[31];
         end
    ADDU,
    ADDIU: o_result = i_op1 + i_op2;
    SUBU: begin
            if(i_lw)
            o_result = i_op1 + i_op2;
            else
            o_result = i_op1 - i_op2;
          end
    SLT : o_result = ($signed(i_op1) < $signed(i_op2)) ? 1'b1 : 1'b0;
    SLTU: begin
            if(i_sw)
            o_result = i_op1 + i_op2;  
            else
            o_result = i_op1 < i_op2 ? 1 : 0;  
          end
    
    SLL : o_result = i_op2 << i_op1;
    SLLV,
    BEQ : begin
            if(i_beq_bit)
              o_result = i_op1 - i_op2;
            else
              o_result = i_op2 << i_op1;
          end
    SRL,  
    SRLV: o_result = i_op2 >> i_op1;
    SRA,  
    SRAV: o_result = $signed(i_op2) >>> i_op1;
    ROTR,  
    ROTRV:o_result = i_op2 << (32 - i_op1[4:0]) | i_op2 >> i_op2[4:0];
    
    LUI : o_result = {i_op2[15:0], 16'b0};
    BNE : o_result = i_op1 - i_op2;
    
  endcase
end 
endmodule
