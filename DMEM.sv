module DMEM

#(parameter mem_depth=1024, parameter size=32)
(
input [size-1:0] data_in,
input wren,clock, 
input [($clog2(mem_depth)-1):0] address,
output logic [size-1:0] data_out
);

logic [size-1:0] ram [mem_depth-1:0];

initial
begin
	$readmemb("ram.txt", ram);
end

always_ff @(posedge clock)
	if (wren)
        ram[address] <= data_in;
		  
assign data_out = ram[address];       
	  
endmodule
