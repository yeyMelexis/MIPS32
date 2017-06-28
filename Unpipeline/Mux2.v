module Mux2(in0,
            in1,
            i_sel,
            out);
            
parameter WIDTH = 5;

input   [WIDTH-1:0] in0, in1;
input               i_sel;
output  [WIDTH-1:0] out;

assign out = i_sel ? in1 : in0;
  
endmodule
