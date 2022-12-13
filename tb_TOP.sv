module tb_TOP ();

localparam T = 20;

logic CLK, RESET_N;			// Reloj y reset asíncron						// Enable escritura RAM

TOP duv(.*);

initial begin CLK = 1'b0;
forever #(T/2)  CLK = !CLK;
end

initial
begin
    #(T)
    reset();
    #(T*100)

$finish;
end
//TASK

//RESET
//Los cambios son realizados en el flanco de bajada del CLK para aportar
//mas estabilidad al hardware
task reset;
begin
	@(negedge CLK)
	RESET_N = 0;
	repeat(10) @(negedge CLK);
	RESET_N = 1;
	
end
endtask 
endmodule