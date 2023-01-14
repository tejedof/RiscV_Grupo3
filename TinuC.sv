module TinuC 

(
input CLK, RESET_N,				// Reloj y reset asíncrono
input [31:0] idata, ddata_r,	// Buses de datos de lectura de memorias de instrucciones y datos
output [31:0] ddata_w,			// Bus de datos de escritura memoria de datos
output [9:0] iaddr, daddr,		// Buses de direcciones de memorias de instrucciones y datos
output d_rw						// Enable escritura de memoria de datos
);


// Señales internas
logic [31:0] ALU_result, read_data1, read_data2, PC, next_PC, A, B, ImmGen, Add, Sum, write_data;
logic [4:0] ALU_control;
logic [3:0] ALUOp;
logic [1:0] AuipcLui;
logic Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, PCSrc, zero;


// PC
assign Add = PC + 4;
assign Sum = PC + ImmGen;
assign PCSrc = Branch && zero;
assign next_PC = PCSrc? Sum : Add;

always_ff @(posedge CLK, negedge RESET_N)
	if (!RESET_N)
		PC <= 0;
	else 
		PC <= next_PC;


// Generador de inmediato
always_comb
	casex(idata[6:0]) // Opcode
		7'b00X0011: ImmGen = {{21{idata[31]}},idata[30:25],idata[24:21], idata[20]};		// I-type
		7'b0100011:	ImmGen = {{21{idata[31]}},idata[30:25],idata[11:8],idata[7]};			// S-type
		7'b1100011:	ImmGen = {{20{idata[31]}},idata[7],idata[30:25], idata[11:8],1'b0};		// B-type
		7'b0X10111: ImmGen = {idata[31:12],12'b0};											// U-type
		7'b110X111: ImmGen = {{12{idata[31]}},idata[19:12],idata[20],idata[30:21],1'b0};	// J-type
		default: ImmGen = 32'b0;
	endcase


// Registros
Registers Registers 
(
	.write_data(write_data),	// Dato que se escribe en la dirección de escritura
	.wren(RegWrite),			// Enable de escritura
	.clock(CLK),				// Reloj
	.reset_n(RESET_N),			// Reset activo a nivel bajo asíncrono
	.read_reg1(idata[19:15]),	// Dirección de lectura del primer registro
	.read_reg2(idata[24:20]),	// Dirección de lectura del segundo registro
	.write_reg(idata[11:7]),	// Dirección de escritura
	.read_data1(read_data1),	// Dato en la dirección de lectura del primer registro
	.read_data2(read_data2)		// Dato en la dirección de lectura del segundo registro
);


