`timescale 1 ns/100 ps

module tb_registers();
localparam T=20;
localparam tamanyo=32;
parameter mem_depth=32;
parameter size=32;
//Inputs
logic [size-1:0] write_data;
logic  wren,clock,reset_n;
logic [($clog2(mem_depth)-1):0] read_reg1,read_reg2,write_reg;
//Outputs
logic [size-1:0] read_data1,read_data2;
//Device Under Verification
Registers DUV(.write_data(write_data),
.wren(wren),
.clock(clock),
.read_reg1(read_reg1),
.read_reg2(read_reg2),
.write_reg(write_reg),
.read_data1(read_data1),
.read_data2(read_data2),
.reset_n(reset_n));

initial begin clock = 1'b0;
forever #(T/2)  clock = !clock;
end

initial 
begin
reset_n=1'b0;
#(10*T)
reset_n=1'b1;
wren=1'b1;
#(2*T)
escribe(8,1);
#(5*T)
escribe(5,0);
#(5*T)
wren=1'b0;
lee(1,0);
#(15*T)
assert(read_data1==8)else $error("El banco de registros no funciona cuando se lee, el resultado deberia ser 8");
assert(read_data2==0)else $error("El banco de registros no funciona cuando se lee, el resultado deberia ser 0");
reset_n=1'b0;
#(10*T)
$stop;
end 
task escribe(reg [size-1:0] valor, reg [($clog2(mem_depth)-1):0] wdir);
begin
wren=1'b1;
write_data=valor;
write_reg=wdir;
end
endtask
task lee (reg [($clog2(mem_depth)-1):0] rdir1,rdir2);
begin 
read_reg1=rdir1;
read_reg2=rdir2;
end
endtask
endmodule 