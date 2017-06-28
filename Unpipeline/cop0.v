module cop0 (	i_clk, 
              i_rst_n,
				      i_overflow,
				      i_wrong_addr,
				      i_ext_int,
				      i_data,
				      i_addr,
				      i_pc_to_epc,
				      i_mtc0,
				      i_eret,
				      o_epc_to_pc,
				      o_exeption,
				      o_data
				      );

parameter 		STATUS = 12, CAUSE = 13, EPC = 14;

input 					i_clk, i_rst_n; 

input 					i_overflow, 
					 i_wrong_addr, 
					 i_ext_int;
input 					i_mtc0;	
input 					i_eret; 

input 		[31:0]		i_pc_to_epc;
input 		[31:0]		i_data;
input 		[4:0]		 i_addr;

output 	reg	[31:0]		o_epc_to_pc;
output 	reg				     o_exeption;
output 	reg [31:0]		o_data;

reg	 		[31:0]		epc, cause, status;
reg 					     interrupt_processing; 

wire 					epc_we;	// write enable for epc

assign 		epc_we =(i_overflow & status[8] |
					(i_wrong_addr) & status[9] |
					i_ext_int & status[10]) & status[0] & 
					!interrupt_processing;

always @(posedge i_clk or negedge i_rst_n) begin 
    if (! i_rst_n)
      epc <= 0;
    else
		if (epc_we) begin
			epc <= i_pc_to_epc;	
		end	
	end


always @(posedge i_clk or negedge i_rst_n) begin 
  if (! i_rst_n) begin
    status  <= 0;
    cause   <= 0;
  end
  else
		if(i_mtc0 & i_addr == STATUS) 
			status <= i_data;
		if(i_mtc0 & i_addr == CAUSE) 
			cause  	<= i_data;
		else begin
			if(epc_we)
				cause 	<= { 29'b0, i_overflow, i_wrong_addr, i_ext_int};
		end
	end


always @(posedge i_clk or negedge i_rst_n) begin 
  if(! i_rst_n)
    interrupt_processing <= 1'b0;
  else
		if(i_eret)
			interrupt_processing <= 1'b0;
		if(epc_we)
			interrupt_processing <= 1'b1;
	end


always @(*) begin 
	case(i_addr)
		STATUS:	o_data = status;
		CAUSE : o_data	= cause;
		EPC   : o_data	= epc;
		default:		o_data 	= 0;
	endcase // i_addr

	o_epc_to_pc = epc;
	o_exeption 	= epc_we;
end

endmodule