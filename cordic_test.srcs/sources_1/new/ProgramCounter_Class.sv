`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: AGH University of Science and Technology
// Engineer: Filip P.
// 
// Create Date: 22.10.2021 00:10:14
// Design Name: NA
// Module Name: ProgramCounter_Class
// Project Name: RISC-V IP Core
// Target Devices: NA
// Tool Versions: NA
// Description: 
//
// This file contains ProgramCounter class which is an extention of Register class.
// Not essential to the project.
// 
// Dependencies: 
// 
// Architecture_AClass package
// Register_Class package
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

import Architecture_AClass::*;
import Register_Class::*;

// Global package alias
`define progcntpkg ProgramCounter_class

`define InstructionAddressByteSize (`REGISTER_GLOBAL_BITWIDTH/8)

package ProgramCounter_Class;
    class ProgramCounter extends `regpkg::Register;
        
        function new(input `rvector _address);
            super.new(_address);
        endfunction
        
        function IncrementByNInstructions(input `uint num_of_instr);
            this.contents = this.contents + (`InstructionAddressByteSize * num_of_instr);
        endfunction
        
        function DecrementByNInstructions(input `uint num_of_instr);
            this.contents = this.contents - (`InstructionAddressByteSize * num_of_instr);
        endfunction
        
        function ChangeByOffset(input `sint offset);
            this.contents = this.contents + offset;
        endfunction
        
    endclass
endpackage
