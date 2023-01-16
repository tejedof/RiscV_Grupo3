module ALU

(
input  [31:0] A,
input  [31:0] B,  
input  [4:0] ALU_control, 
output zero,
output logic [31:0] ALU_result
);

always_comb 
	case(ALU_control)
		5'b00000: ALU_result = A + B;    						// ADD && JAL && JALR
		5'b00010: ALU_result = A - B;
		5'b00100: ALU_result = A<<B;								//SLLI && SLL
		5'b01000: ALU_result = $signed(A) < $signed(B);		//5'b01xxx	BLT
		5'b01100: ALU_result = A < B; 							//5'b01xxx	BLTU
		5'b10000: ALU_result = A ^ B;
		5'b10100: ALU_result = A >> B; 							//5'b101xx	SRLI && SRL
		5'b10110: ALU_result = A >> B; 							//5'b101xx	SRAI && SRA
		5'b11000: ALU_result = A | B; 
		5'b11010: ALU_result = $signed(A) >= $signed(B);	//5'b11x10	BGE
		5'b11100: ALU_result = A & B;
		5'b11110: ALU_result = A >= B;							//5'b11x10  BGEU		
		5'b11111: ALU_result = A + B;
		default:  ALU_result = 32'b0;
	endcase

assign zero = (ALU_result==32'b0) ? 1'b1: 1'b0;

endmodule
