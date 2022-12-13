`timescale 1ns/1ps
module tb_ram();
localparam T=20;
localparam size=32;
localparam mem_depth=1024;

logic clock, wren;
logic [size-1:0] data_in;
logic [$clog2(mem_depth)-1:0] address;
logic [size-1:0] data_out;


//DUV
DMEM duv(.*);

//Generacion del RELOJ
initial begin clock = 1'b0;
forever #(T/2)  clock = !clock;
end

initial
begin
    //PRIMERO ESCRIBIMOS
    //COMPROBAMOS

    //DUDA. Cuando se actualiza la salida? Al cargar un address???
    WriteRAM(53, 1);
    comprobar(53);

    WriteRAM(4, 25);
    comprobar(4);

    WriteRAM(26,10);
    comprobar(26);
    
    $finish;
end

//TASK ESCRITURA RAM
task WriteRAM;
input [size-1:0] dataTask;
input [$clog2(mem_depth-1)-1:0] addressTask;
begin
    wren = 1'b0;
    data_in = dataTask;
    address = addressTask;

    @(negedge clock)
    wren = 1'b1;
    repeat(4) @(negedge clock)
    wren = 1'b0;
end
endtask

//TASK COMPROBACIÓN
task comprobar;
input [size-1:0] data_out_GM;
begin
    assert(data_out_GM == data_out) 
    else $error("La salida no es la esperada");
end
endtask

endmodule