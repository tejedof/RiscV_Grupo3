`timescale 1ns/1ps
module tb_alu();
//Es un combinacional. Le entraran los dos operandos y el codigo de operacion
localparam T=20;
localparam tamanyo=32;

//INPUTS
//---OPERANDO 1
//---OPERANDO 2
//---CODIGO OPERACION
//logic CLK, RSTa, Start;
//logic [tamanyo-1:0] Num, Den;
logic CLK;
logic [4:0] ALU_control;
logic [tamanyo-1:0] A, B;
logic [tamanyo-1:0] ALU_result, res_GM;
logic zero, zero_GM;


//Device Under Verification
ALU duv(.*);
//FIN BLOQUE DUV

initial begin CLK = 1'b0;
forever #(T/2)  CLK = !CLK;
end

initial
begin
   CASO(3,4,0);
   comprobar();

   CASO(10,2,5'b00010);
   comprobar();

   CASO(30,50,5'b01000);
   comprobar();

   CASO(25,4,5'b11100);
   comprobar();
$finish;
end

//TASK


task comprobar;
begin
    assert(zero_GM==zero && ALU_result == res_GM)
    else
        $error("Ha ocurrido un error. El resultado no es el esperado");
end 
endtask

task CASO;
input [tamanyo-1:0] User_Operando1;
input [tamanyo-1:0] User_Operando2;
input [4:0] User_ALU_control;
begin
    A = User_Operando1;
    B = User_Operando2;
    ALU_control = User_ALU_control;
    #(T);
     
 
    case(ALU_control)
      		5'b00000: res_GM = A + B; 
		5'b00010: res_GM = A - B;
		5'b00100: res_GM = A<<B;
		5'b01000: res_GM = (A<B)? 32'b1 : 32'b0; //5'b01xxx  BLT 
		5'b01100: res_GM = (A<B)? 32'b0 : 32'b1; //5'b01xxx BLTU 
		5'b10000: res_GM = A ^ B;
		5'b10100: res_GM = A>>B; //5'b101xx
		5'b10110: res_GM = A>>B; //5'b101xx
		5'b11000: res_GM = A | B; 
		5'b11010: res_GM = (A>=B)? 32'b0 : 32'b1; //5'b11x10 BGE
		5'b11100: res_GM = A & B;
		5'b11110: res_GM = (A>=B)? 32'b0 : 32'b1;//5'b11x10
		5'b11111: res_GM = A + B; 
    		default:  res_GM = 0; 
    endcase

    assign zero_GM = (res_GM==32'b0) ? 1'b1: 1'b0;
    end
endtask   
endmodule