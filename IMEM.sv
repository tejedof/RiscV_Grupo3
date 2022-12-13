module IMEM

#(parameter DATA_WIDTH=32, parameter ADDR_WIDTH=1024)
(
input [($clog2(ADDR_WIDTH)-1):0] addr,
output logic [(DATA_WIDTH-1):0] q
);

logic [DATA_WIDTH-1:0] rom [ADDR_WIDTH-1:0];

initial
begin
	$readmemh("bubblesort_hex.hex", rom);
end

assign q = rom[addr];

endmodule
