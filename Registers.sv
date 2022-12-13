module Registers

#(parameter mem_depth=32, parameter size=32)
(
input [size-1:0] write_data,
input wren,clock, reset_n,
input [($clog2(mem_depth)-1):0] read_reg1,read_reg2,write_reg,
output logic [size-1:0] read_data1,read_data2
);

logic [size-1:0] mem [mem_depth-1 :0];
		
always_ff @(posedge clock, negedge reset_n)
	if (!reset_n)
		mem <= '{mem_depth{0}};
	else if (wren)
		if(write_reg != 0)
			mem[write_reg] <= write_data;
		else
			mem[write_reg] <= 0;

assign read_data1 = mem[read_reg1];
assign read_data2 = mem[read_reg2];

endmodule
