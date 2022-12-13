`timescale 1ns/1ps
module tb_ROM ();
localparam size=32; 
localparam mem_depth=1024;
localparam T = 20;

logic CLK;

logic [($clog2(mem_depth)-1):0] addr;
logic [(size-1):0] q;

logic [($clog2(mem_depth)-1):0] addr_GM;
logic [(size-1):0] q_GM;

IMEM duv(.*);


initial begin CLK = 1'b0;
forever #(T/2)  CLK = !CLK;
end


initial
begin
    @(posedge CLK)
    AddressIn(4);

    @(posedge CLK)
    comprobar();

  	@(posedge CLK)
    AddressIn(10);

    @(posedge CLK)
    comprobar();
    $finish;
end

//INICIO DE LAS TASK
task AddressIn;
input [(mem_depth-1):0] address_user;
	begin 
		addr = address_user;
		addr_GM = address_user;
	end
endtask

task comprobar;
	begin
		assert(q == q_GM) 
        else $error("La salida no es la que debería.");	
	end
endtask
//FIN DE LAS TASK

//GOLDEN MODEL 
logic [1023:0] rom[31:0];

initial
begin
	$readmemh("fibonacci.hex", rom);
end

assign q_GM = rom[addr_GM];
//FIN DEL GOLDEN MODEL


endmodule