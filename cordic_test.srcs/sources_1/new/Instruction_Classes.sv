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
            // TODO: implement in derived classes
        endfunction
    endclass
    
    class RTypeInstruction extends Instruction;
        function new(input `ivector(logic) _contents);
            this.Contents = _contents;
            this.Format = Rtype;
            this.Set = RV32I;
            this.Fields = new [6];
            this.Fields[0] = Field_Classes::OPCODE_field::new;
            this.Fields[1] = Field_Classes::RD_field::new;
            this.Fields[2] = Field_Classes::FUNCT3_field::new;
            this.Fields[3] = Field_Classes::RS1_field::new;
            this.Fields[4] = Field_Classes::RS2_field::new;
            this.Fields[5] = Field_Classes::FUNCT7_field::new;
        endfunction
    endclass
endpackage

