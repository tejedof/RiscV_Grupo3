module TOP (

input CLK, RESET_N

	);

logic [31:0] idata;
logic [31:0] ddata_r;
logic [31:0] ddata_w;
logic [9:0] iaddr;
logic [9:0] daddr;
logic d_rw; 


TinuC TinuC

(
		.CLK(CLK), 
		.RESET_N(RESET_N),				
		.idata(idata), 
		.ddata_r(ddata_r),	
		.ddata_w(ddata_w),			
		.iaddr(iaddr), 
		.daddr(daddr),		
		.d_rw(d_rw)						
);


IMEM  ROM 
(
		.addr(iaddr),
		.q(idata)
);

DMEM  RAM
(
		.data_in(ddata_w),
		.wren(d_rw),
		.clock(CLK), 
		.address(daddr),
		.data_out(ddata_r)
);	
endmodule
