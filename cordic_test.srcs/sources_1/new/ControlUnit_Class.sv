`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.10.2021 23:16:20
// Design Name: 
// Module Name: ControlUnit_Class
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
import Instruction_Classes::*;

`define CONTROL_UNIT_OUTPUT_TYPE int // only for development purposes, will be changed later


package ControlUnit_Class;
    class ControlUnit extends Architecture_AClass::Architecture;
    
    `_public function `CONTROL_UNIT_OUTPUT_TYPE DecodeInstruction(input `inspkg::Instruction);

        
    endfunction

    `_private function `CONTROL_UNIT_OUTPUT_TYPE DecodeRtype(input `inspkg::RTypeInstruction);
        
    endfunction
    
    endclass
endpackage
