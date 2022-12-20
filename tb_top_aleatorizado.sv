//CLASS
//Instrucciones R-Format
class tipoR;
randc logic [31:0] instruccionR;

//CASO 1 DEJAR FIJO TODO MENOS RD 
constraint caso1 {instruccionR[31:25] == 7'b0100000 && instruccionR[24:20] == 5'b00010 && instruccionR[19:15] == 5'd1 && instruccionR[14:12] == 3'd0 && instruccionR[6:0] == 7'b0110011;}

//CASO 2 DEJAR FIJO TODO MENOS FUNCT3 Y FUNCT 7
constraint caso2 {instruccionR[31] == 1'd0 && instruccionR[29:25] == 5'd0 && instruccionR[24:20] == 5'd2 && instruccionR[19:15] == 5'd1 && instruccionR[11:7] == 5'd4  && instruccionR[6:0] == 7'b0110011;}
endclass

//Instrucciones I-Format
class tipoI;
randc logic [31:0] instruccionI;

//CASO 1 DEJAR FIJO TODO MENOS INMEDIATO 
constraint caso1 {instruccionI[19:15] == 5'd3 && instruccionI[14:12] == 3'd0 && instruccionI[11:7] == 5'd4 && instruccionI[6:0] == 7'b0010011;}
endclass

`timescale 1ns/100ps

module tb_top_aleatorizado;
//DECLARACION DE PARAMETROS
localparam T=20;

//DECLARACION DE INPUT
logic CLK, RESET_N;
logic [31:0] instruccion;
logic [31:0] ddata_r;
logic [31:0] ddata_w;
logic [9:0] daddr;
logic d_rw; 

//COBERTURA
//R-Format
covergroup InstTypeR;
    cp1: coverpoint instruccion[11:7];
	cp2: coverpoint {instruccion[30], instruccion[14:12]};
endgroup

//I-Format
covergroup InstTypeI;
    cp3: coverpoint instruccion[31:20];
endgroup

//DECLARACION OBJETO Y COVERGROUP
//R-Format
tipoR tipor_rcsg;
InstTypeR instyper_cg;

//I-Format
tipoI tipoi_rcsg;
InstTypeI instypei_cg;



////INSTANCIACION DUV///////////////////
//
//
//
TinuC TinuC

(
		.CLK(CLK), 
		.RESET_N(RESET_N),				
		.idata(instruccion), 
		.ddata_r(ddata_r),	
		.ddata_w(ddata_w),			
		.iaddr(), 
		.daddr(daddr),		
		.d_rw(d_rw)						
);

DMEM  RAM
(
		.data_in(ddata_w),
		.wren(d_rw),
		.clock(CLK), 
		.address(daddr),
		.data_out(ddata_r)
);	
//
//
//
////FIN DE LA INSTANCIACIÓN DEL DUV////


//GENERACIOND EL RELOJ
initial 
begin 
CLK = 1'b0;
forever #(T/2)  CLK = !CLK;
end

//Inicio de las aleatorizaciones y verificaciones
initial
begin

//Construimos las clases
//Clases R-Format
tipor_rcsg = new;
instyper_cg  = new;

//Clases I-Format
tipoi_rcsg = new;
instypei_cg  = new;

$display("Iniciamos la aleatorización de instrucciones tipo R");
//WHILE CASO 1
while(instyper_cg.cp1.get_coverage()<100)
begin
	$display("Dejamos toda la instrucción dija menos el campo RD");
    tipor_rcsg.caso1.constraint_mode(1);
    tipor_rcsg.caso2.constraint_mode(0);

	//ALEATORIZACIÓN
	assert(tipor_rcsg.randomize()) else $fatal("Ha fallado la aleatorización");
	instruccion = tipor_rcsg.instruccionR;

	instyper_cg.sample();
end

//WHILE CASO 2
while(instyper_cg.cp2.get_coverage()<100)
begin
	$display("Dejamos toda la instrucción fija menos los campos FUNCT3 Y FUNCT 7");
    tipor_rcsg.caso1.constraint_mode(0);
    tipor_rcsg.caso2.constraint_mode(1);

	//ALEATORIZACIÓN
	assert(tipor_rcsg.randomize()) else $fatal("Ha fallado la aleatorización");
	instruccion = tipor_rcsg.instruccionR;

	instyper_cg.sample();
end

// WHILE INSTRUCCIONES TIPO I
while (instypei_cg.cp3.get_coverage()<100)
begin
	$display("Dejamos toda la instrucción fija menos el inmediato");
	tipoi_rcsg.caso1.constraint_mode(1);
	
	// ALEATORIZACIÓN
	assert (tipoi_rcsg.randomize()) else $fatal("Ha fallado la aleatorización")
	instruccion = tipoi_rcsg.instruccionI;

	instypei_cg.sample();
end


$finish;
end



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