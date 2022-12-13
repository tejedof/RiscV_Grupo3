module ROM 
#(parameter DATA_WIDTH=32, parameter ADDR_WIDTH=1024)
(
input [(ADDR_WIDTH-1):0] addr,
output logic [(DATA_WIDTH-1):0] q
);

// Declare the ROM variable
logic [ADDR_WIDTH-1:0] rom[DATA_WIDTH-1:0];

initial
begin
	$readmemh("fibonacci.hex", rom);
end
 

assign q = rom[addr];

endmodule