// Control
always_comb
	case(ID_idata[6:0]) // Opcode
		7'b0110011:	begin   // R-type (registro)
			Branch = 1'b0;		// Salto
			MemRead = 1'b0;		// Enable lectura RAM (no se utiliza por el momento)
			MemtoReg = 1'b0;	// Decide qué se escribe en registros
			ALUOp = 4'b0110;	// Operación ALU
			MemWrite = 1'b0;	// Enable escritura RAM
			ALUSrc = 1'b0;		// Selector MUX B ALU
			RegWrite = 1'b1;	// Enable escritura registros
			AuipcLui = 2'b10;	// Selector
		end
		7'b0010011:	begin   // I-type (inmediatos)
			Branch = 1'b0;
			MemRead = 1'b0;
			MemtoReg = 1'b0;
			ALUOp = 4'b0010;
			MemWrite = 1'b0;
			ALUSrc = 1'b1;
			RegWrite = 1'b1;
			AuipcLui = 2'b10;
		end
		7'b0000011:	begin   // L-type (carga)
			Branch = 1'b0;
			MemRead = 1'b1;
			MemtoReg = 1'b1;
			ALUOp = 4'b0000;
			MemWrite = 1'b0;
			ALUSrc = 1'b1;
			RegWrite = 1'b1;
			AuipcLui = 2'b10;
		end
		7'b0100011:	begin   // S-type (almacenamiento)
			Branch = 1'b0;
			MemRead = 1'b0;
			MemtoReg = 1'b0;
			ALUOp = 4'b0100;
			MemWrite = 1'b1;
			ALUSrc = 1'b1;
			RegWrite = 1'b0;
			AuipcLui = 2'b10;
		end
		7'b1100011: begin   // B-type (salto condicional)
			Branch = 1'b1;
			MemRead = 1'b0;
			MemtoReg = 1'b0;
			ALUOp = 4'b1100;
			MemWrite = 1'b0;
			ALUSrc = 1'b0;
			RegWrite = 1'b0;
			AuipcLui = 2'b10;
		end
		7'b0110111: begin   // LUI
			Branch = 1'b0;
			MemRead = 1'b1;
			MemtoReg = 1'b0;
			ALUOp = 4'b0111;
			MemWrite = 1'b0;
			ALUSrc = 1'b1;
			RegWrite = 1'b1;
			AuipcLui = 2'b01;
		end
		7'b0010111: begin   // AUIPC
			Branch = 1'b0;
			MemRead = 1'b1;
			MemtoReg = 1'b0;
			ALUOp = 4'b0011;
			MemWrite = 1'b0;
			ALUSrc = 1'b0;
			RegWrite = 1'b1;
			AuipcLui = 2'b00;
		end
		default: begin
			Branch = 1'b0;
			MemRead = 1'b0;
			MemtoReg = 1'b0;
			ALUOp = 4'b0000;
			MemWrite = 1'b0;
			ALUSrc = 1'b0;
			RegWrite = 1'b0;
			AuipcLui = 2'b00;
		end
	endcase


// ALU control
always_comb 
	casex({idata[30],idata[14:12],ALUOp})
		8'bX0000010: 	ALU_control = 5'b00000;	// ADDI
		8'bX0100010: 	ALU_control = 5'b01000;	// SLTI
		8'bX0110010: 	ALU_control = 5'b01100;	// SLTIU
		8'bX1110010: 	ALU_control = 5'b11100; // ANDI
		8'bX1100010: 	ALU_control = 5'b11000; // ORI
		8'bX1000010: 	ALU_control = 5'b10000; // XORI
		8'bXXXX0111: 	ALU_control = 5'b11111; // LUI
		8'bXXXX0011: 	ALU_control = 5'b00000; // AUIPC
		8'b00000110: 	ALU_control = 5'b00000; // ADD
		8'b00100110: 	ALU_control = 5'b01000; // SLT
		8'b00110110: 	ALU_control = 5'b01100; // SLTU
		8'b01110110: 	ALU_control = 5'b11100; // AND
		8'b01100110: 	ALU_control = 5'b11000; // OR
		8'b01000110: 	ALU_control = 5'b10000; // XOR
		8'b10000110: 	ALU_control = 5'b00010; // SUB
		8'bX0001100: 	ALU_control = 5'b00010; // BEQ
		8'bX0011100: 	ALU_control = 5'b10000;	// BNE
		8'bX0100000: 	ALU_control = 5'b00000;	// LW
		8'bX0100100: 	ALU_control = 5'b00000;	// SW
		default: 	 	ALU_control = 5'b00000;
	endcase


// Mux_A
always_comb
	case(AuipcLui)
		2'b00:	A = PC;
		2'b01:	A = 0;
		default:	A = read_data1;
	endcase


// Mux_B
assign B = ALUSrc? ImmGen : read_data2;


// ALU
ALU ALU
(
	.A(A),
	.B(B),
	.ALU_control(ALU_control),
	.zero(zero),
	.ALU_result(ALU_result)
);


// Mux_write_data
assign write_data = MemtoReg? ddata_r : ALU_result;


// Asignación de las salidas
assign iaddr = PC[11:2];
assign d_rw = MemWrite;
assign ddata_w = read_data2;
assign daddr = ALU_result[9:0];


endmodule
