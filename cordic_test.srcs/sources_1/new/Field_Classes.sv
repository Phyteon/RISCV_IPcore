`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.10.2021 18:37:09
// Design Name: 
// Module Name: Field_Classes
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

import Architecture_AClass::*;

// Defines section to avoid magic numbers (all numbers should be defined in some way)
// In accordance with "The RISC-V Instruction Set Manual. Volume I: User-Level ISA. Document Version 2.2" from May 7, 2017
`define RD_field_BeginIdx 7
`define RD_field_BitWidth 5
`define OPCODE_field_BeginIdx 0
`define OPCODE_field_BitWidth 7
`define FUNCT3_field_BeginIdx 12
`define FUNCT3_field_BitWidth 3
`define FUNCT7_field_BeginIdx 25
`define FUNCT7_field_BitWidth 7
`define RS1_field_BeginIdx 15
`define RS1_field_BitWidth 5
`define RS2_field_BeginIdx 20
`define RS2_field_BitWidth 5

package Field_Classes;

    virtual class InstructionField extends Architecture_AClass::Architecture;
        const `uint BitWidth;
        const `uint BeginIdx;
        const string Info;
        function `uint ExtractFromInstr(input `ivector(logic) _inst);
            return `to_uint(_inst[BeginIdx : BitWidth - 1]); // TODO: Check the conversion here
        endfunction
    endclass
    
    class RD_field extends InstructionField;
        function new();
            this.BitWidth = `RD_field_BitWidth; 
            this.BeginIdx = `RD_field_BeginIdx;
            this.Info = "RD_field";
        endfunction
    endclass
    
    class OPCODE_field extends InstructionField;
        function new();
            this.BitWidth = `OPCODE_field_BitWidth;
            this.BeginIdx = `OPCODE_field_BeginIdx;
            this.Info = "OPCODE_field";
        endfunction
    endclass
    
    class FUNCT3_field extends InstructionField;
        function new();
            this.BitWidth = `FUNCT3_field_BitWidth;
            this.BeginIdx = `FUNCT3_field_BeginIdx;
            this.Info = "FUNCT3_field";
        endfunction
    endclass
    
    class FUNCT7_field extends InstructionField;
        function new();
            this.BitWidth = `FUNCT7_field_BitWidth;
            this.BeginIdx = `FUNCT7_field_BeginIdx;
            this.Info = "FUNCT7_field";
        endfunction
    endclass
    
    class RS1_field extends InstructionField;
        function new();
            this.BitWidth = `RS1_field_BitWidth;
            this.BeginIdx = `RS1_field_BeginIdx;
            this.Info = "RS1_field";
        endfunction
    endclass
    
    class RS2_field extends InstructionField;
        function new();
            this.BitWidth = `RS2_field_BitWidth;
            this.BeginIdx = `RS2_field_BeginIdx;
            this.Info = "RS2_field";
        endfunction
    endclass
    
    class IMM_field extends InstructionField;
        function new(input int _BitWidth, input int _BeginIdx, input string _Info);
            this.BitWidth = _BitWidth;
            this.BeginIdx = _BeginIdx;
            this.Info = _Info;
        endfunction
    endclass
endpackage
