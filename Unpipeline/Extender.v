module Extender(i_data16,
                i_ExtOp,
                o_data32);
  
input   [15:0]  i_data16;
input           i_ExtOp;
output  [31:0]  o_data32;

assign  o_data32 = {{16{i_ExtOp}} & {16{i_data16[15]}}, i_data16};
  
endmodule
