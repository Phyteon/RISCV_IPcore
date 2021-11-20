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

import Architecture_AClass::*;
import Field_Classes::*;

// Global package alias
`define instrpkg Instruction_Classes

//// Macro definitions - number of fields ////
`define RTypeInstruction_NumOfFields 6
`define ITypeInstruction_NumOfFields 5
`define STypeInstruction_NumOfFields 6
`define BTypeInstruction_NumOfFields 8
`define UTypeInstruction_NumOfFields 3
`define JTypeInstruction_NumOfFields 6

// ITypeInstruction macros //
`define ITypeInstruction_IMM_field_BeginIdx 20
`define ITypeInstruction_IMM_field_BitWidth 12

// STypeInstruction macros //
`define STypeInstruction_IMM1_field_BeginIdx 7
`define STypeInstruction_IMM1_field_BitWidth 5
`define STypeInstruction_IMM2_field_BeginIdx 25
`define STypeInstruction_IMM2_field_BitWidth 7

// BTypeInstruction macros //
`define BTypeInstruction_IMM1_field_BeginIdx 7
`define BTypeInstruction_IMM1_field_BitWidth 1
`define BTypeInstruction_IMM2_field_BeginIdx 8
`define BTypeInstruction_IMM2_field_BitWidth 4
`define BTypeInstruction_IMM3_field_BeginIdx 25
`define BTypeInstruction_IMM3_field_BitWidth 6
`define BTypeInstruction_IMM4_field_BeginIdx 31
`define BTypeInstruction_IMM4_field_BitWidth 1

// UTypeInstruction macros //
`define UTypeInstruction_IMM_field_BeginIdx 12
`define UTypeInstruction_IMM_field_BitWidth 20

// JTypeInstruction macros //
`define JTypeInstruction_IMM1_field_BeginIdx 12
`define JTypeInstruction_IMM1_field_BitWidth 8
`define JTypeInstruction_IMM2_field_BeginIdx 20
`define JTypeInstruction_IMM2_field_BitWidth 1
`define JTypeInstruction_IMM3_field_BeginIdx 21
`define JTypeInstruction_IMM3_field_BitWidth 10
`define JTypeInstruction_IMM4_field_BeginIdx 31
`define JTypeInstruction_IMM4_field_BitWidth 1

package Instruction_Classes;
    typedef enum {
                   Rtype,
                   Itype,
                   Stype,
                   Btype,
                   Utype,
                   Jtype
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
    
    virtual class Instruction extends `archpkg::Architecture;
        `_public const InstructionFormat Format;
        `_public const InstructionSet Set;
        `_public const `ivector Contents;
        `_public `class_handle_dynamic_array Fields;
    endclass
    
    class RTypeInstruction extends Instruction;
        `_public function new(input `ivector _contents);
            this.Contents = _contents;
            this.Format = Rtype;
            this.Set = RV32I;
            this.Fields = new [`RTypeInstruction_NumOfFields];
            this.Fields[0] = `fieldpkg::OPCODE_field#(`OPCODE_field_BitWidth)::new;
            this.Fields[1] = `fieldpkg::RD_field#(`RD_field_BitWidth)::new;
            this.Fields[2] = `fieldpkg::FUNCT3_field#(`FUNCT3_field_BitWidth)::new;
            this.Fields[3] = `fieldpkg::RS1_field#(`RS1_field_BitWidth)::new;
            this.Fields[4] = `fieldpkg::RS2_field#(`RS2_field_BitWidth)::new;
            this.Fields[5] = `fieldpkg::FUNCT7_field#(`FUNCT7_field_BitWidth)::new;
        endfunction
    endclass
    
    class ITypeInstruction extends Instruction;
        `_public function new(input `ivector _contents);
            this.Contents = _contents;
            this.Format = Itype;
            this.Set = RV32I;
            this.Fields = new [`ITypeInstruction_NumOfFields];
            this.Fields[0] = `fieldpkg::OPCODE_field#(`OPCODE_field_BitWidth)::new;
            this.Fields[1] = `fieldpkg::RD_field#(`RD_field_BitWidth)::new;
            this.Fields[2] = `fieldpkg::FUNCT3_field#(`FUNCT3_field_BitWidth)::new;
            this.Fields[3] = `fieldpkg::RS1_field#(`RS1_field_BitWidth)::new;
            this.Fields[4] = `fieldpkg::IMM_field#(`ITypeInstruction_IMM_field_BitWidth)::new(`ITypeInstruction_IMM_field_BeginIdx, "IMM_field[11:0]");
        endfunction
    endclass
    
    class STypeInstruction extends Instruction;
        `_public function new(input `ivector _contents);
            this.Contents = _contents;
            this.Format = Stype;
            this.Set = RV32I;
            this.Fields = new [`STypeInstruction_NumOfFields];
            this.Fields[0] = `fieldpkg::OPCODE_field#(`OPCODE_field_BitWidth)::new;
            this.Fields[1] = `fieldpkg::IMM_field#(`STypeInstruction_IMM1_field_BitWidth)::new(`STypeInstruction_IMM1_field_BeginIdx, "IMM_field[4:0]");
            this.Fields[2] = `fieldpkg::FUNCT3_field#(`FUNCT3_field_BitWidth)::new;
            this.Fields[3] = `fieldpkg::RS1_field#(`RS1_field_BitWidth)::new;
            this.Fields[4] = `fieldpkg::RS2_field#(`RS2_field_BitWidth)::new;
            this.Fields[5] = `fieldpkg::IMM_field#(`STypeInstruction_IMM2_field_BitWidth)::new(`STypeInstruction_IMM2_field_BeginIdx, "IMM_field[11:5]");
        endfunction
    endclass
    
    class BTypeInstruction extends Instruction;
        `_public function new(input `ivector _contents);
            this.Contents = _contents;
            this.Format = Btype;
            this.Set = RV32I;
            this.Fields = new [`BTypeInstruction_NumOfFields];
            this.Fields[0] = `fieldpkg::OPCODE_field::new;
            this.Fields[1] = `fieldpkg::IMM_field#(`BTypeInstruction_IMM1_field_BitWidth)::new(`BTypeInstruction_IMM1_field_BeginIdx, "IMM_field[11]");
            this.Fields[2] = `fieldpkg::IMM_field#(`BTypeInstruction_IMM2_field_BitWidth)::new(`BTypeInstruction_IMM2_field_BeginIdx, "IMM_field[4:1]");
            this.Fields[3] = `fieldpkg::FUNCT3_field#(`FUNCT3_field_BitWidth)::new;
            this.Fields[4] = `fieldpkg::RS1_field#(`RS1_field_BitWidth)::new;
            this.Fields[5] = `fieldpkg::RS2_field#(`RS2_field_BitWidth)::new;
            this.Fields[6] = `fieldpkg::IMM_field#(`BTypeInstruction_IMM3_field_BitWidth)::new(`BTypeInstruction_IMM3_field_BeginIdx, "IMM_field[10:5]");
            this.Fields[7] = `fieldpkg::IMM_field#(`BTypeInstruction_IMM4_field_BitWidth)::new(`BTypeInstruction_IMM4_field_BeginIdx, "IMM_field[12]");
        endfunction
    endclass
    
    class UTypeInstruction extends Instruction;
        `_public function new(input `ivector _contents);
            this.Contents = _contents;
            this.Format = Utype;
            this.Set = RV32I;
            this.Fields = new [`UTypeInstruction_NumOfFields];
            this.Fields[0] = `fieldpkg::OPCODE_field#(`OPCODE_field_BitWidth)::new;
            this.Fields[1] = `fieldpkg::RD_field#(`RD_field_BitWidth)::new;
            this.Fields[2] = `fieldpkg::IMM_field#(`UTypeInstruction_IMM_field_BitWidth)::new(`UTypeInstruction_IMM_field_BeginIdx, "IMM_field[31:12]");
        endfunction
    endclass
    
    class JTypeInstruction extends Instruction;
        `_public function new(input `ivector _contents);
            this.Contents = _contents;
            this.Format = Jtype;
            this.Set = RV32I;
            this.Fields = new [`JTypeInstruction_NumOfFields];
            this.Fields[0] = `fieldpkg::OPCODE_field#(`OPCODE_field_BitWidth)::new;
            this.Fields[1] = `fieldpkg::RD_field#(`RD_field_BitWidth)::new;
            this.Fields[2] = `fieldpkg::IMM_field#(`JTypeInstruction_IMM1_field_BitWidth)::new(`JTypeInstruction_IMM1_field_BeginIdx, "IMM_field[19:12]");
            this.Fields[3] = `fieldpkg::IMM_field#(`JTypeInstruction_IMM2_field_BitWidth)::new(`JTypeInstruction_IMM2_field_BeginIdx, "IMM_field[11]");
            this.Fields[4] = `fieldpkg::IMM_field#(`JTypeInstruction_IMM3_field_BitWidth)::new(`JTypeInstruction_IMM3_field_BeginIdx, "IMM_field[10:1]");
            this.Fields[5] = `fieldpkg::IMM_field#(`JTypeInstruction_IMM4_field_BitWidth)::new(`JTypeInstruction_IMM4_field_BeginIdx, "IMM_field[20]");
        endfunction
    endclass
endpackage

