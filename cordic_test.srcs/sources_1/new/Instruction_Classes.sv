`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.10.2021 23:00:44
// Design Name: 
// Module Name: Instruction_Classes
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
import Field_Classes::*;

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
    
    virtual class Instruction extends Architecture_AClass::Architecture;
        // Public field that holds the format of the instruction
        const InstructionFormat Format;
        // Public field that holds the set from which the instruction originates
        const InstructionSet Set;
        // Public vector holding binary contents of the instruction
        const `ivector(`rvtype) Contents;
        // Private list of fields
        Field_Classes::InstructionField Fields[];
        
    endclass
    
    class RTypeInstruction extends Instruction;
        function new(input `ivector(`rvtype) _contents);
            this.Contents = _contents;
            this.Format = Rtype;
            this.Set = RV32I;
            this.Fields = new [`RTypeInstruction_NumOfFields];
            this.Fields[0] = Field_Classes::OPCODE_field::new;
            this.Fields[1] = Field_Classes::RD_field::new;
            this.Fields[2] = Field_Classes::FUNCT3_field::new;
            this.Fields[3] = Field_Classes::RS1_field::new;
            this.Fields[4] = Field_Classes::RS2_field::new;
            this.Fields[5] = Field_Classes::FUNCT7_field::new;
        endfunction
    endclass
    
    class ITypeInstruction extends Instruction;
        function new(input `ivector(`rvtype) _contents);
            this.Contents = _contents;
            this.Format = Itype;
            this.Set = RV32I;
            this.Fields = new [`ITypeInstruction_NumOfFields];
            this.Fields[0] = Field_Classes::OPCODE_field::new;
            this.Fields[1] = Field_Classes::RD_field::new;
            this.Fields[2] = Field_Classes::FUNCT3_field::new;
            this.Fields[3] = Field_Classes::RS1_field::new;
            this.Fields[4] = Field_Classes::IMM_field::new(`ITypeInstruction_IMM_field_BitWidth, `ITypeInstruction_IMM_field_BeginIdx, "IMM_field[11:0]");
        endfunction
    endclass
    
    class STypeInstruction extends Instruction;
        function new(input `ivector(`rvtype) _contents);
            this.Contents = _contents;
            this.Format = Stype;
            this.Set = RV32I;
            this.Fields = new [`STypeInstruction_NumOfFields];
            this.Fields[0] = Field_Classes::OPCODE_field::new;
            this.Fields[1] = Field_Classes::IMM_field::new(`STypeInstruction_IMM1_field_BitWidth, `STypeInstruction_IMM1_field_BeginIdx, "IMM_field[4:0]");
            this.Fields[2] = Field_Classes::FUNCT3_field::new;
            this.Fields[3] = Field_Classes::RS1_field::new;
            this.Fields[4] = Field_Classes::RS2_field::new;
            this.Fields[5] = Field_Classes::IMM_field::new(`STypeInstruction_IMM2_field_BitWidth, `STypeInstruction_IMM2_field_BeginIdx, "IMM_field[11:5]");
        endfunction
    endclass
    
    class BTypeInstruction extends Instruction;
        function new(input `ivector(`rvtype) _contents);
            this.Contents = _contents;
            this.Format = Btype;
            this.Set = RV32I;
            this.Fields = new [`BTypeInstruction_NumOfFields];
            this.Fields[0] = Field_Classes::OPCODE_field::new;
            this.Fields[1] = Field_Classes::IMM_field::new(`BTypeInstruction_IMM1_field_BitWidth, `BTypeInstruction_IMM1_field_BeginIdx, "IMM_field[11]");
            this.Fields[2] = Field_Classes::IMM_field::new(`BTypeInstruction_IMM2_field_BitWidth, `BTypeInstruction_IMM2_field_BeginIdx, "IMM_field[4:1]");
            this.Fields[3] = Field_Classes::FUNCT3_field::new;
            this.Fields[4] = Field_Classes::RS1_field::new;
            this.Fields[5] = Field_Classes::RS2_field::new;
            this.Fields[6] = Field_Classes::IMM_field::new(`BTypeInstruction_IMM3_field_BitWidth, `BTypeInstruction_IMM3_field_BeginIdx, "IMM_field[10:5]");
            this.Fields[7] = Field_Classes::IMM_field::new(`BTypeInstruction_IMM4_field_BitWidth, `BTypeInstruction_IMM4_field_BeginIdx, "IMM_field[12]");
        endfunction
    endclass
    
    class UTypeInstruction extends Instruction;
        function new(input `ivector(`rvtype) _contents);
            this.Contents = _contents;
            this.Format = Utype;
            this.Set = RV32I;
            this.Fields = new [`UTypeInstruction_NumOfFields];
            this.Fields[0] = Field_Classes::OPCODE_field::new;
            this.Fields[1] = Field_Classes::RD_field::new;
            this.Fields[2] = Field_Classes::IMM_field::new(`UTypeInstruction_IMM_field_BitWidth, `UTypeInstruction_IMM_field_BeginIdx, "IMM_field[31:12]");
        endfunction
    endclass
    
    class JTypeInstruction extends Instruction;
        function new(input `ivector(`rvtype) _contents);
            this.Contents = _contents;
            this.Format = Jtype;
            this.Set = RV32I;
            this.Fields = new [`JTypeInstruction_NumOfFields];
            this.Fields[0] = Field_Classes::OPCODE_field::new;
            this.Fields[1] = Field_Classes::RD_field::new;
            this.Fields[2] = Field_Classes::IMM_field::new(`JTypeInstruction_IMM1_field_BitWidth, `JTypeInstruction_IMM1_field_BeginIdx, "IMM_field[19:12]");
            this.Fields[3] = Field_Classes::IMM_field::new(`JTypeInstruction_IMM2_field_BitWidth, `JTypeInstruction_IMM2_field_BeginIdx, "IMM_field[11]");
            this.Fields[4] = Field_Classes::IMM_field::new(`JTypeInstruction_IMM3_field_BitWidth, `JtypeInstruction_IMM3_field_BeginIdx, "IMM_field[10:1]");
            this.Fields[5] = Field_Classes::IMM_field::new(`JTypeInstruction_IMM4_field_BitWidth, `JTypeInstruction_IMM4_field_BeginIdx, "IMM_field[20]");
        endfunction
    endclass
endpackage

