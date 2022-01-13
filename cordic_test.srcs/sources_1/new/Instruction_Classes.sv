`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: AGH University of Science and Technology
// Engineer: Filip P.
// 
// Create Date: 14.10.2021 23:00:44
// Design Name: NA
// Module Name: Instruction_Classes
// Project Name: RISC-V IP Core
// Target Devices: NA
// Tool Versions: NA
// Description: 
//
// This file contains classes defining instruction types used throughout the project.
// 
// Dependencies: 
// 
// Architecture_AClass package
// Field_Class package
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
// In accordance with "The RISC-V Instruction Set Manual. Volume I: User-Level ISA.
// Document Version 2.2" from May 7, 2017
//////////////////////////////////////////////////////////////////////////////////

`include "CommonHeader.sv"

/**
* Utility macros.
*/
`define Init_Params(bit_width, begin_idx) .BitWidth(bit_width), .BeginIdx(begin_idx)
`define Init_OPCODE     `Init_Params(`OPCODE_field_BitWidth, `OPCODE_field_BeginIdx)
`define Init_RD         `Init_Params(`RD_field_BitWidth, `RD_field_BeginIdx)
`define Init_FUNCT3     `Init_Params(`FUNCT3_field_BitWidth, `FUNCT3_field_BeginIdx)
`define Init_RS1        `Init_Params(`RS1_field_BitWidth, `RS1_field_BeginIdx)
`define Init_RS2        `Init_Params(`RS2_field_BitWidth, `RS2_field_BeginIdx)
`define Init_FUNCT7     `Init_Params(`FUNCT7_field_BitWidth, `FUNCT7_field_BeginIdx)


package Instruction_Classes;
    import Architecture_AClass::*;
    import Field_Classes::*;
    
    typedef enum {
                   Rtype = 0,
                   Itype = 1,
                   Stype = 2,
                   Btype = 3,
                   Utype = 4,
                   Jtype = 5
                         } InstructionFormat;
    typedef enum {
                   RV32I,
                   RV64I,
                   RV32M,
                   RV64M,
                   RV32A,
                   RV64A,
                   RV32F,
                   RV64F,
                   RV32D,
                   RV64D
                         } InstructionSet;
    
    virtual class Instruction extends Architecture_AClass::Architecture;
        `_public InstructionFormat Format;
        `_public InstructionSet Set;
        `_public `ivector Contents;
        `_public InstructionField Fields[];
    endclass
    
    class RTypeInstruction extends Instruction;
        `_public function new(input `ivector _contents);
            this.Contents = _contents;
            this.Format = Rtype;
            this.Set = RV32I;
            this.Fields = new [`RTypeInstruction_NumOfFields];
            this.Fields[0] = `fieldpkg::OPCODE_field#(`Init_OPCODE)::new;
            this.Fields[1] = `fieldpkg::RD_field#(`Init_RD)::new;
            this.Fields[2] = `fieldpkg::FUNCT3_field#(`Init_FUNCT3)::new;
            this.Fields[3] = `fieldpkg::RS1_field#(`Init_RS1)::new;
            this.Fields[4] = `fieldpkg::RS2_field#(`Init_RS2)::new;
            this.Fields[5] = `fieldpkg::FUNCT7_field#(`Init_FUNCT7)::new;
        endfunction
    endclass
    
    class ITypeInstruction extends Instruction;
        `_public function new(input `ivector _contents);
            this.Contents = _contents;
            this.Format = Itype;
            this.Set = RV32I;
            this.Fields = new [`ITypeInstruction_NumOfFields];
            this.Fields[0] = `fieldpkg::OPCODE_field#(`Init_OPCODE)::new;
            this.Fields[1] = `fieldpkg::RD_field#(`Init_RD)::new;
            this.Fields[2] = `fieldpkg::FUNCT3_field#(`Init_FUNCT3)::new;
            this.Fields[3] = `fieldpkg::RS1_field#(`Init_RS1)::new;
            this.Fields[4] = `fieldpkg::IMM_field#(`Init_Params(`ITypeInstruction_IMM1_field_BitWidth, `ITypeInstruction_IMM1_field_BeginIdx))::new("IMM_field[11:0]");
        endfunction
    endclass
    
    class STypeInstruction extends Instruction;
        `_public function new(input `ivector _contents);
            this.Contents = _contents;
            this.Format = Stype;
            this.Set = RV32I;
            this.Fields = new [`STypeInstruction_NumOfFields];
            this.Fields[0] = `fieldpkg::OPCODE_field#(`Init_OPCODE)::new;
            this.Fields[1] = `fieldpkg::IMM_field#(`Init_Params(`STypeInstruction_IMM1_field_BitWidth, `STypeInstruction_IMM1_field_BeginIdx))::new("IMM_field[4:0]");
            this.Fields[2] = `fieldpkg::FUNCT3_field#(`Init_FUNCT3)::new;
            this.Fields[3] = `fieldpkg::RS1_field#(`Init_RS1)::new;
            this.Fields[4] = `fieldpkg::RS2_field#(`Init_RS2)::new;
            this.Fields[5] = `fieldpkg::IMM_field#(`Init_Params(`STypeInstruction_IMM2_field_BitWidth, `STypeInstruction_IMM2_field_BeginIdx))::new("IMM_field[11:5]");
        endfunction
    endclass
    
    class BTypeInstruction extends Instruction;
        `_public function new(input `ivector _contents);
            this.Contents = _contents;
            this.Format = Btype;
            this.Set = RV32I;
            this.Fields = new [`BTypeInstruction_NumOfFields];
            this.Fields[0] = `fieldpkg::OPCODE_field#(`Init_OPCODE)::new;
            this.Fields[1] = `fieldpkg::IMM_field#(`Init_Params(`BTypeInstruction_IMM1_field_BitWidth, `BTypeInstruction_IMM1_field_BeginIdx))::new("IMM_field[11]");
            this.Fields[2] = `fieldpkg::IMM_field#(`Init_Params(`BTypeInstruction_IMM2_field_BitWidth, `BTypeInstruction_IMM2_field_BeginIdx))::new("IMM_field[4:1]");
            this.Fields[3] = `fieldpkg::FUNCT3_field#(`Init_FUNCT3)::new;
            this.Fields[4] = `fieldpkg::RS1_field#(`Init_RS1)::new;
            this.Fields[5] = `fieldpkg::RS2_field#(`Init_RS2)::new;
            this.Fields[6] = `fieldpkg::IMM_field#(`Init_Params(`BTypeInstruction_IMM3_field_BitWidth, `BTypeInstruction_IMM3_field_BeginIdx))::new("IMM_field[10:5]");
            this.Fields[7] = `fieldpkg::IMM_field#(`Init_Params(`BTypeInstruction_IMM4_field_BitWidth, `BTypeInstruction_IMM4_field_BeginIdx))::new("IMM_field[12]");
        endfunction
    endclass
    
    class UTypeInstruction extends Instruction;
        `_public function new(input `ivector _contents);
            this.Contents = _contents;
            this.Format = Utype;
            this.Set = RV32I;
            this.Fields = new [`UTypeInstruction_NumOfFields];
            this.Fields[0] = `fieldpkg::OPCODE_field#(`Init_OPCODE)::new;
            this.Fields[1] = `fieldpkg::RD_field#(`Init_RD)::new;
            this.Fields[2] = `fieldpkg::IMM_field#(`Init_Params(`UTypeInstruction_IMM1_field_BitWidth, `UTypeInstruction_IMM1_field_BeginIdx))::new("IMM_field[31:12]");
        endfunction
    endclass
    
    class JTypeInstruction extends Instruction;
        `_public function new(input `ivector _contents);
            this.Contents = _contents;
            this.Format = Jtype;
            this.Set = RV32I;
            this.Fields = new [`JTypeInstruction_NumOfFields];
            this.Fields[0] = `fieldpkg::OPCODE_field#(`Init_OPCODE)::new;
            this.Fields[1] = `fieldpkg::RD_field#(`Init_RD)::new;
            this.Fields[2] = `fieldpkg::IMM_field#(`Init_Params(`JTypeInstruction_IMM1_field_BitWidth, `JTypeInstruction_IMM1_field_BeginIdx))::new("IMM_field[19:12]");
            this.Fields[3] = `fieldpkg::IMM_field#(`Init_Params(`JTypeInstruction_IMM2_field_BitWidth, `JTypeInstruction_IMM2_field_BeginIdx))::new("IMM_field[11]");
            this.Fields[4] = `fieldpkg::IMM_field#(`Init_Params(`JTypeInstruction_IMM3_field_BitWidth, `JTypeInstruction_IMM3_field_BeginIdx))::new("IMM_field[10:1]");
            this.Fields[5] = `fieldpkg::IMM_field#(`Init_Params(`JTypeInstruction_IMM4_field_BitWidth, `JTypeInstruction_IMM4_field_BeginIdx))::new("IMM_field[20]");
        endfunction
    endclass
endpackage

