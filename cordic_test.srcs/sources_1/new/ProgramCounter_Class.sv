`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.10.2021 00:10:14
// Design Name: 
// Module Name: ProgramCounter_Class
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
import Register_Class::*;

`define InstructionAddressByteSize (RegisterBitWidth/8)

package ProgramCounter_Class;
    class ProgramCounter extends Register_Class::Register;
        
        function new(input `rvector(logic) _address);
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
