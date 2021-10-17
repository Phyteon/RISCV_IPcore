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

// In accordance with "The RISC-V Instruction Set Manual. Volume I: User-Level ISA. Document Version 2.2" from May 7, 2017
package Field_Classes;

    virtual class InstructionField extends Architecture_AClass::Architecture;
        const int BitWidth;
        const int BeginIdx;
        const string Info;
        function int ExtractFromInstr(input `ivector(logic) _inst);
            return _inst[BeginIdx : BitWidth - 1]; // TODO: Check the conversion here
        endfunction
    endclass
    
    class RD_field extends InstructionField;
        function new();
            this.BitWidth = 5; 
            this.BeginIdx = 7;
            this.Info = "RD_field";
        endfunction
    endclass
    
    class OPCODE_field extends InstructionField;
        function new();
            this.BitWidth = 7;
            this.BeginIdx = 0;
            this.Info = "OPCODE_field";
        endfunction
    endclass
    
    class FUNCT3_field extends InstructionField;
        function new();
            this.BitWidth = 3;
            this.BeginIdx = 12;
            this.Info = "FUNCT3_field";
        endfunction
    endclass
    
    class FUNCT7_field extends InstructionField;
        function new();
            this.BitWidth = 7;
            this.BeginIdx = 25;
            this.Info = "FUNCT7_field";
        endfunction
    endclass
    
    class RS1_field extends InstructionField;
        function new();
            this.BitWidth = 5;
            this.BeginIdx = 15;
            this.Info = "RS1_field";
        endfunction
    endclass
    
    class RS2_field extends InstructionField;
        function new();
            this.BitWidth = 5;
            this.BeginIdx = 20;
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
