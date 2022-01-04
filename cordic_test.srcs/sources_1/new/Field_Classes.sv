`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: AGH University of Science and Technology
// Engineer: Filip P.
// 
// Create Date: 17.10.2021 18:37:09
// Design Name: NA
// Module Name: Field_Classes
// Project Name: RISC-V IP Core
// Target Devices: NA
// Tool Versions: NA
// Description: 
// 
// This file contains package with classes representing bit fields in RISC-V ISA.
//
// Dependencies: 
// 
// Architecture_AClass package
//
// Revision:
// Revision 0.01 - File Created
// Revision 0.5 (26.10.2021) - Adjusted to changes in Architecture_AClass package
// Revision 0.7 (20.11.2021) - BitWidth is now a class parameter
// Additional Comments:
// 
// In accordance with "The RISC-V Instruction Set Manual. Volume I: User-Level ISA.
// Document Version 2.2" from May 7, 2017
//
// BitWidth must be passed as class parameter to allow vector slicing.
//////////////////////////////////////////////////////////////////////////////////

`include "CommonHeader.sv"

`define DEFAULT_PARAM 1

package Field_Classes;
    import Architecture_AClass::*;

    virtual class InstructionField #(BitWidth = `DEFAULT_PARAM, BeginIdx = `DEFAULT_PARAM) extends `archpkg::Architecture;
        `_public const string Info;
        
        `_public function `uint ExtractFromInstr(input `ivector _inst);
            `uint temp = _inst[BitWidth + BeginIdx - 1 : BeginIdx];
            return temp;
        endfunction
    endclass
    
    class RD_field extends InstructionField;
        `_public function new();
            this.Info = "RD_field";
        endfunction
    endclass
    
    class OPCODE_field extends InstructionField;
        `_public function new();
            this.Info = "OPCODE_field";
        endfunction
    endclass
    
    class FUNCT3_field extends InstructionField;
        `_public function new();
            this.Info = "FUNCT3_field";
        endfunction
    endclass
    
    class FUNCT7_field extends InstructionField;
        `_public function new();
            this.Info = "FUNCT7_field";
        endfunction
    endclass
    
    class RS1_field extends InstructionField;
        `_public function new();
            this.Info = "RS1_field";
        endfunction
    endclass
    
    class RS2_field extends InstructionField;
        `_public function new();
            this.Info = "RS2_field";
        endfunction
    endclass
    
    class IMM_field extends InstructionField;
        `_public `uint ImmBitWidth;
        `_public function new(input string _Info);
            this.Info = _Info;
            this.ImmBitWidth = BitWidth;
        endfunction
    endclass
endpackage
