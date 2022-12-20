module TinuC_seg 

(
input CLK, RESET_N,				// Reloj y reset asíncrono
input [31:0] idata, ddata_r,	// Bus de datos de lectura ROM y RAM
output [31:0] ddata_w,			// Bus de datos de escritura RAM
output [9:0] iaddr, daddr,		// Bus de direcciones ROM y RAM
output d_rw							// Enable escritura RAM
);


// Señales internas
logic [31:0] ALU_result, read_data1, read_data2, PC, next_PC, A, B, ImmGen, Add, Sum, write_data;
logic [4:0] ALU_control;
logic [3:0] ALUOp;
logic [1:0] AuipcLui;
logic Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, PCSrc, zero;


// PC
assign Add = PC + 4;
assign Sum = PC_reg2 + ImmGen_reg; 
assign PCSrc = Branch_reg2 && zero_reg;
assign next_PC = PCSrc? Sum_reg : Add;

always_ff @(posedge CLK, negedge RESET_N)
	if (!RESET_N)
		PC <= 0;
	else 
		PC <= next_PC;


// Generador de inmediato
always_comb
	casex(instruction_reg[6:0]) // Opcode
		7'b0010011: ImmGen = {{21{instruction_reg[31]}},instruction_reg[30:25],instruction_reg[24:21], instruction_reg[20]};		// I-type
		7'b0100011:	ImmGen = {{21{instruction_reg[31]}},instruction_reg[30:25],instruction_reg[11:8],instruction_reg[7]};			// S-type
		7'b1100011:	ImmGen = {{20{instruction_reg[31]}},instruction_reg[7],instruction_reg[30:25], instruction_reg[11:8],1'b0};	// B-type
		7'b0X10111: ImmGen = {instruction_reg[31:12],12'b0};													// U-type
		7'b110X111: ImmGen = {{12{instruction_reg[31]}},instruction_reg[19:12],instruction_reg[20],instruction_reg[30:21],1'b0};	// J-type
		default: ImmGen = 32'b0;
	endcase


// Registros
Registers Registers 
(
	.write_data(write_data),
	.wren(RegWrite_reg3),
	.clock(CLK),
	.reset_n(RESET_N),
	.read_reg1(instruction_reg[19:15]),
	.read_reg2(instruction_reg[24:20]),
	.write_reg(instruction_reg[11:7]), // Tenemos que retrasar también esta señal (ver transparencia 30 de implementación pipelined)
	.read_data1(read_data1),
	.read_data2(read_data2)
);


// Control
always_comb
	case(instruction_reg[6:0]) // Opcode
		7'b0110011:	begin   // R-type (registro)
						Branch = 1'b0;		// Salto
						MemRead = 1'b0;	// Enable lectura RAM (no se utiliza por el momento)
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
		default:		begin
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
	casex({i30_reg[30],funct3_reg[14:12],AluOP_reg})                  
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
	case(AuipcLui_reg)
		2'b00:	A = PC_reg2;
		2'b01:	A = 0;
		default:	A = read_data1_reg;
	endcase


// Mux_B
assign B = AluSrc_reg? ImmGen_reg : read_data2_reg;


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
assign write_data = MemtoReg_reg3? ddata_r_reg : ALU_result_reg2;
// Añadir opción  para  PC+4 cuando tengamos JAL/JALR


// Asignación de las salidas
assign iaddr = PC[11:2];
assign d_rw = MemWrite_reg2;
assign ddata_w = read_data2_reg2;
assign daddr = ALU_result_reg;


// SEGMENTACIÓN
//Banco 1 IF/ID
logic [31:0] pc_reg, instruction_reg // Salida del PC y de las Instrucciones.

always_ff @(posedge CLK, negedge RESET_N)
	if (!RESET_N)
		begin
		pc_reg <= '0;
		instruction_reg <= '0;
		end
	else
		begin
			pc_reg <= PC; 
			instruction_reg <= idata;
		end


//Banco 2 ID/EX
logic [31:0] read_data1_reg, read_data2_reg, ImmGen_reg;
logic [9:0] pc_reg2;
logic [4:0] rd_reg;
logic [3:0] AluOP_reg;
logic [2:0] funct3_reg, AuipcLui_reg;
logic i30_reg, AluSrc_reg, Branch_reg, MemWrite_reg, MemRead_reg, MemtoReg_reg, RegWrite_reg;

