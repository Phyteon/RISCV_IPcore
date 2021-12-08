`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.03.2021 21:05:35
// Design Name: 
// Module Name: mb_design_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mb_design_tb();

reg sysclk;
wire [11:0] angle;
wire [11:0] sin;
wire [11:0] cos;
reg reset_n;

real r_angle = 1024*3.14*0.2;
real r_sin, r_cos;
assign angle = r_angle;

initial
begin
    reset_n = 1'b0;
    #10 reset_n = 1'b1;
end

initial
begin
    sysclk = 1'b0;
end

always
begin
    #5 sysclk = ~sysclk;
end

always @*
begin
    r_sin = sin;
    r_cos = cos;
    r_sin = r_sin / 1024;
    r_cos = r_cos / 1024;
end

mb_design_wrapper mb_design_inst(angle, cos, sin, reset_n, sysclk);
endmodule
