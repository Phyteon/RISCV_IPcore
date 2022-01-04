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

module ALU_Module(ALUInterface.DUT aluinf);
    import ALU_Class::*;

    `ifdef ALU_MODULE_DESIGN
        `alupkg::ALU alu;
        always @(`CLOCK_ACTIVE_EDGE aluinf.clk) begin
            if (aluinf.reset)
                aluinf.outcome = `ALU_OUTCOME_INITIAL_VALUE;
            else begin
                aluinf.outcome = alu.PerformOperation(aluinf.operation, aluinf.leftOperand, aluinf.rightOperand);
            end // else
        end
    `elsif ALU_MODULE_IMPLEMENTATION
        // Synthesizable code here
    `else
        `throw_compilation_error("No configuration defined for the ALU module!");
    `endif

endmodule
