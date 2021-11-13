`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.10.2021 00:01:02
// Design Name: 
// Module Name: RV_core
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
import RegistryFile_Class::*;
import Instruction_Classes::*;
import ProgramCounter_Class::*;
import Multiplexer_Class::*;
import ControlUnit_Class::*;


module RV_core();

// Classes initialisation

`regfilepkg::RegistryFile registers; // Register bank

`muxpkg::Multiplexer alu_mux;




endmodule
