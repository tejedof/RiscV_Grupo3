`timescale 1ps/1ns
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
logic [4:0] ALU_operation;
logic [tamanyo-1:0] A, B;
logic [tamanyo-1:0] res, res_GM;
logic zero, zero_GM;


//Device Under Verification
ALU duv(.*);
//FIN BLOQUE DUV

initial begin CLK = 1'b0;
forever #(T/2)  CLK = !CLK;
end

initial
begin
   CASO();
   comprobar();

   CASO();
   comprobar();

   CASO();
   comprobar();

   CASO();
   comprobar();
    $finish
end

//TASK


task comprobar;
begin
    assert(zero_GM==zero && res == res_GM)
    else
        $error("Ha ocurrido un error. El resultado no es el esperado")
end 
endtask

task CASO;
input [tamanyo-1:0] User_Operando1;
input [tamanyo-1:0] User_Operando2;
input [4:0] User_ALU_control;
begin
    A = User_Operando1;
    B = User_Operando2;
    ALU_operation = User_ALU_control;
    #(T)
    case(User_ALU_control)
        4'b0001:
            begin
                res_GM = A + B;
                zero_GM = 1'b0;
            end
        4'b0010:
            begin
                res_GM = A - B;
                zero_GM = 1'b0;
            end
        //OJO QUE ES IGUAL QUE 4'b0001
        4'b0011:
            begin
                res_GM = A + B;
                zero_GM = 1'b0;
            end
        4'b0100:
            begin
                res_GM = A & B;
                zero_GM = 1'b0;
            end
        4'b0101: 
            begin
                res_GM = A | B;
                zero_GM = 1'b0;
            end
        4'b0110:
            begin
                if(A-B < 0)
                    begin
                        res_GM = 0;
                        zero_GM = 1'b1;
                    end
                else
                    begin
                        res_GM = 0;
                        zero_GM = 1'b0;
                    end
            end
        4'b0111:
            begin
                if(A-B >= 0)
                    begin
                        res_GM = 0;
                        zero_GM = 1'b1;
                    end
                else
                    begin
                        res_GM = 0;
                        zero_GM = 1'b0;
                    end
            end
        4'b1000:
            begin
                res_GM = A | B;
                zero_GM = 1'b1;
            end
        4'b1001:
            begin
                res_GM = A ^ B;
                zero_GM = 1'b0;
            end
        4'b1010:
            begin
                if(A-B == 0)
                    begin
                        res_GM = 0;
                        zero_GM = 1'b1;
                    end
                else
                    begin
                        res_GM = 0;
                        zero_GM = 1'b0;
                    end
            end
    endcase
end
endtask

    
endmodule