module HazardControl(	i_instr_fetch,
                      i_instr_dec,
						          i_instr_exec,
						          i_instr_MemAc,
						          i_instr_WrBc,
						          o_s_rst_dec,
						          o_we_dec
						         );		

input [31:0]  i_instr_fetch,
              i_instr_dec,
						  i_instr_exec,
						  i_instr_MemAc,
						  i_instr_WrBc;    
						         
output o_s_rst_dec, o_we_dec;

wire  w_we_rd_dec,
      w_we_rd_exec,
      w_we_rd_MemAc,
      w_we_rd_WrBc,
      w_we_rt_dec,
      w_we_rt_exec,
      w_we_rt_MemAc,
      w_we_rt_WrBc,
      w_re_rs_fetch,
      w_re_rt_fetch;

wire  [4:0]  w_Rd_dec   = i_instr_dec[15:11];
wire  [4:0]  w_Rd_exec  = i_instr_exec[15:11];
wire  [4:0]  w_Rd_MemAc = i_instr_MemAc[15:11];
wire  [4:0]  w_Rd_WrBc  = i_instr_WrBc[15:11];

wire  [4:0]  w_Rt_dec   = i_instr_dec[20:16];
wire  [4:0]  w_Rt_exec  = i_instr_exec[20:16];
wire  [4:0]  w_Rt_MemAc = i_instr_MemAc[20:16];
wire  [4:0]  w_Rt_WrBc  = i_instr_WrBc[20:16];

wire  [4:0]  w_Rs_fetch = i_instr_fetch[25:21];
wire  [4:0]  w_Rt_fetch = i_instr_fetch[20:16];

reg r_stall;

always @* begin
  r_stall =( ((w_Rd_dec   == w_Rs_fetch) & w_we_rd_dec    | (w_Rt_dec   == w_Rs_fetch) & w_we_rt_dec    |
              (w_Rd_exec  == w_Rs_fetch) & w_we_rd_exec   | (w_Rt_exec  == w_Rs_fetch) & w_we_rt_exec   |
              (w_Rd_MemAc == w_Rs_fetch) & w_we_rd_MemAc  | (w_Rt_MemAc == w_Rs_fetch) & w_we_rt_MemAc  |
              (w_Rd_WrBc  == w_Rs_fetch) & w_we_rd_WrBc   | (w_Rt_WrBc  == w_Rs_fetch) & w_we_rt_WrBc)  & w_re_rs_fetch |
              ((w_Rd_dec  == w_Rt_fetch) & w_we_rd_dec    | (w_Rt_dec   == w_Rt_fetch) & w_we_rt_dec    |
              (w_Rd_exec  == w_Rt_fetch) & w_we_rd_exec   | (w_Rt_exec  == w_Rt_fetch) & w_we_rt_exec   |
              (w_Rd_MemAc == w_Rt_fetch) & w_we_rd_MemAc  | (w_Rt_MemAc == w_Rt_fetch) & w_we_rt_MemAc  |
              (w_Rd_WrBc  == w_Rt_fetch) & w_we_rd_WrBc   | (w_Rt_WrBc  == w_Rt_fetch) & w_we_rt_WrBc)  & w_re_rt_fetch  
            );
end

assign o_we_dec = r_stall;
assign o_s_rst_dec = r_stall;

Destination Destination_dec( .i_instr     (i_instr_dec),
                             //.o_CompReg   (w_CompReg_dec),
                             .o_we_rd     (w_we_rd_dec),
                             .o_we_rt     (w_we_rt_dec)
                            ); 

Destination Destination_exec(.i_instr     (i_instr_exec),
                            // .o_CompReg   (w_CompReg_exec),
                             .o_we_rd     (w_we_rd_exec),
                             .o_we_rt     (w_we_rt_exec)
                            );

Destination Destination_MemAc(.i_instr     (i_instr_MemAc),
                              //.o_CompReg   (w_CompReg_MemAc),
                              .o_we_rd     (w_we_rd_MemAc),
                              .o_we_rt     (w_we_rt_MemAc)
                              );

Destination Destination_WrBc( .i_instr     (i_instr_WrBc),
                             // .o_CompReg   (w_CompReg_WrBc),
                              .o_we_rd     (w_we_rd_WrBc),
                              .o_we_rt     (w_we_rt_WrBc)
                             );

Destination_fetch destination_fetch( .i_instr  (i_instr_fetch),
                                     .o_re_rs  (w_re_rs_fetch),
                                     .o_re_rt  (w_re_rt_fetch)
                                    );
                         
endmodule


