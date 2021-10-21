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

`define InstructionAddressByteSize (RegisterBitWidth/8)

package ProgramCounter_Class;
    class ProgramCounter extends Architecture_AClass::Architecture;
        local `rvector(logic) address;
        
        function new(input `rvector(logic) _address);
            this.address = _address;
        endfunction
        
        function IncrementByNInstructions(input `uint num_of_instr);
            this.address = this.address + (`InstructionAddressByteSize * num_of_instr);
        endfunction
        
        function DecrementByNInstructions(input `uint num_of_instr);
            this.address = this.address - (`InstructionAddressByteSize * num_of_instr);
        endfunction
        
        function ChangeByOffset(input `sint offset);
            this.address = this.address + offset;
        endfunction
        
        function JumpTo(input `rvector(logic) _address);
            this.address = _address;
        endfunction
        
        function `rvector(logic) GetAddr();
            return this.address;
        endfunction
    endclass
endpackage
