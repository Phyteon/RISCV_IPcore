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
`define RTypeInstruction_NumOfFields 6
`define ITypeInstruction_NumOfFields 5
`define STypeInstruction_NumOfFields 6
`define ITypeInstruction_IMM_field_BeginIdx 20
`define ITypeInstruction_IMM_field_BitWidth 12
`define STypeInstruction_IMM1_field_BeginIdx 7
`define STypeInstruction_IMM1_field_BitWidth 5
`define STypeInstruction_IMM2_field_BeginIdx 25
`define STypeInstruction_IMM2_field_BitWidth 7

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
        const `ivector(logic) Contents;
        // Private list of fields
        local Field_Classes::InstructionField Fields[];
        
        function Field_Classes::InstructionField[] GetFields();
            return this.Fields;
        endfunction
    endclass
    
    class RTypeInstruction extends Instruction;
        function new(input `ivector(logic) _contents);
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
        function new(input `ivector(logic) _contents);
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
        function new(input `ivector(logic) _contents);
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
        function new(input `ivector(logic) _contents);
        
        endfunction
    endclass
endpackage

