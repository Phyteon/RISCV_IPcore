`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: AGH University of Science and Technology
// Engineer: 
// 
// Create Date: 22.03.2021 20:34:16
// Design Name: 
// Module Name: instruction_decoder
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
// This module is part of RISC-V IP core project
//////////////////////////////////////////////////////////////////////////////////



module instruction_decoder(
    input [31:0] inst,
    input clk,
    input reset,
    output reg_write,
    output outcome
    );
    ////////////////////////////////////////////////////////////////////////////////////////
    // Base instuction fields division, all formats of instructions can be defined with those
    parameter integer opcode_idx = 0;
    parameter integer opcode_len = 7;
    parameter integer rd_idx = 7;
    parameter integer rd_len = 5;
    parameter integer funct3_idx = 12;
    parameter integer funct3_len = 3;
    parameter integer rs1_idx = 15;
    parameter integer rs1_len = 5;
    parameter integer rs2_idx = 20;
    parameter integer rs2_len = 5;
    parameter integer funct7_idx = 25;
    parameter integer funct7_len = 7; // TODO: Remake as union
    /////////////////////////////////////////////////////////////////////////////////////////
    
    //////////////////////////////////////////////////////////
    // Wires for R-type instruction format
    wire [opcode_len-1:0] opcode;
    wire [rd_len-1:0] rd;
    wire [funct3_len-1:0] funct3;
    wire [rs1_len-1:0] rs1;
    wire [rs2_len-1:0] rs2;
    wire [funct7_len-1:0] funct7;
    // Assignment statements
    assign opcode = inst[opcode_len-1:opcode_idx];
    assign rd = inst[rd_len+rd_idx-1:rd_idx];
    assign funct3 = inst[funct3_len+funct3_idx-1:funct3_idx];
    assign rs1 = inst[rs1_len+rs1_idx-1:rs1_idx];
    assign rs2 = inst[rs2_len+rs2_idx-1:rs2_idx];
    assign funct7 = inst[funct7_len+funct7_idx-1:funct7_idx];
    //////////////////////////////////////////////////////////
    
    //////////////////////////////////////////////////////////
    // Wires for I-type instruction format
    wire [funct7_len+rs2_len-1:0] I_immediate;
    // Assignment statements
    assign I_immediate = inst[funct7_len+funct7_idx-1:rs2_idx];
    //////////////////////////////////////////////////////////
    
    
    always @(posedge clk or posedge reset)
    begin
        if(reset == 1)
        begin
            // Handle the reset
        end else begin    
            if(opcode == 7'b0110011) // R-type instruction format
            begin
                case (funct3)
                    3'b111: if(funct7 == 7'h0) // AND
                            begin
                                // Implement AND instruction
                            end
                    3'b110: if(funct7 == 7'h0) // OR
                            begin
                                // Implement OR instruction
                            end
                    
                    endcase;
            end else if(opcode == 7'b0010011) // I-type instruction format
            begin
                case (funct3)
                    3'b000: ; // Implement ADDI (NOP) instruction
                    
                endcase
            end // If additional instruction formats needed, add else if case
        end
    end     
   
// IMPORTANT! No explicit MOV instruction specified in RISC-V ISA. Same operation can be achieved by:
// AND x2, x0, x2    <- Suppose we want to copy register x3 into register x2. First we make sure that x2 is empty. (can be done in a multiple of ways)
// ADD x2, x2, x3    <- Add x3 to x2    
        
    
endmodule
