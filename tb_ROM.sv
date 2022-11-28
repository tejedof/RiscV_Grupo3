`timescale 1ps/1ns
module tb_ROM ();

initial begin CLK = 1'b0;
forever #(T/2)  CLK = !CLK;
end
    
endmodule