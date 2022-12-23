module GPIO(clk, rst,mem1_dout, mem1_din, mem1_ena, din, dout);

input [15:0] mem1_dout, din;
input mem1_ena, clk, rst;
output logic [15:0] mem1_din, dout;

always @(posedge clk or negedge rst) 

begin
if (!rst)
		mem1_din <= 0
		dout <= 0
else
	if ( mem1_ena == 1'b1)
		mem1_din <= din
		dout <= mem1_dout
//	else 
//		mem1_din = mem1_din
//		dout = dout
end

endmodule
