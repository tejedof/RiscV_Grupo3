module MemoryController(daddr, ddata_w, ddata_r, mem0_dw, mem0_dr, mem0_ena, mem1_ena, mem0_rw, d_rw, mem1_dout, mem1_din);

input [31:0] ddata_w, ddata_r;
input [9:0] daddr;
input d_rw;
input [15:0] mem1_din;
output logic [31:0] mem0_dw, mem0_dr;
output logic mem0_ena, mem1_ena, mem0_rw;
output logic [15:0] mem1_dout;

always_comb 
begin
	mem0_ena = 1'b0;
	mem0_dw = 0;
	mem0_dr = 0;
	mem0_rw = 0;
	mem1_ena = 1'b0;
	mem1_dout = 0;
	if (daddr[9] == 1'b0)
		begin 
			mem0_ena = 1'b1;
			mem0_dw = ddata_w;
			mem0_dr = ddata_r;
			mem0_rw = d_rw;
			mem1_ena = 1'b0;
			mem1_dout = 0;
		end
	else 
		begin
			mem1_ena = 1'b1;
			mem1_dout = ddata_w[15:0];
			mem0_dw = 0;
			mem0_dr = 0;
			mem0_rw = 0;
			mem0_ena = 1'b0;
		end
end	
endmodule
