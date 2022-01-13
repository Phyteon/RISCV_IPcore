`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: AGH University of Science and Technology
// Engineer: Filip P.
// 
// Create Date: 19.12.2021 15:18:04
// Design Name: 
// Module Name: ALU_Module
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

`include "CommonHeader.sv"

`define ALU_OUTCOME_INITIAL_VALUE `ALUVECTOR_BITWIDTH'h0

//// Compilation switches - if ALU_MODULE_DESIGN is defined, high level OOP implementation will be used
`define ALU_MODULE_DESIGN
//`define ALU_MODULE_IMPLEMENTATION

module ALU_Module(ALUInterface aluinf);
    import ALU_Class::*;

    `ifdef ALU_MODULE_DESIGN
        `alupkg::ALU alu;

        initial begin
            alu = new;
        end

        always_comb begin
            if (aluinf.alu_clk.reset)
                aluinf.alu_clk.outcome <= `ALU_OUTCOME_INITIAL_VALUE;
            else begin
                aluinf.alu_clk.outcome <= alu.PerformOperation(aluinf.operation, aluinf.left_operand, aluinf.right_operand);
                aluinf.alu_clk.alubctrl <= alu.branchctrl;
            end // else
        end
    `elsif ALU_MODULE_IMPLEMENTATION
        // Synthesizable code here
    `else
        `throw_compilation_error("No configuration defined for the ALU module!");
    `endif

endmodule