always_ff @(posedge CLK, negedge RESET_N)
	if (!RESET_N)
		begin
		pc_reg2 <= '0; 
		read_data1_reg <= '0;
		read_data2_reg <= '0;
		ImmGen_reg <= '0;
		i30_reg <= '0;
		funct3_reg <= '0;
		rd_reg <= '0;
		AluOP_reg <= '0;
		AluSrc_reg <= '0;
		Branch_reg <= '0;
		MemWrite_reg <= '0;
		MemRead_reg <= '0;
		AuipcLui_reg <= '0;
		MemtoReg_reg <= '0;
		RegWrite_reg <= '0;
		end
	else
		begin
		pc_reg2 <= pc_reg1; 
		read_data1_reg <= read_data1;
		read_data2_reg <= read_data2;
		ImmGen_reg <= ImmGen;
		i30_reg <= instruction_reg[30];
		funct3_reg <= instruction_reg[14:12];
		rd_reg <= instruction_reg[11:7];
		AluOP_reg <= ALUOp;
		AluSrc_reg <=  ALUSrc;
		Branch_reg <= Branch;
		MemWrite_reg <= MemWrite;
		MemRead_reg <= MemRead;
		AuipcLui_reg <= AuipcLui;
		MemtoReg_reg <= MemtoReg;
		RegWrite_reg <= RegWrite;
		end


//Banco 3 EX/MEM
logic [31:0] Sum_reg, ALU_result_reg, read_data2_reg2;
logic [4:0] rd_reg2;
logic zero_reg, Branch_reg2, MemWrite_reg2, MemRead_reg2, MemtoReg_reg2, RegWrite_reg2;

always_ff @(posedge CLK, negedge RESET_N)
	if (!RESET_N)
		begin
		Sum_reg <= '0;
		zero_reg <= '0;
		ALU_result_reg <= '0;
		read_data2_reg2 <= '0;
		rd_reg2 <= '0;
		Branch_reg2 <= '0
		MemWrite_reg2 <= '0;
		MemRead_reg2 <= '0;
		MemtoReg_reg2 <= '0;
		RegWrite_reg2 <= '0;
		end
	else
		begin
		Sum_reg <= Sum;
		zero_reg <= zero;
		ALU_result_reg <= ALU_result;
		read_data2_reg2 <= read_data2_reg;
		rd_reg2 <= rd_reg;
		Branch_reg2 <= Branch_reg
		MemWrite_reg2 <= MemWrite_reg;
		MemRead_reg2 <= MemRead_reg;
		MemtoReg_reg2 <= MemtoReg_reg;
		RegWrite_reg2 <= RegWrite_reg;
		end


//Banco 4 MEM/WB
logic [31:0] ddata_r_reg, ALU_result_reg2;
logic MemtoReg_reg3, RegWrite_reg3;

always_ff @(posedge CLK, negedge RESET_N)
	if (!RESET_N)
		begin
		MemtoReg_reg3 <= '0;
		ddata_r_reg <= '0;
		ALU_result_reg2 <= '0;
		RegWrite_reg3 <= '0;
		end
	else
		begin
		MemtoReg_reg3 <= MemtoReg_reg2;
		ddata_r_reg <= ddata_r;
		ALU_result_reg2 <= ALU_result_reg;
		RegWrite_reg3 <= RegWrite_reg2;
		end

// Registros con enable y clear (reset síncrono)
// Incluir las instrucciones SLLI, SRLI, SRAI, SLL, SRL, SRA, JAL, JALR, BLT, BLTU, BGE, BGEU.


// DATA  FORWARDING
// Forwarding unit
always_comb
	if(EX/MEM.RegisterRd == ID/EX.RegisterRs1)or(EX/MEM.RegisterRd = ID/EX.RegisterRs2)

	else

	if

	else


// Mux forward A
always_comb
	case(ForwardA)
		2'b00: 
		2'b01: 
		2'b10: 
		default:
	endcase

// Mux forward B
always_comb
	case(ForwardB)
		2'b00: 
		2'b01: 
		2'b10: 
		default:
	endcase


// RIESGO DE DATOS POR CARGA
// Añadimos una NOP si detectamos el riesgo:
// Hazard detection unit detecta el riesgo
// Señales de control a 0 durante un ciclo de reloj
// Congelamos el PC (enable = 0) durante un ciclo de reloj
// Limpiamos los registros de control (clear = 1)


//

endmodule
