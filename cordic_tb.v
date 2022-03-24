`timescale 1ns / 1ns

module cordic_tb;
// Inputs
reg clk;
reg reset;
reg		[31:0]	phase;
wire signed [31:0] sin;
wire signed [31:0] cos;
wire signed [31:0] Error;

//// ʱ��
//initial begin
//#0 clk = 1'b0;
//forever #10 clk = ~clk; //20nsʱ�����ڣ���Ӧ50M
//end
//// ��λ
//initial begin
//reset = 0;
//# 50 reset = 1;
//end
always #10 clk=~clk;
initial begin
	#1 clk=1'b0;
	#20 phase=32'd60;
	#50 reset=1'b0;
	#50 reset=1'b1;
end

cordic_function1 u1(
.clk (clk),
.reset (reset),
.phase (phase),//  30��
.sin (sin),
.cos (cos),
.Error (Error)
);

endmodule
