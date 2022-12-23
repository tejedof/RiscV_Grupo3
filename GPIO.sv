module GPIO(clk, rst,mem1_dout, mem1_din, mem1_ena, din, dout);

input [15:0] mem1_dout, din;
input mem1_ena, clk, rst;
output logic [15:0] mem1_din, dout;

always_ff @(posedge clk or negedge rst) 
	if (!rst)
		begin
		mem1_din <= 0;
		dout <= 0;
		end
	else if ( mem1_ena == 1'b1)
		begin
		mem1_din <= din;
		dout <= mem1_dout;
		end


endmodule
