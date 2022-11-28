`timescale 1ps/1ns
module tb_ROM ();
localparam DATA_WIDTH=32; 
localparam ADDR_WIDTH=1024;
localparam T = 20;

logic [(ADDR_WIDTH-1):0] addr;
logic [(DATA_WIDTH-1):0] q;

ROM duv(.*);


initial begin CLK = 1'b0;
forever #(T/2)  CLK = !CLK;
end


initial
begin
    #(2*T)
    AddressIn();
    comprobar();

    $finish;
end


task AddressIn;
input [(ADDR_WIDTH-1):0] address_user;
	begin 
		addr = address_user;
	end
endtask

task comprobar;
input [4:0] q_GM;
	begin
		assert(q == q_GM) 
        else $error("La salida no es la que debería.");	
	end
endtask
endmodule